class Hospital < ActiveRecord::Base
	extend Geocoder::Model::ActiveRecord

	has_many :employers
	has_many :departments

	has_many :contacts

	geocoded_by :address
	after_validation :geocode
	
	def department_random(max)
		#self.joins("inner join departments on departments.hospital_id = ?", self.id).sample(Faker::Number.between(1, max))
		Department.where("departments.hospital_id = ?", self.id).sample(Faker::Number.between(1, max))
	end

	def address
		self.building_num.to_s + " " + self.primary_address.to_s + " " + self.secondary_address.to_s + " " + self.tertiary_address.to_s + " " + self.city.to_s + " " + self.postal_code.to_s + " " + self.country.to_s
	end

	scope :with_distance_to, ->(point) { select("#{table_name}.*").select("(#{distance_from_sql(point)}) as distance") }

end