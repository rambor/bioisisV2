class PofrData
  extend ActiveModel::Callbacks
  define_model_callbacks :initialize, :only => :after

  include ActiveModel::Model
  #include ActiveModel::Attributes
  #include ActiveModel::Validations
  attr_accessor :file_blob, :filename, :r_values, :pr_values, :dmax, :pr_max, :pr_min
  # before_validation :ensure_file_is_accessible

  # pass in columns to plot
  def initialize(attributes={})
    super
    # @attributes={}
    #attributes.each { |key, val| (@attributes[key] = val) if respond_to?("#{key}=") }
    #
    # @attributes.each do |name, value|
    #    send("#{name}=", value)
    # end
    run_callbacks :initialize do
      @r_values = []
      @pr_values = []
      @dmax = 0.0
      @pr_max = -Float::MAX
      @pr_min = Float::MAX
      @cols =[0,1]
      @filename = @file_blob.filename
    end

  end

  # file should already be validated during upload, no need to double check
  def read_contents

    #puts "pofr file #{@file_blob.filename}"

    file_lines=[]
    @file_blob.open do |file|
      File.open(file){|x| file_lines = x.readlines}
      puts file_lines[0]
      puts file_lines.last
    end

    if @file_blob.filename.extension == "out" # GNOM
      getDataLinesFromGnom(file_lines)
    elsif @file_blob.filename.extension == "dat" # scatter
      puts "reading file @file #{@file_blob.filename}"
      getDataLinesFromScatter(file_lines)
    end

    @dmax = @r_values.last
    @pr_values.each do |y|
      @pr_max = (y[1] > @pr_max) ? y[1] : @pr_max
      @pr_min = (y[1] < @pr_min) ? y[1] : @pr_min
    end

  end

  private

  def getDataLinesFromGnom(file_lines)

    locale = 0
    file_lines.each do |line|
      if line.match?(/distance/i) && line.match?(/distribution/i)
        break
      end
      locale += 1
    end

    (locale...file_lines.size).each do |i|
      line = file_lines[i]
      if check_format line
        elements = line.strip.split(/[\s\t]+/)
        @r_values << elements[0].to_f
        @pr_values << [elements[0].to_f, elements[1].to_f]
      end
    end
  end

  def getDataLinesFromScatter(file_lines)
    locale = 0

    # should be 3 column format, if header has REMARK and other text, looking for when it stops
    file_lines.each do |line|
      if line.match?(/REMARK 265/i) && line.match?(/distribution/i)
        break
      elsif check_format(line) && check_format(file_lines[locale+1]) # no header but three columns
        break
      end
      locale += 1
    end

    (locale...file_lines.size).each do |i|
      line = file_lines[i]

      if check_format line
        elements = line.strip.split(/[\s\t]+/)
        @r_values << elements[0].to_f
        @pr_values << [elements[0].to_f, elements[1].to_f]
      end
    end
  end

  def numeric?(val)
    Float(val) != nil rescue false
  end

  def check_format(line)
    three_columns = Regexp.new("([+-]?[0-9]\\.[0-9]+(E[+-]?[0-9]+)?[\\s\\t]+){2}([+-]?[0-9]\\.[0-9]+(E[+-]?[0-9]+)?[\\s\\t]*[\\r\\n]*)", Regexp::IGNORECASE)
    #if line =~ /([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+/i
    if line.match?(three_columns)
      elements = line.strip.split(/[\s\t]+/)
      if numeric?(elements[0]) && numeric?(elements[1]) && numeric?(elements[2])
        return true
      end
    end
    false
  end

end