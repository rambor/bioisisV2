desc "Remove Archive files from db/SAXS subdirectories"

task :purge_archives do

  saxs_data_dir  = "db/SAXS"
  if Dir.exist?(saxs_data_dir)
    entries = Dir.entries(saxs_data_dir).select {|entry| File.directory? File.join(saxs_data_dir,entry) and !(entry =='.' || entry == '..')}
    entries.each do |subdirectory|
      zipfiles = Dir["#{saxs_data_dir}/#{subdirectory}/*.zip"]
      if zipfiles.size == 1 && File.exists?(zipfiles[0])
        puts "#{subdirectory} #{Rails.env.production?} D #{Rails.env.development?}"
        if Rails.env.production?
          #FileUtils.remove_file(zipfiles[0])
          "zip file exist to remove #{zipfiles[0]}"
        elsif Rails.env.development?

        end
      end
    end
  end

end