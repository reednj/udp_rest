#!/usr/bin/env ruby

require 'json'
require 'time'
require './lib/udp_rest'

class App
	def main
		c = 0
		puts 'listening...'
		
		UHTTPServer.new(:port => 7890) do |s|
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
				c += 1
				c.to_s
			end

		end

	end
end


App.new.main
