class DefaultAvailability < ApplicationRecord
	has_one :doctor

	scope :involving, -> (doctor) do
		joins(:doctor).where("doctors.id = ?", doctor.id)
	end
end
