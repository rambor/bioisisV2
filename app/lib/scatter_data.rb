class ScatterData
  extend ActiveModel::Callbacks
  define_model_callbacks :initialize, :only => :after

  include ActiveModel::Model
  #include ActiveModel::Attributes
  #include ActiveModel::Validations
  attr_accessor :is_subtracted, :is_sec, :file, :filename, :xvalues, :yvalues, :zvalues, :xy_data, :x_xy_data, :xy_log_data, :cols, :y_min, :y_max, :y_min_log, :y_max_log, :xy_min, :xy_max, :logx_logy_data, :kratky_data
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
      @is_sec = false
      @is_subtracted = true
      @xvalues = []
      @yvalues = []
      @zvalues = []
      @xy_data = []
      @xy_log_data=[]
      @logx_logy_data=[]
      @kratky_data=[]
      @x_xy_data=[]
      @y_min = Float::MAX
      @y_max = -Float::MAX
      @xy_min = Float::MAX
      @xy_max = -Float::MAX
      @y_min_log = Float::MAX
      @y_max_log = -Float::MAX
      @cols||=[]
      if @cols.size == 0
        @cols =[0,1]
      end
    end

  end


  def read_sec_file

    json_string = File.open(@file, &:readline)
    #: raise StandardError.new "SEC FILE DOES NOT EXIST"

    if valid_json?(json_string)

      # make signal plot
      # frame_index, signal_index
      jason = JSON.parse(json_string).deep_symbolize_keys
      signal_index = jason[:sec_format][:signal_index].to_i
      frame_index = jason[:sec_format][:frame_index].to_i

      sec_file = File.foreach(@file)
      count = 0

      signal_line = String.new
      frame_line = String.new
      sec_file.each do |line|
        if count == signal_index
          signal_line = line.chomp.strip # remove carriage return
        elsif count == frame_index
          frame_line = line.chomp.strip
        elsif count > signal_index && count > frame_index
          break
        end
        count +=1
      end

      raise StandardError.new "CORRUPT SIGNAL LINES => " unless signal_line.size > 1 || frame_line.size > 1
      #
      # assume here that signal and frame index starts with MD5 hash
      #
      signals = signal_line.split
      frame_indices = frame_line.split

      total = signals.size
      raise StandardError.new "frames do not match signals" unless total == frame_indices.size

      for i in 1...total
        yval = signals[i].to_f
        @xy_data << [frame_indices[i].to_i, yval]
        @y_max = (yval > @y_max) ? yval : @y_max
        @y_min = (yval < @y_min) ? yval : @y_min
      end

      bins = [0.0,0.0,0.0,0.0,0.0,0.0]
      diff = (@y_max - @y_min)/bins.size

      for i in 1...total
        yval = signals[i].to_f
        bin = ((yval-@y_min)/diff).floor
        bin = bin >= bins.size ? bin - 1 : bin
        bins[bin] += 1
      end
      max_index = 0
      largest = 0.0
      bins.each_index do |x|
        val = bins[x]
        if (val > largest)
          largest = val
          max_index = x
        end
      end

      average = max_index*diff + @y_min

      @y_min = average
      @is_sec = true
    else
      raise StandardError.new "SEC JSON NOT CORRECT => #{json_string}"
    end

  end

  def read_contents

    referencePDBLines=[]
    File.open(@file){|x| referencePDBLines = x.readlines}

    isItTrue=[]
    referencePDBLines.each do |line|
      elements = line.strip.split(/[\s\t]+/)
      # how many consecutive lines have correct format?
      if line !~ /\AREMARK/ && numeric?(elements[0]) && numeric?(elements[1]) && numeric?(elements[2])
        isItTrue << true
      else
        isItTrue << false
      end
    end

    for i in 0...(referencePDBLines.size - 2)
      if isItTrue[i] && isItTrue[i+1] && isItTrue[i+2]
        elements = referencePDBLines[i].strip.split(/[\s\t]+/)
        xval = elements[@cols[0]].to_f
        yval = elements[@cols[1]].to_f
        xyval = xval*yval
        @xvalues << xval
        @yvalues << yval
        @xy_data << [xval, yval]
        @x_xy_data << [xval, xyval]
        @y_max = (yval > @y_max) ? yval : @y_max
        @y_min = (yval < @y_min) ? yval : @y_min

        @xy_max = (xyval > @xy_max) ? xyval : @xy_max
        @xy_min = (xyval < @xy_min) ? xyval : @xy_min
        @kratky_data << [xval, xval*xval*yval]

        if xval > 0 && yval > 0
          ylog = Math.log10(yval)
          @xy_log_data << [xval, ylog]
          @logx_logy_data << [Math.log10(xval), ylog]
          @y_max_log = (ylog > @y_max_log) ? ylog : @y_max_log
          @y_min_log = (ylog < @y_min_log) ? ylog : @y_min_log
        end

        if @cols.size == 3
          @zvalues << elements[@cols[2]].to_f
        end
      end
    end
  end

  private
  def numeric?(val)
    Float(val) != nil rescue false
  end

  def valid_json?(json)
    JSON.parse(json)
    return true
  rescue JSON::ParserError => e
    return false
  end

end