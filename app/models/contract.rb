	class Contract < ActiveRecord::Base
	belongs_to :doctor
	#belongs_to :employer

	belongs_to :job

	belongs_to :requester, class_name: "Contact"
	belongs_to :approver, class_name: "Contact"
	belongs_to :financer, class_name: "Contact"
	belongs_to :invoicer, class_name: "Contact"
	belongs_to :verifier, class_name: "Contact"


	scope :involving, -> (user) do
		joins("inner join jobs on contracts.job_id = jobs.id").where("contracts.doctor_id = ? OR jobs.employer_id = ?", user.id, user.id)
	end

	scope :involving_upcoming, -> (user, time) do
		#where("(contracts.doctor_id = ? OR jobs.employer_id = ?) AND jobs.end_date > ?", user.id, user.id, time)
	end

	scope :involving_past, -> (user, time) do
		#where("(jobs.doctor_id = ? OR jobs.employer_id = ?) AND jobs.end_date < ?", user.id, user.id, time)
	end

	scope :get, -> (contract) do
		where("contracts.id = ?", contract).first()
	end
end