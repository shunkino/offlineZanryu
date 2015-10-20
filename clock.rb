require 'clockwork'
require 'open3'

def makePdf
		out, err, status = Open3.capture3("ruby pdfGen.rb")
		puts out
		puts err
end
def printPdf
	out, err, status = Open3.capture3("lpr -P _203_178_128_18 overnight-" << Date.today.to_s << ".pdf")
		puts out
		puts err
		puts status
end

class Print 
	def call
		makePdf
		printPdf
	end
end

module Clockwork
	handler do |job|
		job.call
	end

	every(1.day, Print.new, at: '23:30')
	# every(5.minutes, Print.new)
end
