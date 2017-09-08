class User < ApplicationRecord
  actable
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # unread
  acts_as_reader

  # paperclip
  has_attached_file :avatar
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/


  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  
  #has_many :jobs_as_employer, :class_name => "Job", :foreign_key => 'employer_id'
  #has_many :jobs_as_doctor, :class_name => "Job", :foreign_key => 'doctor_id'

  belongs_to :rating_cache

  has_many :contacts
  
  #belongs_to :specialty
  #belongs_to :title

  ratyrate_rater
  ratyrate_rateable "score"

  scope :involving, -> (user) do
    # deprecated
		#where("contracts.doctor_id = ? OR jobs.employer_id = ?", user.id, user.id)
	end

  scope :stage, -> (uid) do
    select("stage", "id").where("users.id = ?", uid).first().stage 
  end

  scope :namefilter, -> (spec) do
    spec = "%" + spec + "%"
    where("LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?", spec.downcase, spec.downcase)
  end

  scope :set_stage, -> (uid, stage) do
    update(uid, :stage => stage)
  end

  scope :add_role, -> (uid, role) do
    update(uid, :type => role)
  end

  scope :update_spec, -> (user, params) do
    profession = params["profession_id"]
    
    spec = params["specialty_id"]
    puts params.inspect
    update(user, { :profession_id => profession, :specialty_id => spec })
  end

  scope :confirm_RIBIZ, -> (user, params) do
    profession = params.profession["id"]
    specialty = params.specialty["id"] if params.specialty
    #Doctor.update(user.actable.id, { :professions.add, :specialty_id => specialty, :RIBIZ_num => params.bignumber})
    d = Doctor.find(user.actable.id)
    d.professions.push(Profession.find(profession))
    d.specialties.push(Specialty.find(specialty)) if specialty
    d.BIG_number = params.bignumber
    d.save!
    user.add_role :doctor if !user.has_role? :doctor
  end
end
