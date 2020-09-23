class Experiment < ApplicationRecord

  has_many :data_sets
  has_many :contributors
  has_one_attached :figure
  belongs_to :user
  belongs_to :submission
  has_many :publications
  has_many :archives
  validates_presence_of :description, :message => "Description can't be blank"
  #validates_length_of :description, :minimum => 100, :message => "Description too short", :allow_blank => true
  validates_length_of :title, :minimum => 20, :message => "Title too short, at least 20 characters"
  validates_presence_of :state, :message => "Must have a status"
#  validate :figure_format

  accepts_nested_attributes_for :publications, reject_if: proc { |attributes| attributes['title'].blank? }
  #
  # data_files will be *.dat and associated pofr files
  #
  # abstract/description
  #
  def resize_image
      resized_image = MiniMagick::Image.read(figure.download)
      resized_image = resized_image.resize "150x150"
      v_filename = obj.filename
      v_content_type = obj.content_type
      obj.purge
      obj.attach(io: File.open(resized_image.path), filename:  v_filename, content_type: v_content_type)
  end


  def self.search(search)
    if search
      where('bioisis_id LIKE ?', "%#{search}%").limit(5)
    else
      scoped
    end
  end

  def get_random_data_to_plot
    total_datasets = self.data_sets.size
    random_dataset = self.data_sets[rand(total_datasets)]
    file_to_use = random_dataset.files[rand(random_dataset.files.size)]

    extension = file_to_use.blob.filename.extension

    if extension == "dat"
      file_to_use.get_log10iofq_data
    elsif extension == "sec"
      file_to_use.get_sec_trace
    end
  end

  private
  def figure_format
    return unless figure.attached?
    if figure.blob.content_type.start_with? 'image/'
      if figure.blob.byte_size > 10.megabytes
        errors.add(:figure, 'size needs to be less than 10MB')
        figure.purge
      else
        resize_image
      end
    else
      figure.purge
      errors.add(:figure, 'needs to be an image')
    end
  end

end
