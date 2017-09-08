class Specialty < ActiveRecord::Base
	has_many :jobs
	has_many :doctor_specialties
	has_many :doctors, :through => :doctor_specialties

	scope :get_by_code, -> (code) do
		where("specialties.code = ?", code)
	end
end