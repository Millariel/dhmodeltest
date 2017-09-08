class JobDoctor < ApplicationRecord
	belongs_to :job
	belongs_to :doctor
end
