class RealSpaceFilesController < ApplicationController
  protect_from_forgery except: :view

  def view
    # open file and load data
    #
    # :dataset_id => data_set.id, :file_id => rcp.real_space_file.id
    #
    permitted = params.permit(:dataset_id, :file_id)
    permitted.permitted?
    real_space_file = RealSpaceFile.find_by(:id => permitted[:file_id])
    blob = real_space_file.file

    @data_to_plot = PofrData.new(:file_blob => blob)
    @data_to_plot.read_contents

    blob.open do |tempfile|
      @data_to_plot.filename = blob.filename
      @data_to_plot.read_contents
      @ymin = @data_to_plot.pr_min # signif(@data_to_plot.y_min,3)
      @ymax = signif(@data_to_plot.pr_max + (@data_to_plot.pr_max*0.01).abs,3)
    end

    render "view_pr.js.erb", format: :js, layout: false
  end


  def destroy

    permitted = params.permit(:file_id, :dataset_id)
    permitted.permitted?

    to_destroy = RealSpaceFile.find_by(:id => permitted[:file_id])
    @id_to_remove = permitted[:file_id]
    rcp_id = to_destroy.reciprocal_space_file.id

    respond_to do |format|
      if to_destroy.destroy

        @rcp = ReciprocalSpaceFile.find_by(:id => rcp_id)
        @data_set = @rcp.data_set

        format.js { render :remove_real_space_file }
      else

      end
    end

  end
end
