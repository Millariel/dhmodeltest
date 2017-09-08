class DoctorJob < ApplicationRecord
	belongs_to :doctor
	belongs_to :job
end
