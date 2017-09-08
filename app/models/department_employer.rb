class DepartmentEmployer < ApplicationRecord
	belongs_to :department
	belongs_to :employer
end
