#!/usr/bin/env ruby

require 'socket'
require 'colorize'
require './lib/udp_rest'

class App
	def main
		path = ARGV.last || '/hello'
		r = UDPRestClient.get("uhttp://127.0.0.1:7890#{path}")
		print_response(r)		
	end

	def print_response(r)
		puts r.ok? ? r.status_line.green : r.status_line.red
		puts ''
		puts r.text
	end
end

App.new.main
