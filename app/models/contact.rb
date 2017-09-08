class Contact < ApplicationRecord
	belongs_to :hospital
	belongs_to :user

	has_many :requesters, class_name: "Job"
	has_many :approvers, class_name: "Job"
	has_many :financers, class_name: "Job"
	has_many :invoicers, class_name: "Job"
	has_many :verifiers, class_name: "Job"
end
