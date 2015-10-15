require "pasori"

def getStudentNo
	Pasori.open {|pasori|
		begin
			pasori.felica_polling(-31279) {|felica|
				felica_area = felica.service[9]
				stNo = felica.read(felica_area, 1, 0)[0..7]
				puts stNo
				return stNo 
			}
		rescue #=> ex
			puts "学生証が読み取れません。"
			# puts ex.message
			retry
		end
	}
end

def chohuku(file, stNumber)
	file.each {|line|
		if line.chomp == stNumber.chomp 
			puts "重複した番号です"
			return true	
		end
	}
	return false
end

puts "Automatic Zanryu Paper Printer."
loop do
	f = open("participation.txt", "a+") 
	studentId = getStudentNo
	if !chohuku(f, studentId)
		f.puts studentId 
	end
	f.close
end