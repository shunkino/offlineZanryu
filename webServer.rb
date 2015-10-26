# -*- encoding: UTF-8 -*-
require 'webrick'
include WEBrick
require 'sqlite3'
include SQLite3

db = Database.new("zanryu.db")
# db接続
infoSql =<<INFOSQL
CREATE TABLE IF NOT EXISTS information(
studentID INTEGER PRIMARY KEY, 
faculty text,
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
db.execute(infoSql)

def makePreparedQuery(userQuery, mode)
	columnList = [
		"studentID",
		"faculty",
		"year",
		"name",
		"course",
		"facultyMember",
		"place",
		"emergencyName",
		"emergencyRelation",
		"emergencyPhone"
	]
	case mode
	when 0 then
		# insertだった時
		queryStr = "INSERT INTO information ("
		columnList.each{|columnName|
			unless columnName == columnList.last 
				# 最終行以外の場合
				queryStr << "#{columnName}, "
			else
				# 最終行の場合
				queryStr << "#{columnName}) VALUES ("
			end
		}
		columnList.each{|columnName|
			unless columnName == columnList.last 
				# 最終行以外の場合
				queryStr << ":#{columnName}, "
			else
				# 最終行の場合
				queryStr << ":#{columnName}) " 
			end
		}
	when 1 then
		# updateだった時
		queryStr = "UPDATE information SET "
		columnList.each{|columnName|
			unless columnName == columnList.last 
				queryStr << "#{columnName}="
				queryStr << ":#{columnName}, "
			else
				queryStr << "#{columnName}="
				queryStr << ":#{columnName} "
			end
		}
		queryStr << "WHERE studentID=:studentID"
	end
	return queryStr
end

def isAlreadyInDB (studentID, date, db)
	response = db.execute("SELECT * FROM overnightPeople WHERE zanryuStudentId=:studentID AND stayDate=:date", studentID.to_s, date.to_s)
	if response.empty?
		return false
	else
		return true
	end
end

def studentNumberValidation(studentID)
	if /^([0-9]{8})/ =~ studentID
		return true
	else
		return false
	end
end

s = HTTPServer.new(
	:Port => 3000,
	:DocumentRoot => File.join(Dir::pwd, "public_html")
)

class PostInfo < WEBrick::HTTPServlet::AbstractServlet
	def do_POST(req, res)
		db = Database.new("zanryu.db")
		userQuery = req.query
		# puts userQuery
		if studentNumberValidation(userQuery["studentID"])
			preparedStr = makePreparedQuery(userQuery, 0)	
			sth = db.prepare(preparedStr)
			userQuery.each{|key, value|
				# ループを回してbindingをしてからexecute
				if key == "studentID"
					sth.bind_param("#{key}", value.to_i)
				else	
					sth.bind_param("#{key}", value) 
				end
			}
			begin
				sth.execute
				res.body += "データの登録に成功しました。\n"
			rescue
				res.body += "データの登録に失敗しました。登録済みで無いか確認して時間がたってから再トライしてください。\n"
				res.body += $!.to_s 
			end
		else
			res.body = "学籍番号を確認してやり直してください。"
		end
	end
end

class UpdateInfo < WEBrick::HTTPServlet::AbstractServlet
	def do_POST(req, res)
		db = Database.new("zanryu.db")
		userQuery = req.query
		if studentNumberValidation(userQuery["studentID"])
			preparedStr = makePreparedQuery(userQuery, 1)	
			sth = db.prepare(preparedStr)
			userQuery.each{|key, value|
				# ループを回してbindingをしてからexecute
				if key == "studentID"
					sth.bind_param("#{key}", value.to_i)
				else	
					sth.bind_param("#{key}", value) 
				end
			}
			begin
				sth.execute
				res.body += "データの更新に成功しました。\n"
			rescue
				res.body += "データの登録に失敗しました。登録済みで無いか確認して時間がたってから再トライしてください。\n"
				res.body += $!.to_s 
			end
		else
			res.body = "学籍番号を確認してやり直してください。"
		end
	end
end

class ZanryuTouroku< WEBrick::HTTPServlet::AbstractServlet
	def do_POST(req, res)
		today = Date.today.to_s
		db = Database.new("zanryu.db")
		userQuery = req.query
		if studentNumberValidation(userQuery["studentID"])
			unless isAlreadyInDB(userQuery["studentID"], today, db)
				# 重複がなかった場合
				db.execute("INSERT INTO overnightPeople (zanryuStudentID, stayDate) VALUES (:studentID, :date);", userQuery["studentID"], today)
				res.body = "登録完了しました。"
			else
				# 重複があった場合
				puts "You have already registered today." 
				res.body = "既に登録済みです。"
			end
		else
			res.body = "学籍番号を確認してやり直してください。"
		end
	end
end

s.mount('/register', PostInfo)
s.mount('/update', UpdateInfo)
s.mount('/offer', ZanryuTouroku)

trap("INT") {
	s.shutdown
}
s.start
