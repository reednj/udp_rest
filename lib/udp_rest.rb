require 'uri'
require 'socket'

require 'worker_thread'
require "udp_rest/version"
require "udp_rest/udp"
require "udp_rest/uhttp"

module UDPRest
	class Server
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

		def udp_server
			@udp
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
						request = UHTTPRequest.from_packet packet
					rescue => e
						puts "400 BAD REQUEST: #{e}"
						response = respond(400, 'Bad Request')
					end
				end

				if response.nil?
					begin
						response = route_request(request)

						if response.to_s.bytesize > udp_server.max_packet_size
							raise "response too long (#{response.to_s.bytesize} bytes)"
						end
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

	class Client
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

		def send_text(text)
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
			client = self.new(uri.host, uri.port || 80)
			
			req = UHTTPRequest.new
			req.req_method = req_method
			req.path = uri.path

			packet = client.send_text(req.to_s)
			UHTTPResponse.parse(packet.text)
		end

		def self.get(url)
			self.uhttp('GET', url)
		end
		
	end

end