class Publication < ApplicationRecord
  validates_presence_of :container_title
  validates_presence_of :title
  validates_presence_of :year
  validates_presence_of :month
  belongs_to :experiment
end
