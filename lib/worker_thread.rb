# Helper for running threads in the background, with a timeout
# and error logging.
#
# Example:
#
#    WorkerThread.new.start :timeout => 5.minutes do 
#        # long running task here...
#        sleep 10.0
#    end
#
class WorkerThread

	def start(options = nil)
		raise 'background_task needs a block' unless block_given?

		options ||= {}

		worker = Thread.new do
			begin
				yield
			rescue => e
				$stderr.puts "#{Time.now}\t#{e.class.to_s}\t#{e.message}\n"
				raise e
			end
		end

		# if the user set a timeout then we need a thread to monitor
		# the worker to make sure it doesn't run too long
		if !options[:timeout].nil?
			Thread.new do
				sleep options[:timeout].to_f
				
				if worker.status != false
					$stderr.puts "#{Time.now}\tbackground_task thread timeout\n"
					worker.kill
				end
			end
		end

		worker
	end
end