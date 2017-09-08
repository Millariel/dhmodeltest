class Employer < ActiveRecord::Base
	belongs_to :hospital
	has_many :department_employers
	has_many :departments, :through => :department_employers
	acts_as :user
	has_many :jobs
end