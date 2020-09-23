module DataFileMethods

  def getLastPofRLine(filename)
    file = File.open(filename)
    file_data = file.readlines.map(&:chomp)

    r_data =[]
    file_data.each do |line|
      if line =~ /([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+/i
        elements = line.strip.split(/[\s\t]+/)
        if numeric?(elements[0]) && numeric?(elements[1]) && numeric?(elements[2])
          r_data << elements[0].to_f
        end
      end
    end

    file.close
    r_data.last
  end
end

