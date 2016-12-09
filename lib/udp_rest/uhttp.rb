require 'uri'
require 'socket'

module UDPRest

    class UDPRest::UHTTPRequest
        attr_accessor :req_method
        attr_accessor :path
        attr_accessor :protocol

        def initialize
            self.req_method = 'GET'
            self.protocol = 'UHTTP/1.0'
            self.path ='/'
        end

        def self.from_packet(p)
            text = p
            text = p.text if text.is_a? UDPPacket
            data = text.split(' ')

            raise 'invalid request' if data.length != 3
            req = self.new
            req.req_method = data[0]
            req.path = data[1]
            req.protocol = data[2]
            return req
        end

        def to_s
            self.path = '/' if path.nil? || path.empty?
            "#{req_method} #{path} #{protocol}\n"
        end
    end

    class UDPRest::UHTTPResponse
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

end