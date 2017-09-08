class Conversation < ActiveRecord::Base
	belongs_to :sender, foreign_key: :sender_id, class_name: 'User'
	belongs_to :recipient, foreign_key: :recipient_id, class_name: 'User'

	has_many :messages, dependent: :destroy

	validates_uniqueness_of :sender_id, scope: :recipient_id

	scope :involving, -> (user) do
		#puts user.inspect
		where("conversations.sender_id = ? OR conversations.recipient_id = ?", user.id, user.id)
	end

	scope :between, -> (sender_id, recipient_id) do 
		where("(conversations.sender_id = ? AND conversations.recipient_id = ?) OR (conversations.sender_id = ? AND conversations.recipient_id = ?)", 
			sender_id, recipient_id, recipient_id, sender_id)
	end

	scope :unread, -> (user) do
		#where(:id => Message.unread_by(user).where(:conversation_id => involving(user).ids))
		#where(:id => Message.unread_by(user)).where(recipient_id: user.id)
		#where(recipient_id: user.id).where(:id => Message.read_by(user))
		where(:id => Message.unread_by(user).select("conversation_id"), recipient_id: user.id)
	end

  	scope :convfilter, -> (convfilter) do
  		where(sender: User.namefilter(convfilter)).or(Conversation.where(recipient: User.namefilter(convfilter)))
  	end

	def unread?(user)
		Conversation.unread(user).include? self
	end

	def unread_count(user)
		r = Message.unread_by(user).where("conversation_id = ?", self.id).count 
		r if r > 0
	end

	def last_message_time()
		self.messages.order(:created_at).last&.created_at
	end
end