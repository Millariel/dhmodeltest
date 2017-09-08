class Department < ActiveRecord::Base
	has_many :department_employers
	has_many :employers, :through => :department_employers
	has_many :jobs
	
	belongs_to :hospital
end