class RealSpaceFile < ApplicationRecord
  belongs_to :reciprocal_space_file
  has_one_attached :file
  validates_presence_of :dmax, numericality: { greater_than: 0 }

  validates :file, presence: true, real_data: { content_type: 'application/octet-stream', size_range: 1.megabytes }

end
