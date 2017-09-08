class Job < ApplicationRecord
  	extend Geocoder::Model::ActiveRecord

	attr_accessor :distance
	attr_accessor :score

	belongs_to :employer
	belongs_to :department
	belongs_to :specialty
	
	has_one :contract

	#has_one :job_schedules
	has_many :schedules, :through => :job_schedules

	has_many :job_doctors
	has_many :doctors, :through => :job_doctors

	has_many :doctor_jobs
	has_many :doctors, :through => :doctor_jobs, as: "liked"

	geocoded_by :address

	scope :involving, -> (user) do
		where("jobs.employer_id = ?", user.id)
	end

	# scope :involving_upcoming, -> (user, time) do
	# 	#where("(contracts.doctor_id = ? OR jobs.employer_id = ?) AND jobs.end_date > ?", user.id, user.id, time)
	# end

	# scope :involving_past, -> (user, time) do
	# 	#where("(jobs.doctor_id = ? OR jobs.employer_id = ?) AND jobs.end_date < ?", user.id, user.id, time)
	# end

	scope :get, -> (contract) do
		where("contracts.id = ?", contract).first()
	end

	scope :free, -> do
		#joins(:contract).where("contracts.id is null")
		joins("LEFT JOIN contracts on contracts.job_id = jobs.id").where("contracts.id is null").joins("INNER JOIN employers on jobs.employer_id = employers.id INNER JOIN hospitals on employers.hospital_id = hospitals.id")
	end


	# hospital_jobs scopes
	scope :open_jobs, -> (user) do 
		joins("LEFT JOIN contracts on contracts.job_id = jobs.id").where("contracts.id is null").where("jobs.employer_id = ?", user.id)
	end

	scope :contracted_jobs, -> (user) do
		joins("LEFT JOIN contracts on contracts.job_id = jobs.id").where("contracts.id is not null").where("jobs.employer_id = ?", user.id)
	end

	scope :expired, -> (user) do # job open and start_date past current date
		open_jobs(user).where("jobs.end_date < ?", DateTime.now)
	end

	scope :active , -> (user) do # contracted. start_date before current date and end date past current date
		contracted_jobs(user).where("jobs.start_date < ? and jobs.end_date > ?", DateTime.now, DateTime.now)
	end

	scope :completed, -> (user) do # job contracted and end_date before current date
		contracted_jobs(user).where("jobs.end_date < ?", DateTime.now)
	end

	scope :liked_by, -> (user) do
		joins("INNER JOIN doctor_jobs on doctor_jobs.job_id = jobs.id INNER JOIN doctors on doctor_jobs.doctor_id = doctors.id").where("doctors.id = ?", user.actable.id)
	end
	# end

	def distance(target)
		#puts user.inspect
		#puts employer.hospital.inspect
		if employer.hospital.longitude
			employer.hospital.distance_to(target).round(2)
		else
			"??"
		end
	end

	def relevance(doctor)
		self.score = ActiveRecord::Base.connection.exec_query("select sum(length(replace(ftime::text, '0', '')))::decimal/(count(total)*3) as score from
			(select d, COALESCE(times, dtimes) as ftime from
			(select d::date, extract(isodow from d::date),
			(case extract(isodow from d::date)
				when 1 then (
			        select monday from default_availabilities
			        inner join doctors on doctors.default_availability_id = default_availabilities.id
			        where doctors.id = " + doctor.id.to_s + ")
			 	when 2 then (
			        select tuesday from default_availabilities
			        inner join doctors on doctors.default_availability_id = default_availabilities.id
			        where doctors.id = " + doctor.id.to_s + ")
			  	when 3 then (
			        select wednesday from default_availabilities
			        inner join doctors on doctors.default_availability_id = default_availabilities.id
			        where doctors.id = " + doctor.id.to_s + ")
			  	when 4 then (
			        select thursday from default_availabilities
			        inner join doctors on doctors.default_availability_id = default_availabilities.id
			        where doctors.id = " + doctor.id.to_s + ")
			  	when 5 then (
			        select friday from default_availabilities
			        inner join doctors on doctors.default_availability_id = default_availabilities.id
			        where doctors.id = " + doctor.id.to_s + ")
			  	when 6 then (
			        select saturday from default_availabilities
			        inner join doctors on doctors.default_availability_id = default_availabilities.id
			        where doctors.id = " + doctor.id.to_s + ")
			  	when 7 then (
			        select sunday from default_availabilities
			        inner join doctors on doctors.default_availability_id = default_availabilities.id
			        where doctors.id = " + doctor.id.to_s + ")
			end ) as dtimes, times, doctor_id
			from generate_series(
			    (select start_date from jobs where id = " + self.id.to_s + "),
			    (select end_date from jobs where id = " + self.id.to_s + "),
			'1 day') date(d)
			left outer join availabilities on d::date = availabilities.date and doctor_id = " + doctor.id.to_s + "
			order by d::date) as datas) as total").to_hash
	end

	scope :ordered_by_distance, -> do
		joins("inner join employers as e on jobs.employer_id = e.id inner join hospitals as h on e.hospital_id = h.id")
	end

  	scope :with_distance_to, -> (point) {
  		#puts point.inspect
  		select("#{table_name}.*").select("(3958.755864232 * 2 * ASIN(SQRT(POWER(SIN((53.3210859 - hospitals.latitude) * PI() / 180 / 2), 2) + COS(53.3210859 * PI() / 180) * COS(hospitals.latitude * PI() / 180) * POWER(SIN((6.854499 - hospitals.longitude) * PI() / 180 / 2), 2)))) as distance").joins("inner join employers on jobs.employer_id = employers.id inner join hospitals on employers.hospital_id = hospitals.id")
  	}

  	scope :with_relevance, -> do 
  		#select("#{table_name}.*").select(job.relevance(doctor))

  		# BRAYDON
		# algorithm implementation-
		# 1: construct sql view of user availabilities
		# 2: from jobs.start_date to jobs.end_date
		# 	2a: if day exists in doctor.availabilities
		# 		2ai: use that availability
		# 	2b: else
		# 		2bi: use doctor.default_availability(day)
		# 3: sum up columns	
		# 	3a: each day's availability represented as a number
		# 		(0-3: sum number of 1s in day bitstring)
		# 4: select the summation and divide by jobs.duration*3
		
	end

	def liked_by(user)
		#self.doctors.include?(user.actable)
	end

	scope :toggle_like, -> (user, jobid) do
		puts "ghfkjohksofpghoisjighjsiogfdhiosfghj"
		puts jobid
		job = jobid
		#if job.liked_by(user)
		#	job.applied.push(user.actable)
		#else
		#	job.applied.delete(user.actable)
		#end
		#job.save
	end

	def address
		self.employer.hospital.building_num.to_s + " " + self.employer.hospital.primary_address.to_s + " " + self.employer.hospital.secondary_address.to_s + " " + self.employer.hospital.tertiary_address.to_s + " " + self.employer.hospital.city.to_s + " " + self.employer.hospital.postal_code.to_s + " " + self.employer.hospital.country.to_s
	end
end
