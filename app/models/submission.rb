class Submission < ApplicationRecord

  belongs_to :user
  has_many :comments
  has_one :experiment, dependent: :destroy
  accepts_nested_attributes_for :experiment

  validates :data_directory, :uniqueness => true
  validates_format_of :email, :with => Devise::email_regexp, :message => "Invalid email"
#  validates :bioisis_id, length: { is: 6, :message => "Must be 6 characters only"}, :allow_blank => true
  validates_length_of :bioisis_id,  minimum: 6, :allow_blank => true

  def self.search(search)
    if search
      where('bioisis_id LIKE ?', "%#{search}%").limit(5)
    else
      scoped
    end
  end

end
