require 'sqlite3'
include SQLite3
db = Database.new("zanryu.db")
countingQuery = "select zanryuStudentID from overnightPeople where stayDate='2015-10-29'"

studentIDs = {}
i = 0
db.execute(countingQuery) do |res|
	unless studentIDs[res]
		studentIDs[res] = true
		puts res
		i += 1	
	else
		puts "重複しています"
	end
end
puts "合計の参加者は#{i}人です"
