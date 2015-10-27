# -*- encoding: UTF-8 -*-
require "pasori"
require 'rubygems'
require 'clockwork'
include Clockwork
require 'sqlite3'
include SQLite3

def init 
	createDB
end

def createDB
	# SQL接続
	db = Database.new("zanryu.db")
	peopleSql =<<SQL
CREATE TABLE IF NOT EXISTS overnightPeople(
id INTEGER PRIMARY KEY AUTOINCREMENT,
zanryuStudentID INTEGER NOT NULL,
stayDate text 
);
SQL
	db.execute(peopleSql)
	db.close
end

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

def isAlreadyInDB (studentID, date, db)
	response = db.execute("SELECT * FROM overnightPeople WHERE zanryuStudentId=:studentID AND stayDate=:date", studentID.to_s, date.to_s)
	if response.empty?
		return false
	else
		return true
	end
end

def insertStudentNum(studentID)
	db = Database.new("zanryu.db")
	# 日にちを取得("YYYY-MM-DD")
	date = Date.today
	unless isAlreadyInDB(studentID, date, db)
		# 重複がなかった場合
		puts "Data doesn't exists"
		db.execute("INSERT INTO overnightPeople (zanryuStudentID, stayDate) VALUES (:studentID, :date);", studentID, date.to_s)
		puts "SUCCESS!"
	else
		# 重複があった場合
		puts "You have already registered today." 
	end
	db.close
end

# 初期化処理
init
puts "Automatic Zanryu Paper Printer."
Pasori.open {|pasori|
	loop do
		print "Press Enter to read next card."
		gets
		studentID = getStudentNo(pasori).chomp.encode('ascii-8bit')
		insertStudentNum(studentID)
	end	
}

Signal.trap(:INT) {|signo|
	# 終了時の処理
	db.close
}
