class Event < ActiveRecord::Base
  has_many :bets, dependent: :destroy
end