class Message < ActiveRecord::Base
  belongs_to :conversation, touch: true
  belongs_to :user
  acts_as_readable :on => :created_at

  validates_presence_of :content, :conversation_id, :user_id

  def message_time
  	created_at.strftime("%r %v")
  end

  def unread?(user) 
  	User.have_read(self).include? user
  end
end
