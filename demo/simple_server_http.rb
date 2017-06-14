#!/usr/bin/env ruby

require 'sinatra'
require 'json'
require 'time'

req_count = 0

get '/' do
    "Hello, World!\nVisit http://github.com/reednj/udp_rest for more info"
end

get '/hello' do
    'hello'
end

post '/time' do
    Time.now.to_s
end

get '/time/unix' do
    Time.now.to_i.to_s
end

get '/time/iso' do
    Time.now.iso8601
end

get '/count' do
    req_count += 1
    req_count.to_s
end

get '/too_long' do
    'a' * 600
end
