class Event < ActiveRecord::Base
  has_many :bets, dependent: :destroy

  scope :sport_types, lambda { distinct.pluck :sport_type }
end