require 'clockwork'

class ClockJob
	def call
		puts "test"
	end
end

module Clockwork
	handler do |job|
		job.call
	end

	every(2.seconds, ClockJob.new)
end

