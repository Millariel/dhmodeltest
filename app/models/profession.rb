class Profession < ActiveRecord::Base
	has_many :doctors

	scope :get_by_code, -> (code) do
		where("professions.code = ?", code)
	end
end