class BigUser
	attr_accessor :name, :gender, :specialty, :profession, :bignumber

	def initialize(n, g, s, t, b)
		@name = n
		@gender = g
		@specialty = s 
		@profession = t 
		@bignumber = b
	end

	def inspect
		"BigUser(name: #{@name}, gender: #{@gender}, specialty: #{@specialty.inspect}, profession: #{@profession.inspect}, bignumber: #{@bignumber})" 
	end
	
	def to_s
		"BigUser(name: #{@name}, gender: #{@gender}, specialty: #{@specialty.inspect}, profession: #{@profession.inspect}, bignumber: #{@bignumber})" 
	end
end