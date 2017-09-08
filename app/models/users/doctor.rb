class Doctor < ActiveRecord::Base
	attr_accessor :score

	acts_as :user
	
	has_many :doctor_specialties
	has_many :specialties, :through => :doctor_specialties
	has_many :doctor_professions
	has_many :professions, :through => :doctor_professions

	has_many :contracts

	has_many :availabilities
	belongs_to :default_availability

	has_many :job_doctors
	has_many :jobs, :through => :job_doctors

	has_many :doctor_jobs
	has_many :jobs, :through => :doctor_jobs

	geocoded_by :address
	after_validation :geocode

	scope :liked_doctors, -> (job) do
		#Doctor.joins("INNER JOIN doctor_jobs ON doctor_jobs.doctor_id = doctor.id").where("doctor_jobs.job_id = ?", job)
		select("doctors.*").select("doctor_jobs.updated_at as updated").joins(:doctor_jobs).where("doctor_jobs.job_id = ?", job)
	end

	scope :nominated_doctors, -> (job) do
		select("doctors.*").select("job_doctors.updated_at as updated").joins(:job_doctors).where("job_doctors.job_id = ?", job)
	end

	scope :scoreplus, -> (amt) do
		#Doctor.joins("INNER JOIN rating_caches ON doctor.id = rating_caches.cacheable_id").where("rating_caches.\"avg\" > ?", amt)
		#Doctor.joins("INNER JOIN users ON doctor.id = users.actable_id").joins("INNER JOIN rating_caches ON users.id = rating_caches.cacheable_id").where("rating_caches.\"avg\" > ?", amt)
		Doctor.joins("INNER JOIN users ON users.actable_id = doctors.id INNER JOIN rating_caches ON users.id = rating_caches.cacheable_id").where("rating_caches.\"avg\" > ?", amt)
		#Doctor.joins(:scoreplus)
	end

	scope :namefilter, -> (spec) do
		spec = "%" + spec + "%"
		where("LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?", spec.downcase, spec.downcase)
	end

	scope :specfilter, -> (spec) do
		#Doctor.joins("INNER JOIN specialties ON users.specialty_id = specialties.id").where("specialties.id = ?", spec)
		puts "Specfilter"
		#Doctor.joins(:specialties).where(:specialty_id => spec.specialty_id)
		Doctor.joins("INNER JOIN doctor_specialties on doctor_specialties.doctor_id = doctors.id INNER join specialties on doctor_specialties.specialty_id = specialties.id").where("specialties.id = ?", spec)
	end

	scope :professionfilter, -> (profession) do
		#Doctor.joins("INNER JOIN professions ON users.profession_id = professions.id").where("titles.id = ?", profession)
		#Doctor.joins("INNER JOIN profession ON users.profession_id = professions.id").where("titles.id = ?", profession)
		Doctor.joins("INNER JOIN doctor_professions ON doctors.id = doctor_professions.doctor_id INNER JOIN professions ON doctor_professions.profession_id = professions.id").where("professions.id = ?", profession)
	end

	scope :with_relevance, -> (job) do
		connection = ActiveRecord::Base.connection

		sql = "select doc.score, doctors.* from
			(select sum(length(replace(ftime::text, '0', '')))::decimal/(count(total)*3) as score, total.id from
			(select d, COALESCE(times, dtimes) as ftime, * from
				(select d::date, docout.*, extract(isodow from d::date),
					(case extract(isodow from d::date)
						when 1 then (
					        select monday from default_availabilities
					        inner join doctors on doctors.default_availability_id = default_availabilities.id
					        where doctors.id = docout.id)
					 	when 2 then (
					        select tuesday from default_availabilities
					        inner join doctors on doctors.default_availability_id = default_availabilities.id
					        where doctors.id = docout.id)
					  	when 3 then (
					        select wednesday from default_availabilities
					        inner join doctors on doctors.default_availability_id = default_availabilities.id
					        where doctors.id = docout.id)
					  	when 4 then (
					        select thursday from default_availabilities
					        inner join doctors on doctors.default_availability_id = default_availabilities.id
					        where doctors.id = docout.id)
					  	when 5 then (
					        select friday from default_availabilities
					        inner join doctors on doctors.default_availability_id = default_availabilities.id
					        where doctors.id = docout.id)
					  	when 6 then (
					        select saturday from default_availabilities
					        inner join doctors on doctors.default_availability_id = default_availabilities.id
					        where doctors.id = docout.id)
					  	when 7 then (
					        select sunday from default_availabilities
					        inner join doctors on doctors.default_availability_id = default_availabilities.id
					        where doctors.id = docout.id)
					end ) as dtimes, times, doctor_id
				from generate_series(
				    (select start_date from jobs where id = " + job.id.to_s + "),
				    (select end_date from jobs where id = " + job.id.to_s + "),
				'1 day') date(d)
			left outer join availabilities on d::date = availabilities.date
            inner join doctors as docout on availabilities.doctor_id = docout.id
			order by d::date) as datas) as total
            group by total.id) as doc
            inner join doctors on doctors.id = doc.id"

		#Doctor.find_by_sql(sql)
		Doctor.connection.select_all(sql).to_hash
	end

	def to_s
		"Doctor(specialties: #{@specialties.inspect})"
	end

	def address
		self.building_num.to_s + " " + self.primary_address.to_s + " " + self.secondary_address.to_s + " " + self.tertiary_address.to_s + " " + self.city.to_s + " " + self.postal_code.to_s + " " + self.country.to_s
	end
end