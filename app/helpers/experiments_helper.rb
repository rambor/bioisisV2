module ExperimentsHelper

  def total_data_files(data_sets)
    count=0
    puts "HELPER #{count}"
    data_sets.each do |d_set|
      puts "RCP -- 2 #{count} #{d_set.reciprocal_space_files.size}"
      count += d_set.reciprocal_space_files.size
    end
    puts "HELPER -- 2 #{count} #{data_sets.size}"

    count
  end

  def total_associated_files(data_set)
    data_set.reciprocal_space_files.size
  end
end
