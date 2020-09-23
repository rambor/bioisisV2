class ScattersController < ApplicationController
  before_action :authenticate_user!

  def new
    @update = Scatter.new
    # comments (changelog)
    # version number
    authorize! :manage, @update

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def download_file
    @last_time_download = ScatterDownload.where(:user_id => current_user.id).order("created_at").last
    last_time = (Time.now - @last_time_download.created_at).to_i

    if last_time > 24*60*60 || @last_time_download.version != Scatter.last.version
      # use JSON to upload image to the form
      respond_to do |format|
        format.html { redirect_to scatter_download_path,  notice: 'Must Agree' }
      end
    else
      version = Scatter.last.version.gsub(/\./,"_")
      send_data Scatter.last.zip_file.download, type: 'application/zip', disposition: "attachment; filename=scatter_#{version}.zip", status: 202
    end

  end

  def validate_download

    @last_time_download = ScatterDownload.where(:user_id => current_user.id).order("created_at").last
    last_time = (Time.now - @last_time_download.created_at).to_i

    allow_download = (last_time < 24*60*60 || @last_time_download.version != Scatter.last.version) ? true : false

    respond_to do |format|
      msg = { :status => "ok", :allow_download => allow_download }
      format.json  { render :json => msg } # don't do msg.to_json
    end
    #   respond_to do |format|
    #     if last_time > 0 || @last_time_download.version != Scatter.last.version
    #       # use JSON to upload image to the form
    #       format.html { redirect_to scatter_download_path  }
    #     else
    #       format.html {head :no_content }
    #       #send_data Scatter.last.zip_file.download, type: 'application/zip', disposition: 'attachment; filename=scatterIV.zip', status: 202
    #     end

  end

  def agree_to_download

    permitted = params.require(:scatter_download).permit(:principal_investigator, :institution, :country, :status, :email, :terms_of_service)

    @rcp = ScatterDownload.new(permitted)
    @rcp.user_id = current_user.id
    @rcp.ip_address = request.remote_ip
    @latest = Scatter.last
    @rcp.version = @latest.version
    @rcp.scatter_id = @latest.id

      # response.headers["Content-Type"] = Scatter.last.zip_file.content_type
      # zipname = "scatterIV.zip"
      # disposition = ActionDispatch::Http::ContentDisposition.format(disposition: "attachment", filename: zipname)
      # response.headers["Content-Disposition"] = disposition
      # response.headers["Content-Type"] = "application/zip"

      #send_data Scatter.last.zip_file.download, type: 'application/zip', disposition: 'attachment', filename: "scatterIV.zip"

      respond_to do |format|
        if @rcp.terms_of_service && @rcp.save
          @scatter = Scatter.last
          format.js {render :get_download}
        else
          @rcp.errors.add(:agree, "Please agree to terms of use") unless @rcp.terms_of_service
          format.js {render :errors}
        end
      end

  end


  def download
    respond_to do |format|
      format.html {render "request_download"}
    end
  end

  def create
    @scatter = Scatter.new(params.require(:scatter).permit(:title, :version, :comments, :email_users, :zip_file))

    authorize! :manage, @scatter
    @last_scatter = (Scatter.all.size > 1) ? Scatter.last : nil

    file_size = @scatter&.zip_file.byte_size/(1024.0*1024.0)
    if file_size > 10 # uploaded file should be at least 10 MB

      if @scatter.save
        if Scatter.all.size > 1
          @last_scatter.zip_file.purge # remove attachment
          @last_scatter.save
        end

        redirect_to experiments_admin_list_path, :notice => 'Successfully updated Scatter'
      else
        flash[:error] = @scatter.errors.inspect
        render 'new'
      end
    end
  end
end
