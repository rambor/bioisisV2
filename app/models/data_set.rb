class DataSet < ApplicationRecord

  belongs_to :experiment
  #has_many_attached :files
  has_many :reciprocal_space_files
  accepts_nested_attributes_for :reciprocal_space_files

  has_and_belongs_to_many :materials
  validates :name, :presence => true
  validates :description, :presence => true
  validates :buffer, :presence => true
  validates :source, :presence => true
  validates :instrument_name, :presence => true
    #validates :files, :allow_blank => true, data: { content_type: 'application/octet-stream', size_range: 120.megabytes }
    #validates :real_space_files, :allow_blank => true, real_data: { content_type: 'application/octet-stream', size_range: 10.megabytes }

end
