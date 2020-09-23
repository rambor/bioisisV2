class Archive < ApplicationRecord
  belongs_to :experiment
  has_one_attached :zip_file
  validate :zip_format
  validates_presence_of :description
  validates_length_of :description, :minimum => 50

  private
  def zip_format
    return unless zip_file.attached?
    if zip_file.blob.content_type.include? "zip"
      if zip_file.blob.byte_size > 100.megabytes
        errors.add(:zip_file, 'size needs to be less than 10MB')
      end
    else
      errors.add(:zip_file, 'needs to be a zip file')
    end
  end

end
