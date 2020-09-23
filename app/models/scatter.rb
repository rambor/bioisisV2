class Scatter < ApplicationRecord
  # Use this site key in the HTML code your site serves to users
  # 6Leo08gZAAAAAA79rkrFITwBq8W6vDI3KxAeYCIQ
  #
  # Use this secret key for communication between your site and reCAPTCHA
  # 6Leo08gZAAAAAFGOIM5meLh8uioo5bJgrt6bVba2
  #
  #
  attribute :email_users, :boolean
  #
  has_one_attached :zip_file
  validates_presence_of :comments, :version, :title

end
