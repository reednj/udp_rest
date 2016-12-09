require 'uri'
require 'socket'

module UDPRest

    class UDPRest::UDPServer
        attr_accessor :socket

        def initialize
            @max_packet_size = 512
            self.socket = UDPSocket.new
        end

        def max_packet_size
            @max_packet_size
        end

        def listen(port, options = {})
            @port = port.to_i
            @host = options[:host] || '0.0.0.0'
            self.socket.bind(@host, @port)

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
            raise "message too long (max is #{@max_packet_size}b, was #{text.bytesize})" if text.bytesize > @max_packet_size
            self.socket.send(text, 0, host, port)
        end

        def host
            @host
        end

        def port
            @port
        end

    end

    class UDPRest::UDPPacket
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

end