# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# roles :: Admin, User, Reviewer, Author - must be added to database manually
#require File.expand_path('../../lib/data_file_methods', __FILE__)
SasCIFResult = Struct.new(:experimental_MW, :i0_from_Guinier, :i0_from_Guinier_error, :dmax, :rg_from_Guinier, :rg_from_Guinier_error, :rg_from_pr, :rg_from_pr_error, :porod_volume, :porod_exponent, :volume_of_correlation)

def getMonth(month_string)
  month_string.downcase!
  list = %w{january february march april may june july august september october november december}

  index = list.index(month_string)
  if index.nil?
    expression = Regexp.new(month_string)
    index = list.index{|x| x.match? expression}
  end
  index += 1
end

def numeric?(val)
  Float(val) != nil rescue false
end

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

def has3ColumnsData(filename)

  file = File.open(filename)
  file_data = file.readlines.map(&:chomp)

  count = 0
  file_data.each do |line|
    if line =~ /([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+/i
      elements = line.strip.split(/[\s\t]+/)
      if numeric?(elements[0]) && numeric?(elements[1]) && numeric?(elements[2])
        count += 1
      end
    end
  end

  file.close
  count > 100

end

Role.create(role: 'Admin')
Role.create(role: 'User')
Role.create(role: 'Reviewer')
Role.create(role: 'Author')

# validates :city, :presence => true
# validates :country, :presence => true
# validates :last_name, :presence => true
# validates :first_name, :presence => true

user = User.create(last_name: "Rambo", first_name: "Robert", country: "UK", city: "Didcot", email: "robert_p_rambo@hotmail.com", mailing_list: false, password:"123456789", password_confirmation: "123456789")
user.roles << Role.find_by(:id => 1)
# news update story

#
Material.create(material: 'protein')
Material.create(material: 'RNA')
Material.create(material: 'DNA')
Material.create(material: 'carbohydrate')
Material.create(material: 'glycosylated')
Material.create(material: 'lipid')
Material.create(material: 'detergent')
Material.create(material: 'surfactant')
Material.create(material: 'peptide')
Material.create(material: 'peptide-conjugate')
Material.create(material: 'gel')
Material.create(material: 'polymer')
Material.create(material: 'diblock copolymer')
Material.create(material: 'other')

# load existing data
# look in directory and see if BID was issued in summary.txt
# if so, test that iofq files are correct format, 3 columns, if not, add third column
# News.create(title: "Rebuild of BioISIS",
#             journal_info: "",
#             abstract: "",
#             notes: "",
#             category:"",
#             )

Serrano.configuration do |config|
  config.mailto = "robert_p_rambo@hotmail.com"
end

saxs_data_dir  = "#{Dir.pwd}/db/SAXS"
if Dir.exist?(saxs_data_dir)
  # get list of all sub_directories
  entries = Dir.entries(saxs_data_dir).select {|entry| File.directory? File.join(saxs_data_dir,entry) and !(entry =='.' || entry == '..')}
  entries.each do |subdirectory|

    filename = "#{saxs_data_dir}/#{subdirectory}/summary.txt"
    filename = (File.exists? filename) ? filename : "#{saxs_data_dir}/#{subdirectory}/summary_file.txt"

    if File.exist? filename
      file = File.open(filename)
      file_data = file.readlines.map(&:chomp)
      file.close
      bid = file_data.select{|x| x.include? "BIOISIS_ID" }
      contributors =[]
      if bid.size == 1
        elements = bid[0].strip.split
        if elements.size == 2
          sasSICF = SasCIFResult.new
          bid = elements[1].upcase

          "CREATING BID #{bid} #{bid.size}"
          submission = Submission.create(bioisis_id: bid, data_directory: subdirectory, email: "robert_p_rambo@hotmail.com", user_id: user.id)
          submission.create_experiment(bioisis_id: bid, :description => "Please Provide a Description via EDIT DETAILS", :title=>"Please provide a suitable title via EDIT DETAILS", :user_id => user.id, :state => "journal")

          dataset = DataSet.new
          dataset.experiment = submission.experiment # set the experiment
          #dataset = submission.experiment.data_sets[0]

          details = ""
          file_data.each do |line|
            line.strip!
            if line =~ /^TITLE/
              submission.experiment.title = line[6, line.size-6]
            elsif line =~ /^DOI/
              submission.experiment.doi = line[4, line.size-4]
              submission.experiment.publication_doi = submission.experiment.doi
              # lookup publication
              #
              if submission.experiment.doi !~ /none/i
                address = "https://doi.org/#{submission.experiment.doi}"
                query = Serrano.works(ids: address)
                # while
                #   begin
                #     query = Serrano.works(ids: address)
                #     break
                #   rescue Serrano::ServiceUnavailable => e
                #     puts e.message# Message, message, message*
                #   end
                # end

                if query.size > 0 && query[0]["status"].downcase == "ok"
                  info = query[0]["message"]
                  j_title = info["container-title"][0]
                  vol = info["volume"]
                  issue = info["issue"]
                  year = info["issued"]["date-parts"][0][0].to_i
                  j_title = (vol.size > 0) ? j_title + ". " + vol : j_title
                  j_title = (issue.size > 0) ? j_title + "(" + issue+")" : j_title
                  j_title = (year.size > 0) ? j_title + " #{year}" : j_title
                  submission.experiment.publication = j_title

                  submission.experiment.publications.create(container_title: info["container-title"][0])
                  publication = submission.experiment.publications.last
                  #publication.container_title = info["container-title"][0]
                  publication.title = info["title"][0]
                  publication.volume = info["volume"]
                  publication.issue = info["issue"]
                  publication.year = info["issued"]["date-parts"][0][0].to_i
                  publication.page = info["page"]
                  publication.url = address

                  month = info["issued"]["date-parts"][0][1]

                  if month > 0 && month < 13
                    publication.month = month
                  elsif month.is_a? String
                    if month.size <3 && month =~ /^[0-9]{1,2}[:.,-]?$/
                      publication.month = month.to_i
                    elsif month =~ /[A-Za-z]+/
                      publication.month = getMonth(month)
                    end
                  end

                end
              end

            elsif line =~ /^EXP_DESCRIPTION/
              flag = "EXP_DESCRIPTION"
              submission.experiment.description = line[flag.size+1, line.size-flag.size+1].strip
            elsif line =~ /^EMAIL/
              elements = line.split
              if elements.size == 2
                submission.email = elements[1]
              else
                submission.email = "robert_p_rambo@hotmail.com"
              end
              submission.user_id = user.id
              submission.experiment.user_id = user.id
            elsif line =~ /^SOURCE_LOCATION/
              flag = "SOURCE_LOCATION"
              dataset.instrument_name = line[flag.size+1, line.size-flag.size+1].strip
              dataset.source = 'synchrotron'
              if (dataset.instrument_name.include? "Rigaku") || (dataset.instrument_name.include? "Bruker")
                dataset.source = 'home'
              end

              dataset.name = "Primary - single deposit"
              dataset.description = ""
            elsif line =~ /^PROTEIN/
              eles = line.strip.split
              if eles[1] =~ /YES/i
                dataset.materials << Material.find_by(:material => 'protein')
              end
            elsif line =~ /^RNA/
              eles = line.strip.split
              if eles[1] =~ /YES/i
                dataset.materials << Material.find_by(:material => 'RNA')
              end
            elsif line =~ /^DNA/
              eles = line.strip.split
              if eles[1] =~ /YES/i
                dataset.materials << Material.find_by(:material => 'DNA')
              end
            elsif line =~ /^BUFFER/
              details += (line[7, line.size-7]).strip
            elsif line =~ /^pH/
              eles = line.split
              details += + "(pH "+ eles[1] + ") "
            elsif line =~ /^TEMPERATURE/
              eles = line.split
              details += eles[1] + " &#176;C "
            elsif line =~ /^SALT /
              eles = line.split
              details += eles[1] + " mM "
            elsif line =~ /^ADDITIVES/
              if line.strip.size > "ADDITIVES".size
                details += line[10, line.size-10].strip
              end
            elsif line =~ /^DIVALENT /
              eles = line.split
              if eles[1] != "none"
                details += eles[1] + " "
              end
            elsif line =~ /^AUTHOR/
              eles = line.split
              #contributors << Contributor.new(last_name: eles[1], given_names: eles[2].gsub(/\./,""))
              submission.experiment.contributors.create(last_name: eles[1], given_names: eles[2].gsub(/\./,""))
            elsif line =~ /^Io/ && line !~ /^Io_/
              eles = line.split
              if numeric? eles[1]
                sasSICF.i0_from_Guinier = eles[1].to_f
              else
                sasSICF.i0_from_Guinier = "?"
              end
            elsif line =~ /^SIG_Io/
              eles = line.split
              if numeric? eles[1]
                sasSICF.i0_from_Guinier_error = eles[1].to_f
              else
                sasSICF.i0_from_Guinier = "?"
              end
            elsif line =~ /^Io_MOLEC/
              eles = line.split
              if numeric? eles[1]
                sasSICF.experimental_MW = eles[1].to_i
              else
                sasSICF.experimental_MW = "?"
              end
            elsif line =~ /^DMAX/
              eles = line.split
              if numeric? eles[1]
                sasSICF.dmax = eles[1].to_f
              else
                sasSICF.dmax = "?"
              end
            elsif line =~ /^RG/ && line !~ /^RG_/
              eles = line.split
              if numeric? eles[1]
                sasSICF.rg_from_Guinier = eles[1].to_i
              else
                sasSICF.rg_from_Guinier = "?"
              end
            elsif line =~ /^SIG_RG/ && line !~ /^SIG_RG_/
              eles = line.split
              if numeric? eles[1]
                sasSICF.rg_from_Guinier_error = eles[1].to_i
              else
                sasSICF.rg_from_Guinier_error = "?"
              end
            elsif line =~ /^RG_REAL/
              eles = line.split
              if numeric? eles[1]
                sasSICF.rg_from_pr = eles[1].to_i
              else
                sasSICF.rg_from_pr = "?"
              end
            elsif line =~ /^SIG_RG_REAL/
              eles = line.split
              if numeric? eles[1]
                sasSICF.rg_from_pr_error = eles[1].to_i
              else
                sasSICF.rg_from_pr_error = "?"
              end
            elsif line =~ /^V_POROD/
              eles = line.split
              if numeric? eles[1]
                sasSICF.porod_volume = eles[1].to_f
              else
                sasSICF.porod_volume = "?"
              end
            elsif line =~ /^V_C/
              eles = line.split
              if numeric? eles[1]
                sasSICF.volume_of_correlation = eles[1].to_f
              else
                sasSICF.volume_of_correlation = "?"
              end
            elsif line =~ /^POROD_EXPONENT/
              eles = line.split
              if numeric? eles[1]
                sasSICF.porod_exponent = eles[1].to_f
              else
                sasSICF.porod_exponent = "?"
              end
            elsif line =~ /^CREATED_ON/
              flag = "CREATED_ON"
              if line.split.size > 1
                date_to_use = line[flag.size+1, line.size-flag.size+1]&.strip
                if Date.parse(date_to_use)
                  submission.experiment.created_at = date_to_use
                end
              else
                submission.experiment.created_at = Time.now
              end

            end
          end

          submission.experiment.release_date = Time.now
          dataset.description = "Batch mode experiment, collected at several concentrations. Please see publication for details"
          dataset.buffer = details
          dataset.save!

          if submission.experiment.doi.nil?
            puts "DOI NIL with #{subdirectory}"
          end

          unless submission.save
            puts "error with #{subdirectory}"
            puts submission.errors.inspect
            exit
          end

          # check entries so need doi for each entry in summary.txt file?
          pofr = "#{saxs_data_dir}/#{subdirectory}/pofr_data_file.dat"
          iofq = "#{saxs_data_dir}/#{subdirectory}/iofq_data_file.dat"
          dataset = submission.experiment.data_sets[0]
          dataset.reciprocal_space_files.create(sas_type: "subtracted")

          if File.exists? iofq
            # check if 3 column, if so, use it otherwise, make temp file with 3 columns
            if has3ColumnsData(iofq)

              #submission.experiment.data_sets[0].reciprocal_space_files << ReciprocalSpaceFile.new(sas_type: "subtracted")
              dataset.reciprocal_space_files.last.file.attach(io: File.open(iofq), filename: "iofq_#{submission.bioisis_id}.dat")
              sascif = Hash.new
              sascif["sas_result"] = sasSICF
              dataset.reciprocal_space_files.last.json = sascif.to_json
              dataset.save

            else
              puts "Writing temp SX file for 2 column #{saxs_data_dir}/#{subdirectory}"
              iofqfile = File.open(iofq)
              file_data = iofqfile.readlines.map(&:chomp)
              iofqfile.close
              originals = "#{saxs_data_dir}/#{subdirectory}/originals"

              i_data =[]
              file_data.each do |line|
                if line =~ /([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+/i
                  elements = line.strip.split(/[\s\t]+/)
                  if numeric?(elements[0]) && numeric?(elements[1])
                    i_data << "#{elements[0]} #{elements[1]} #{elements[1].to_f*0.2}"
                  end
                end
              end

              if i_data.size < 10 # load int file
                int_files = Dir.glob("#{originals}/*.int")
                if int_files.size == 0
                  int_files = Dir.glob("#{originals}/*.dat")
                end
                puts "opening :: #{int_files[0]}"

                i_data.clear
                if File.exist? int_files[0]
                  iofqfile = File.open(int_files[0])
                  file_data = iofqfile.readlines.map(&:chomp)
                  iofqfile.close

                  file_data.each do |line|
                    if line =~ /([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+/i
                      elements = line.strip.split(/[\s\t]+/)
                      if numeric?(elements[0]) && numeric?(elements[1]) && numeric?(elements[2])
                        i_data << "#{elements[0]} #{elements[1]} #{elements[2]}"
                      else
                        i_data << "#{elements[0]} #{elements[1]} #{elements[1].to_f*0.2}"
                      end
                    end
                  end
                end
              end

              iofq_3column = "#{saxs_data_dir}/#{subdirectory}/iofq_data_file_pseudo.dat"
              File.open(iofq_3column, "w+") do |f|
                i_data.each { |element| f.puts(element) }
              end

              dataset.reciprocal_space_files.last.file.attach(io: File.open(iofq_3column), filename: "iofq_#{submission.bioisis_id}.dat")
              dataset.save
            end

            #
            # check for PofR file
            #
            if File.exist? pofr # validate three columns
              dmax = getLastPofRLine(pofr)
              #
              rcp = submission.experiment.data_sets[0].reciprocal_space_files.last
              real = RealSpaceFile.new(method: "GNOM", dmax: dmax.to_f, reciprocal_space_file_id: rcp.id)
              real.file.attach(io: File.open(pofr), filename: "pofr_#{submission.bioisis_id}.dat")
              real.json = sascif.to_json

              unless real.save
                puts real.errors.inspect
              end

            else
              puts "no PofR #{subdirectory}"
            end
          end

          image = "#{saxs_data_dir}/#{subdirectory}/low_res_thumbnail.png"
          if File.exists? image
            puts image
            submission.experiment.figure.attach(io: File.open(image), filename: "figure.png")
          else
            image = "#{saxs_data_dir}/#{subdirectory}/med_res_kratky.png"
            if File.exists? image
              submission.experiment.figure.attach(io: File.open(image), filename: "figure.png")
            else
              image = "#{saxs_data_dir}/SAXS-default.png"
              submission.experiment.figure.attach(io: File.open(image), filename: "figure.png")
            end

          end

          # submission.status = true # true means completed, false means pending
          # submission.experiment.status = false # @submission.status = true and experiment.status = false means unapproved
          submission.status = true
          submission.experiment.approved = true
          submission.experiment.state = "published"
          submission.save

        end
      end # if BID exists
    end # end of parsing summary.txt file in data_directory

  end # end of directory entries

  # associate dataset with data file
end
# create_table "news", force: :cascade do |t|
#   t.integer "user_id", null: false
#   t.string "title"
#   t.text "journal_info"
#   t.text "abstract"
#   t.text "notes"
#   t.string "category"
#   t.string "link"
#   t.datetime "created_at", precision: 6, null: false
#   t.datetime "updated_at", precision: 6, null: false
#   t.date "publication_date"
# end
#
#
