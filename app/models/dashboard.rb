class Dashboard < ApplicationRecord
  	extend Geocoder::Model::ActiveRecord

	scope :available_jobs, -> (user) do
		user.actable.jobs.joins(:job_doctors).where("job_doctors.matched is null")
	end

	scope :respond, -> (job, doctor, set) do

		puts job
		puts doctor
		puts set
		jd = JobDoctor.where(job_id: job, doctor_id: doctor).first()

		if set
			# added to contracts
			# create new contract
			c = Contract.create!(
				doctor_id: doctor,
				job_id: job
			)
			jd.matched = true
			jd.save!
		else
			# deleted from jobs list
			puts "delete"
			jd.matched = false
			jd.save!
		end
	end

	scope :accepted_jobs, -> (user) do
		user.actable.jobs.joins(:job_doctors).where("job_doctors.matched = ?", true)
	end

	scope :declined_jobs, -> (user) do
		user.actable.jobs.joins(:job_doctors).where("job_doctors.matched = ?", false)
	end

	#def self.sorted_by_distance
		#self.sort_by({|job| job.distance(user)})
		#puts Current.user
	#end
end
