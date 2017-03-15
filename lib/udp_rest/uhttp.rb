require 'uri'
require 'cgi'
require 'socket'

module UDPRest

    class UDPRest::UHTTPRequest
        attr_accessor :req_method
        attr_accessor :path
        attr_accessor :query
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
            req.protocol = data[2]
            
            path_data = data[1].split('?')
            req.path = path_data[0]
            req.query = path_data[1] || '' if path_data.length > 1

            return req
        end

        def to_s
            self.path = '/' if path.nil? || path.empty?
            "#{req_method} #{path_and_query} #{protocol}\n"
        end

        def path_and_query
            if query.nil? || query.strip == ''
                path
            else
                path + '?' + query
            end
        end

        def params
            return {} if query.nil? || query.strip == ''
            
            if @params.nil?
                p = CGI.parse(self.query)
                p.each {|k,v| p[k] = v.first }
                @params = p
            end

            @params
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