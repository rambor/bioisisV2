class ReciprocalSpaceFile < ApplicationRecord
  has_one :real_space_file
  has_one_attached :file
  belongs_to :data_set

  accepts_nested_attributes_for :real_space_file
  validates :file,  presence: true, data: { content_type: 'application/octet-stream', size_range: 100.megabytes }


end
