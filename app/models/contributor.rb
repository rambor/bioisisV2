class Contributor < ApplicationRecord
  before_save :upcase_last
  belongs_to :experiment
  validates_presence_of :last_name, :message => "Last Name can't be blank"
  validates_presence_of :given_names, :message => "Given Names can't be blank"

  private
  def upcase_last
    self.last_name = self.last_name.upcase_first
  end
end