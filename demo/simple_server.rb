#!/usr/bin/env ruby

require 'json'
require 'time'
require './lib/udp_rest'

req_count = 0
port = (ARGV.last || 7890).to_i
puts "listening on 0.0.0.0:#{port}..."

UHTTPServer.new(:port => port) do |s|
	s.get '/' do
		"Hello, World!\nVisit http://github.com/reednj/udp_rest for more info"
	end

	s.get '/hello' do
		'hello'
	end

	s.post '/time' do
		Time.now.to_s
	end

	s.get '/time/unix' do
		Time.now.to_i
	end

	s.get '/time/iso' do
		Time.now.iso8601
	end

	s.get '/count' do
		req_count += 1
		req_count.to_s
	end

	s.get '/too_long' do
		'a' * 600
	end

end