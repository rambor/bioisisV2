class ArchiveController < ApplicationController

  def new
    @experiment = Experiment.find_by(:id => params[:id])
    @archive = Archive.new
    @archive.experiment = @experiment

    render :add_or_edit_supporting_archive
  end

  def create
    @experiment = Experiment.find_by(:id => params[:id])
    @archive = Archive.new(params.require(:archive).permit(:description, :zip_file))
    @archive.experiment = @experiment

    respond_to do |format|
      if @archive.save
        format.js { render 'create'}
      else
        format.html { render 'add_or_edit_supporting_archive', notice: "Error in File"  }
        format.js { render 'errors'}
      end
    end
  end

  def edit
    @archive = Archive.find_by(:id => params[:id])
    @experiment = @archive.experiment
  end

  def update
    @archive = Archive.find_by(:id => params[:id])
    @experiment = @archive.experiment


    if @archive.update(params.require(:archive).permit(:description))
      redirect_to( edit_submission_path(:id => @experiment.submission.data_directory))
    else
      respond_to do |format| # using delete since there are no callbacks on the archive
        format.html { render "edit" }
        format.js
      end
    end
  end

  def remove
    # file = DataFile.find_by(:id => params[:file_id])
    @archive = Archive.find_by(:id => params[:id])
    @experiment = @archive.experiment
    @submission = @experiment.submission
    #data_file = @experiment.data_files.find_by(:id => params[:file_id])
    #
    # data_file = ActiveStorage::Blob.find_data_file(params[:file_id])
    #
    # data_file = DataFile.find_by_id(params[:file_id])
    # data_file.destroy
    #
    @archive_tag = "archive_#{@archive.id}"
    respond_to do |format| # using delete since there are no callbacks on the archive
      if Archive.find(@archive.id).destroy
        puts "redirecting to "
        format.html { redirect_to edit_submission_path(:id => @experiment.submission.data_directory)}
        format.js
      else
        format.html { render edit_submission_path(:id => @experiment.submission.data_directory) }
        format.js
      end
    end
  end

end
