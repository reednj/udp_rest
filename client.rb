#!/usr/bin/env ruby

require 'socket'
require 'colorize'
require './lib/udp_rest'

class App
	def main
		url = ARGV.last || '/hello'
		url = "uhttp://" + url unless url.start_with? 'uhttp'

		begin
			r = UDPRestClient.get(url)
			print_response(r)
		rescue => e
			puts e
		end
	end

	def print_response(r)
		puts r.ok? ? r.status_line.green : r.status_line.red
		puts ''
		puts r.text
	end
end
