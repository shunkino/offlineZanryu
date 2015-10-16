require "pasori"
require 'rubygems'
require 'clockwork'
include Clockwork
require 'sqlite3'
include SQLite3

# SQL接続
db = Database.new("zanryu.db")
peopleSql =<<SQL
CREATE TABLE IF NOT EXISTS overnightPeople(
studentID int NOT NULL,
stayDate text 
);
SQL

infoSql =<<INFOSQL
CREATE TABLE IF NOT EXISTS information(
studentID int NOT NULL,
fuculty text,
year text,
name text,
course text,
facultyMember text,
place text,
emergencyName text,
emergencyRelation text,
emergencyPhone text
);
INFOSQL

db.execute(peopleSql)
db.execute(infoSql)

def getStudentNo(pasori)
	begin
		pasori.felica_polling(-31279) {|felica|
			felica_area = felica.service[9]
			stNo = felica.read(felica_area, 1, 0)[0..7]
			return stNo 
		}
	rescue 
		puts "Cannot read student ID card."
		retry
	end
end

def insertStudentNum(db, studentID)
	date = Date.today
	insertSql = "INSERT INTO overnightPeople (studentID, stayDate) VALUES (#{studentID.to_s}, '#{date}');"
	db.execute(insertSql)
	puts "SUCCESS!"
	puts insertSql
end

studentIDs = {}
puts "Automatic Zanryu Paper Printer."
Pasori.open {|pasori|
	loop do
		# 時間を判定する
		print "Press Enter to read next card."
		gets
		studentID = getStudentNo(pasori).chomp
		unless studentIDs[studentID]
			# 未登録だった時
			studentIDs[studentID] = true	
			insertStudentNum(db, studentID)
		else
			# 重複していた場合
			puts "You have already registered." 
		end
	end	
}
