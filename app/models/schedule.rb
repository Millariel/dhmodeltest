class Schedule < ActiveRecord::Base
	belongs_to :job
	
	scope :contracted_jobs, -> (user) do
		user.actable.jobs.joins(:job_doctors).where("job_doctors.doctor_id = ?", user.actable.id).where("job_doctors.matched = ?", true)
	end

	scope :job_schedule, -> (job, startDate, endDate) do
		joins("INNER JOIN jobs on jobs.id = schedules.job_id").where("jobs.id = ?", job.id).where("schedules.start_time BETWEEN ? AND ? OR schedules.end_time BETWEEN ? AND ?", startDate, endDate, startDate, endDate)
	end
end