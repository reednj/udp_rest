#!/usr/bin/env ruby

require 'json'
require 'time'
require './lib/udp_rest'

port = 7890
puts "listening on 0.0.0.0:#{port}..."

UHTTPServer.new(:port => port) do |s|
	puts s.port
	
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

end