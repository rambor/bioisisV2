class DataValidator < ActiveModel::EachValidator

  # record is DataFile Object
  # values ActiveStorage::Attached Objects that are existing and new
  Data = Struct.new(:qval, :iofq, :error)

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
    #
    fileToRead = record.attachment_changes['file']&.attachable
    #
    #
    #
    contents = (fileToRead.class.name.match? /UploadedFile/) ? fileToRead.read : nil
    unless contents.nil?
      extension = File.extname(fileToRead.path)
      if extension == ".dat"
        dataset = []
        contents.each_line do |line|
          elements = line.strip.split(/[\s\t]+/)
          # how many consecutive lines have correct format?
          if !line.match?(/REMARK/) && (numeric?(elements[0]) && numeric?(elements[1]) && numeric?(elements[2]))
            qval = elements[0].to_f
            error = elements[2].to_f
            # can't place judgement on intensity, could be < 0 in a difference
            if qval > 0 && error > 0
              dataset << Data.new(qval, elements[1].to_f, error)
            end
          end
        end
        #
        # validate the set of data is sensible
        #
        for i in 1...dataset.size
          if dataset[i].qval < dataset[i - 1].qval
            record.errors.add(attribute, "q-values order incorrect")
            return false
          end
        end

        puts "total data points in validator #{dataset.size}"
        if dataset.size < 100 # too few datapoints
          record.errors.add(attribute, "check file format, no valid data found, must have at least 3 columns")
          return false
        end

      elsif extension == ".sec"
        # first line must be a json string
        # read first line to see if it is a valid JSON string
        #
        strVar = File.open(fileToRead.path, &:readline)
        if valid_json?(strVar)
          jason = JSON.parse(strVar).deep_symbolize_keys

          # go through each key and validate line
          jason[:sec_format].each_pair do |key, index|
            sec_file = File.foreach(fileToRead.path)

            if key.match? "index"
              count = 0
              stop_at = index.to_i
              sec_file.each do |line|
                if count == stop_at

                  elements = line.split
                  mdf = ""
                  dataline = "a"
                  # actual trace lines start with index of frame followed by MDF5HEX
                  if key.match? "subtracted_intensities"
                    mdf = elements[1]
                    dataline = line[mdf.size+elements[0].size+1, line.size - mdf.size-elements[0].size-1].lstrip.chomp
                  else
                    mdf = elements[0]
                    dataline = line[mdf.size, line.size - mdf.size].lstrip.chomp
                  end
                  # mdf = key.match? "subtracted_intensities" ? elements[1] : elements[0]
                  # dataline = key.match? "subtracted_intensities" ? line[mdf.size+elements[0].size, line.size - mdf.size-elements[0].size].lstrip.chomp : line[mdf.size, line.size - mdf.size].lstrip.chomp
                  recalc = (Digest::MD5.hexdigest dataline).upcase

                  if mdf == recalc
                    break
                  else
                    record.errors.add(attribute, "SEC file, MD5 violation, see #{key} : #{index} #{line[0, mdf.size + 4]}")
                    return false
                  end
                end
                count += 1
              end
            end

          end
        else
          record.errors.add(attribute, "INVALID JSON string in SEC file, must be single line")
        end

        return false
      else
        record.errors.add(attribute, "incorrect file type, must be *.sec or *.dat")
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
end