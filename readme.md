# REST over UDP

 - Most REST requets are very small
 - it should be possible to implement a simple version of HTTP that can run over UDP in order to make REST requets
 - we have implemented that
  - the max packet size is 512 bytes
 - This gem makes it easy to create servers and clients for udp-rest
 - it also contains a curl-like command line app
 - obviously this is not going to work from any browser, but it can be useful for simple command line apps.

## Try it out

There is a udp rest server running on uhttp.reednj.com. You can make requests to it by installing the gem.

		gem install udp_rest
		udp-rest uhttp.reednj.com

		<SCREEN SHOT OF CONSOLE>

## Server

Use this gem to create sinatra style servers to respond to requests.

		<CODE>

## Client

## Benchmarks

 - do some testing of the latency here, see if it really is faster. Pick a few different servers

## Other Points

 - encoding is always UTF-8
 - the max request and response size is 512 bytes
