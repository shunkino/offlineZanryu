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


studentIDs = {}
puts "Automatic Zanryu Paper Printer."
f = open("participation.txt", "a+") 
loop do
	studentID = getStudentNo().chomp
	if defined? studentIDs[studentID] 
		puts "重複です。" 
	else
		puts studentID
		studentIDs[studentID] = true	
	end

end
f.puts studentId 
f.close
