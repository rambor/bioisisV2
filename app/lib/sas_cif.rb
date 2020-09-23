class SasCif
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :json, :file



  def initialize(attributes={})
    super
    #@file = file_blob
    @json=String.new
    @file_lines=[]
    @three_columns = Regexp.new("([+-]?[0-9]\\.[0-9]+(E[+-]?[0-9]+)?[\\s\\t]+){2}([+-]?[0-9]\\.[0-9]+(E[+-]?[0-9]+)?[\\s\\t]*[\\r\\n]*)", Regexp::IGNORECASE)

    read_blob
  end

  def get_json
    # json line should either have a {, } or contain : as in "dog" : "muffin"
    # sec file should contain a single line

    temp_lines = @file_lines.select{|line| line.match?(/("?[.]+"?:)|,|{|}/) && !check_if_data_line(line) && !line.match?(/^(REMARK|#)/)}.map(&:chomp).join

    if valid_json?(temp_lines)
      @json = temp_lines
    else
      @json=""
    end

    @json
  end


  private
  def read_blob
    @file.open do |file|
      if @file.filename.extension == "sec" # get first line, formatted sec file contains JSON as first line
        @file_lines << File.open(file, &:readline)
      elsif @file.filename.extension == "dat"
        File.open(file){|x| @file_lines = x.readlines}
      end
    end
  end



  def check_if_data_line(line)
    line.match?(@three_columns)
  end

  def valid_json?(json)
    JSON.parse(json)
    true
  rescue JSON::ParserError => e
    return false
  end

end