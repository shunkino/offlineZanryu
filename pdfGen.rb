require 'thinreports'
require 'date'
require 'sqlite3'
include SQLite3
todayDate = Date.today
report = Thinreports::Report.new layout:'Overnight_Study'
db = Database.new("zanryu.db")
db.results_as_hash = true

dateConverter = {"Monday" => "月", "Tuesday" => "火", "Wednesday" => "水", "Thursday" => "木", "Friday" => "金", "Saturday" => "土", "Sunday" => "日"}

#infos = db.execute("SELECT * FROM information INNER JOIN overnightPeople ON overnightPeople.studentID=information.studentID WHERE stayDate=:dateToday ", :dateToday => todayDate.to_s)
infos = db.execute("SELECT * FROM information INNER JOIN overnightPeople ON overnightPeople.zanryuStudentID=information.studentID WHERE stayDate=:dateToday ", :dateToday => todayDate.to_s)

unless infos.empty?
	infos.each_slice(4) do |information|
		report.start_new_page do |page|
			information.each_with_index do |info, i|
				dateSplit = info["stayDate"].split("-")
				page.item("year#" << i.to_s).value(dateSplit[0])
				page.item("month#" << i.to_s).value(dateSplit[1])
				page.item("date#" << i.to_s).value(dateSplit[2])
				page.item("day#" << i.to_s).value(dateConverter[todayDate.strftime("%A")])
				page.item("studentID#" << i.to_s).value(info["studentID"])
				page.item("faculty#" << i.to_s).value(info["faculty"].force_encoding("UTF-8"))
				page.item("grade#" << i.to_s).value(info["year"].force_encoding("UTF-8"))
				page.item("name#" << i.to_s).value(info["name"].force_encoding("UTF-8"))
				page.item("course#" << i.to_s).value(info["course"].force_encoding("UTF-8"))
				page.item("member#" << i.to_s).value(info["facultyMember"].force_encoding("UTF-8"))
				page.item("facility#" << i.to_s).value(info["place"].force_encoding("UTF-8"))
				page.item("emergencyName#" << i.to_s).value(info["emergencyName"].force_encoding("UTF-8"))
				page.item("emergencyRelation#" << i.to_s).value(info["emergencyRelation"].force_encoding("UTF-8"))
				page.item("emergencyPhone#" << i.to_s).value(info["emergencyPhone"].force_encoding("UTF-8"))
			end
		end
	end

	report.generate(filename: "overnight-#{todayDate.to_s}.pdf")
	puts "Done!"
else
	puts "Nobody Zanryu today."
end
