class User < ApplicationRecord
  ROLES = %i[Admin Reviewer User Author]

#  has_many :roles_users
#  has_many :roles, :through => :roles_users
  has_and_belongs_to_many :roles
  has_many :scatter_downloads
  has_many :experiments
  has_many :submissions

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable, :trackable

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :password_confirmation, :remember_me, :city, :last_name, :first_name

  validates :city, :presence => true
  validates :country, :presence => true
  validates :last_name, :presence => true
  validates :first_name, :presence => true

  def role?(role)
    return !!self.roles.find_by_role(role.to_s.camelize)
  end

end
