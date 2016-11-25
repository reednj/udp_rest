#!/usr/bin/env ruby

require 'json'
require 'time'
require './lib/udp_rest'

@server = UHTTPServer.new(:port => 7890)

def get(url, &block)
	@server.get(url, &block)
end

def post(url, &block)
	@server.post(url, &block)
end

get '/hello' do
	'hello, world!'
end
