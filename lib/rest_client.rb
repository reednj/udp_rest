#!/usr/bin/env ruby

require 'socket'
require 'colorize'
require 'trollop'
require 'udp_rest'

class App
	def main
		valid_methods = ['GET', 'PUT', 'POST', 'DELETE']
		@opts = Trollop::options do
			version "UDP RestClient (c) 2016 @reednj"
			banner "Usage: udp-rest [options] <url>"
			opt :method, "HTTP Method (GET, POST etc)", :type => :string, :default => 'GET'
			opt :content, "Show the response content only (no headers)", :default => false
		end

		Trollop::educate if ARGV.empty?
		url = ARGV.last
		url = "uhttp://" + url unless url.start_with? 'uhttp://'

		begin
			if !valid_methods.include? @opts[:method].upcase
				raise "Invalid REST method '#{@opts[:method]}'"
			end

			r = UDPRest::UDPRestClient.uhttp(@opts[:method], url)
			print_response(r)
		rescue => e
			puts e
		end
	end

	def print_response(r)
		unless @opts[:content]
			puts r.ok? ? r.status_line.green : r.status_line.red
			puts ''
		end

		puts r.text
	end
end
