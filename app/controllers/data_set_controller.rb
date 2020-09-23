class DataSetController < ApplicationController
  before_action :set_data_set, only: [:edit, :get_data_to_plot, :view_data_file, :remove_file, :add_real_space_file]

  def add
    @experiment = Experiment.find_by_id(params[:id])
    @data_set = DataSet.new
    @data_set.experiment = @experiment

    @data_set.buffer=""
    respond_to do |format|
      format.html { render :add_or_edit_data_set}
    end
  end

  # pass in the Dataset ID that data files are being added to
  def add_datafile
    @data_set = DataSet.find_by(:id=>params[:id])

    respond_to do |format|
      format.html
      format.js
    end
  end


  def view

    @data_set = DataSet.find_by(:id=>params[:id])
    @data_directory = @data_set.experiment.submission.data_directory
    @submission = @data_set.experiment.submission

    respond_to do |format|
      format.html
      format.js
    end
  end


  def create

    @experiment = Experiment.find_by_id(params[:id])
    @data_set = DataSet.new(data_set_params)
    @data_set.experiment = @experiment # set the experiment
    #
    # must validate file before saving
    # file has to be either dat file (3 columns) or formatted *.sec or zip file of dats
    #
    if @data_set.save
      redirect_to edit_submission_path(:id => @experiment.submission.data_directory), notice: "DataSet created, please add dat files"
    else
      puts @data_set.errors.inspect
      respond_to do |format|
        format.html { render 'add_or_edit_data_set'  }
        format.js {render 'errors'}
      end
    end

  end

  def edit

    @experiment = @data_set.experiment

    respond_to do |format|
      format.html { render :add_or_edit_data_set, notice: "Book not found"}
    end
  end



  def update_data_set

    @data_set = DataSet.find_by(:id => params[:id])

    if @data_set.update(data_set_params)
      redirect_to edit_data_set_path(:dataset_id => @data_set.id), notice: "Updated DataSet"
    else
      respond_to do |format|
        format.html { render 'add_or_edit_data_set'  }
        format.js {render 'update.js.erb'}
      end
    end
  end


  # Uploads and saves reciprocal space file to the experiment via DataSet Model
  def upload_data_file

    @data_set = DataSet.find_by(:id => params[:id])
    permitted = params.require(:data_set).permit(reciprocal_space_file: [:sas_type, :file])

    if permitted.permitted?
      @rcp = @data_set.reciprocal_space_files.create(permitted[:reciprocal_space_file])
      #@rcp = ReciprocalSpaceFile.new(data_set_id: @data_set.id, file: permitted[:reciprocal_space_file][:file], sas_type: permitted[:reciprocal_space_file][:sas_type])

      unless @rcp.errors.any?
        # grab JSON string from file if present
        @rcp.json = SasCif.new(:file => @rcp.file).get_json
        #@data_set.reciprocal_space_files << @rcp
      end
    end
    #
    # must validate file before saving
    # file has to be either dat file (3 columns) or formatted *.sec or zip file of data
    #
    puts @data_set.errors.inspect

    respond_to do |format|
      if @data_set.save
        @rcp = @data_set.reciprocal_space_files.last
        #format.html { redirect_to edit_data_set_path, :id => add_datafile_path(:id => @data_set.id)  }
        format.js
      else
        puts @data_set.errors.inspect
        format.html { render 'add_or_edit_data_set', notice: "Error in Uploaded File"  }
        format.js { render 'errors'}
      end
    end

  end


  def destroy
    # file = DataFile.find_by(:id => params[:file_id])
    # puts "File to Delete #{params[:file_id]} #{file.name}"
    @experiment = Experiment.find_by(:id => params[:id])

    data_set = @experiment.data_sets.find_by(:id => params[:dataset_id])

    if data_set.reciprocal_space_files.size > 0
      data_set.reciprocal_space_files.each do |rcp|
        rcp.file.purge
        rcp.destroy
      end
    end

    #data_file = @experiment.data_files.find_by(:id => params[:file_id])
    #
    # data_file = ActiveStorage::Blob.find_data_file(params[:file_id])
    #
    data_set.destroy

    respond_to do |format|
      format.html { redirect_to deposition_path(:id => @experiment.submission.data_directory), :id => params[:id] }
    end
  end

  def add_real_space_file
    permitted = params.permit(:reciprocal_space_file_id)
    @rcp = @data_set.reciprocal_space_files.find_by(:id => permitted[:reciprocal_space_file_id])
    # make new real space association
    respond_to do |format|
      format.js { render :add_real_space_file }
    end
  end


  def upload_real_space_file

    permitted = params.require(:real_space_file).permit(:reciprocal_space_file_id, :dmax, :method, :file)

    if permitted.permitted?
      @rcp = ReciprocalSpaceFile.find_by(:id => permitted[:reciprocal_space_file_id])

      @data_set = DataSet.find_by(:id => @rcp.data_set_id)
      if @rcp.real_space_file.nil?
        @rcp.build_real_space_file(permitted)
      else
        @rcp.real_space_file.destroy
        @rcp.build_real_space_file(permitted)
      end
    end

    respond_to do |format|
      if @rcp.save
        format.js { render :upload_real_space_file }
      else
        format.js { render  :template => "real_space_files/errors.js.erb", :layout => false }
      end
    end

  end


  def get_data_to_plot
    permitted = params.permit(:file_id)
    blob = get_blob(@data_set, permitted[:file_id])
    blob_ext = blob.filename.extension
    @data_to_plot = ScatterData.new(:cols => [0,1])

    blob.open do |tempfile|
      @data_to_plot.file = tempfile
      @data_to_plot.filename = blob.filename

      if blob_ext == "sec"
        @data_to_plot.read_sec_file
        @ymin = @data_to_plot.y_min # signif(@data_to_plot.y_min,3)
        @ymax = signif(@data_to_plot.y_max + (@data_to_plot.y_max*0.01).abs,3)
      else
        @data_to_plot.read_contents
        @ymin_log = signif(@data_to_plot.y_min_log,3)
        @ymax_log = signif(@data_to_plot.y_max_log + (@data_to_plot.y_max_log*0.05).abs,3)

        @ymin = signif(@data_to_plot.y_min,3)
        @ymax = signif(@data_to_plot.y_max + (@data_to_plot.y_max*0.05).abs,3)

        @xymin = (@data_to_plot.xy_min > 0) ? 0 : signif(@data_to_plot.y_min,3)
        @xymax = signif(@data_to_plot.xy_max + (@data_to_plot.xy_max*0.05).abs,3)
      end

    end

    # puts "#{params[:file_id]}"
    # ActiveStorage::Blob.service.send(:path_for, @data_set.files.find_by(:id => params[:file_id]))
    respond_to do |format|
        format.html { render :view_data_file }
        format.js { render :view_data_file }
    end
  end

  # for viewing data during submission, sec file not fully validated requiring exception handler
  def view_data_file
    permitted = params.permit(:file_id, :data_set_id)
    blob = get_blob(@data_set, permitted[:file_id])
    @data_to_plot = ScatterData.new(:cols => [0,1])

    begin

      blob.open do |tempfile|

        @data_to_plot.file = tempfile
        @data_to_plot.filename = blob.filename

        if blob.filename.extension == "sec"
          @data_to_plot.is_subtracted = false
          @data_to_plot.read_sec_file
          @ymin = @data_to_plot.y_min # signif(@data_to_plot.y_min,3)
          @ymax = signif(@data_to_plot.y_max + (@data_to_plot.y_max*0.01).abs,3)
        else
          @data_to_plot.is_subtracted = @data_set.reciprocal_space_files.find_by(:id => permitted[:file_id]).sas_type
          @data_to_plot.read_contents
          @ymin_log = signif(@data_to_plot.y_min_log,3)
          @ymax_log = signif(@data_to_plot.y_max_log + (@data_to_plot.y_max_log*0.05).abs,3)

          puts "min max log #{@ymin_log} #{@ymax_log} #{@data_to_plot.xy_max}"

          @ymin = signif(@data_to_plot.y_min,3)
          @ymax = signif(@data_to_plot.y_max + (@data_to_plot.y_max*0.05).abs,3)

          if @data_to_plot.is_subtracted && @data_to_plot.xy_min > 0
            @data_to_plot.xy_min = 0
          end
        end
      end

    rescue StandardError => e
      puts "RESCUING #{e}"
      @data_set.errors.add(:base, e)
    end

    # ActiveStorage::Blob.service.send(:path_for, @data_set.files.find_by(:id => params[:file_id]))
    respond_to do |format|
      if @data_set.errors.any?
        format.html { redirect_to :add_datafile, :id => permitted[:data_set_id]}
      else
        # format.html { render :view_data_file }
        format.js
      end
    end

  end


  def remove_file
    # file = DataFile.find_by(:id => params[:file_id])
    permitted = params.permit(:file_id, :data_set_id)
    rcp_data_file = @data_set.reciprocal_space_files.find_by(:id => permitted[:file_id])
    @file_tag = "file_#{permitted[:file_id]}"

    unless rcp_data_file.real_space_file.nil?
      @real_space_file_to_remove = rcp_data_file.real_space_file.id
    end
    #
    respond_to do |format|
      if rcp_data_file.destroy
        format.html { render :add_datafile, :id => permitted[:data_set_id] }
        format.js
      else
        format.html { redirect_to :add_datafile, :id => permitted[:data_set_id] }
      end
    end

  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_data_set
    @data_set = DataSet.find_by(:id => params[:dataset_id])
  end

  def get_blob(data_set, id)
    data_set.reciprocal_space_files.find_by(:id => id).file
      #data_set.files.find_by(:id => id)
  end

  # Only allow a list of trusted parameters through.
  def data_set_params
    params.require(:data_set).permit(:name, :description, :buffer, :source, :instrument_name, material_ids:[])
    #params.require(:experiment).permit(data_file_attributes: [:sas_type, :name, :description, :buffer, files: []])
  end

end
