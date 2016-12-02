require 'uri'
require 'socket'
require './lib/worker_thread'

class UDPRestClient
	attr_accessor :host
	attr_accessor :port
	attr_accessor :socket
	attr_accessor :timeout

	def initialize(host, port)
		@max_packet_size = 512

		self.host = host
		self.port = port
		self.socket = UDPSocket.new
		self.timeout = 5.0
	end

	def request(text)
		thread = WorkerThread.new.start :timeout => self.timeout do
			self.socket.send(text, 0, self.host, self.port)
			response_data = self.socket.recvfrom(@max_packet_size)
			UDPPacket.new(response_data)
		end

		thread.join
		packet = thread.value
		raise "Request Timeout (#{host}:#{port})" if packet.nil?
		return packet
	end

	def self.uhttp(req_method, url)
		uri = URI(url)
		client = UDPRestClient.new(uri.host, uri.port || 80)
		text = "#{req_method} #{uri.path || '/'} UHTTP/1.0\n"
		packet = client.request(text)
		UHTTPResponse.parse(packet.text)
	end

	def self.get(url)
		self.uhttp('GET', url)
	end
	
end

class UHTTPServer
	def initialize(options = {})
		@udp = UDPServer.new
		@routes = {}

		if block_given?
			yield(self) 
			port = options[:port] || 80
			options[:host] = options[:host] || '0.0.0.0'
			self.listen(port, options)
		end
	end

	def post(path, &block)
		add_route('POST', path, &block)
	end

	def get(path, &block)
		add_route('GET', path, &block)
	end

	def add_route(req_method, path, &block)
		key = "#{req_method.upcase} #{path}"
		@routes[key] = Proc.new &block 		
		return key
	end

	def route_request(request)
		key = "#{request.req_method.upcase} #{request.path}"
		puts key

		block = @routes[key]
		return respond(404, 'Not Found') if block.nil?
		
		# handle the response. No matter what gets returned
		# we want to try and make it into something useful
		result = block.call(request, self)
		return result if result.is_a? UHTTPResponse
		return respond(200, result.to_s) if result.respond_to? :to_s
		return respond(200, 'ok')
	end

	def listen(port, options = {})
		port = port || 80

		@udp.listen(port, options) do |packet|
			response = nil

			if response.nil?
				begin
					request = UHTTPRequest.new(packet.text)
				rescue => e
					puts "400 BAD REQUEST: #{e}"
					response = respond(400, 'Bad Request')
				end
			end

			if response.nil?
				begin
					response = route_request(request)
				rescue => e
					puts "500 APPLICATION ERROR: #{e}"
					response = respond(500, 'Application Error')
				end
			end

			@udp.send(response.to_s, packet.src_addr, packet.src_port)
		end
	end

	def respond(code, text)
		UHTTPResponse.new(code, :text => text)
	end
end

class UHTTPRequest
	attr_accessor :req_method
	attr_accessor :path
	attr_accessor :protocol

	def initialize(text)
		data = text.split(' ')
		raise 'invalid request' if data.length != 3
		self.req_method = data[0]
		self.path = data[1]
		self.protocol = data[2]
	end
end

class UHTTPResponse
	attr_accessor :code
	attr_accessor :protocol
	attr_accessor :text

	def initialize(code, options = {})
		self.code = code.to_i
		self.protocol = options[:protocol] || 'UHTTP/1.0'
		self.text = options[:text] || ''
	end

	def self.parse(s)
		data = s.split("\n\n")
		status = data[0].split(' ')
		text = data[1] if data.length > 1
		self.new(status[1], :text => text || '')
	end

	def ok?
		code == 200
	end

	def status_text
		return 'OK' if ok?
		return 'FAILED'
	end

	def status_line
		"#{protocol} #{code} #{status_text}"
	end

	def to_s
		"#{status_line}\n\n#{text}"
	end
end

class UDPServer
	attr_accessor :socket

	def initialize
		@max_packet_size = 512
		self.socket = UDPSocket.new
	end

	def listen(port, options = {})
		port = port.to_i
		host = options[:host] || '0.0.0.0'
		self.socket.bind(host, port)

		loop do
			response = self.receive()
			yield(response)
		end
	end

	def receive
		data = self.socket.recvfrom(@max_packet_size)
		UDPPacket.new(data)
	end

	def send(text, host, port)
		self.socket.send(text, 0, host, port)
	end

end

class UDPPacket
	attr_accessor :text
	attr_accessor :addr_family
	attr_accessor :src_port
	attr_accessor :src_addr

	def initialize(data = nil)
		# assume this was initialized with the standard data structure
		# that is returned by UDPSocket
		if !data.nil?
			self.text = data[0]
			self.addr_family = data[1][0]
			self.src_port = data[1][1]
			self.src_addr = data[1][2]
		end
	end

	def to_s
		self.text
	end
end

