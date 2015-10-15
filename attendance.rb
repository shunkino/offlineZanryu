require "pasori"

def getStudentNo(pasori)
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
end


studentIDs = {}
puts "Automatic Zanryu Paper Printer."
Pasori.open {|pasori|
	loop do
		studentID = getStudentNo(pasori).chomp
		#if studentIDs.key?(studentID)
		if studentIDs[studentID]
			f = open("participation.txt", "a+") 
			print "次の人"
			gets
			studentId = getStudentNo(pasori)
			studentIDs[studentID] = true	
			unless chohuku(f, studentId)
				f.puts studentId 
			end
			f.close
		end	
	end

}
