class Availability < ApplicationRecord
	belongs_to :doctor

  def as_json(options = {})
    
    events = availToEvents
    {
      :id => events.id,
      :title => events.title,
      :start => events.start,
      :end => events.end,
      :date => events.date,
      #:url => Rails.application.routes.url_helpers.events_path(id),
      #:color => "green"
    }
  end

end
