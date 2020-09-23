class RealDataValidator < ActiveModel::EachValidator

  # record is DataFile Object
  # values ActiveStorage::Attached Objects that are existing and new
  Data = Struct.new(:rval, :pofr)

  def validate_each(record, attribute, values)
    return unless values.attached?

    Array(values).each do |value|

      if options[:size_range].present? && value.new_record?
        if options[:size_range] < value.blob.byte_size
          #record.errors.add(attribute, :max_size_error, max_size: ActiveSupport::NumberHelper.number_to_human_size(options[:size_range]))
          record.errors.add(attribute, "Exceeded max file size")
        end
      end
      #puts "TEXT #{value.blob.text?}"
      if value.new_record?
        unless valid_file_format?(value.blob)
          record.errors.add(attribute, :content_type)
        end
      end
    end

    #
    # validate format of the file
    #
    #return unless record.attachment_changes['files'].blank?
    fileToRead = record.attachment_changes['file']&.attachable
    contents = (fileToRead.class.name.match? /UploadedFile/) ? fileToRead.read : nil

    if contents.nil? # if attaching through seed file
      fileToRead = fileToRead[:io]
      contents = File.new(fileToRead)
    end

    unless contents.nil?
      extension = File.extname(fileToRead.path)
      if extension == ".dat"
        dataset = []
        contents.each_line do |line|
          elements = line.strip.split(/[\s\t]+/)
          # how many consecutive lines have correct format?
          # JSON string will never have two consecutive elements that are numbers ?
          if line !~ /\AREMARK/ && (numeric?(elements[0]) && numeric?(elements[1]))
            rval = elements[0].to_f
            # can't place judgement on intensity, could be < 0 ???
            if rval >= 0
              dataset << Data.new(rval, elements[1].to_f)
            end
          end
        end
        #
        # validate the set of data is sensible
        #
        for i in 1...dataset.size
          if dataset[i].rval < dataset[i - 1].rval
            puts fileToRead.path
            record.errors.add(attribute, "r-values order incorrect")
            return false
          end
        end

        if dataset.size < 5 # too few datapoints
          puts fileToRead.path
          record.errors.add(attribute, "check file format, no valid data found, must have at least 2 columns")
          return false
        end

        # if (fileToRead.class.name.match? /UploadedFile/)
        #   fileToRead.rewind
        # end

        elsif extension == ".out" # GNOM
        # should have a line in it that contains "G N O M or GNOM"
        #
        # should have a line that contains "Distance distribution"
        gnom_file = File.foreach(fileToRead.path)
        has_gnom = false
        has_pr = false
        has_rs = false

        test = gnom_file.select{|v| v =~ /(G N O M)|(R[\s\t]+P\(R\)[\s\t]+ERROR)|(Distance[\s\t]+[Dd]istribution[\s\t]+)/}

        if test.size < 3
          record.errors.add(attribute, "Improper GNOM file, extension .out suggests GNOM, missing proper format G N O M")
          return false
        end

        gnom_file.each do |line|
          stripped = line.gsub(/\s+/,"")
          if stripped.include?("GNOM") || stripped.match?(/GNOM/i)
            has_gnom = true
            break
          end
        end

        gnom_file.each do |line|
          if line.match?(/real/i) && line.match?(/space/i)
            has_rs = true
            break
          end
        end

        locale = 0
        gnom_file.each do |line|
          if line.match?(/distance/i) && line.match?(/distribution/i)
            has_pr = true
            break
          end
          locale += 1
        end

        unless has_gnom && has_pr && has_rs
          record.errors.add(attribute, "Improper GNOM file, extension .out suggests GNOM")
          return false
        end

        start_at = 0
        values =[]
        gnom_file.each do |line|
          if start_at >= locale
            if check_format(line)
              elements = line.strip.split(/[\s\t]+/)
              values << Data.new(elements[0].to_f, elements[1].to_f)
            end
          end
          start_at += 1
        end

        if values.size < 12
          record.errors.add(attribute, "Too few lines for GNOM file :: #{values.size}")
        end

        return true
      else
        record.errors.add(attribute, "incorrect file type, must be *.out or *.dat")
        return false
      end
    end

  end

  private
  def valid_file_format?(blob)

    return true if options[:content_type].nil?

    case options[:content_type]
    when Regexp
      puts "REGEXP"
      options[:content_type].match?(blob.content_type)
    when Array
      puts "ARRAY"
      options[:content_type].include?(blob.content_type)
    when Symbol
      puts "SYMBOL"
      blob.public_send("#{options[:content_type]}?")
    else
      options[:content_type] == blob.content_type
    end
  end

  def valid_file_extension?(fileToRead)
    puts File.extname(fileToRead.path)
  end


  def numeric?(val)
    Float(val) != nil rescue false
  end

  private
  def valid_json?(json)
    JSON.parse(json)
    return true
  rescue JSON::ParserError => e
    return false
  end

  def check_format(line)

    if line =~ /([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+/i
      elements = line.strip.split(/[\s\t]+/)
      if numeric?(elements[0]) && numeric?(elements[1]) && numeric?(elements[2])
        return true
      end
    end
    false
  end

end