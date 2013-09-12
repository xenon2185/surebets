class EventsController < ApplicationController
  def index
    @events = Event.all
    @sport_types = Event.sport_types
    if params[:event]
      event = params[:event]
      @events = @events.where(:datetime => parse_datetime(event,'datetime')) if event['datetime(1i)']
    end 
  end
  def show
    @event = Event.find(params[:id])
  end
  def parse_datetime hash, field_name
    dt = DateTime.new hash[field_name + '(1i)'].to_i, 
                      hash[field_name + '(2i)'].to_i, 
                      hash[field_name + '(3i)'].to_i, 
                      hash[field_name + '(4i)'].to_i,
                      hash[field_name + '(5i)'].to_i
    Time.zone.parse(dt.to_s)
  end
end
