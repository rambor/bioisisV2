desc "Remove Archive files from db/SAXS subdirectories"

task :purge_archives do

  saxs_data_dir  = "db/SAXS"
  if Dir.exist?(saxs_data_dir)
    entries = Dir.entries(saxs_data_dir).select {|entry| File.directory? File.join(saxs_data_dir,entry) and !(entry =='.' || entry == '..')}
    entries.each do |subdirectory|
      zipfiles = Dir["#{saxs_data_dir}/#{subdirectory}/*.zip"]
      if zipfiles.size == 1 && File.exists?(zipfiles[0])
        if Rails.env.production?
          puts "In PRO MODE :: zip file exist => remove #{zipfiles[0]}"
          FileUtils.remove_file(zipfiles[0])
          puts "#{subdirectory} File exists? :: #{File.exists?(zipfiles[0]) }"
        elsif Rails.env.development?
          puts "In DEV MODE :: zip file exists and will not be removed #{zipfiles[0]}"
        end
      end
    end
  end

end