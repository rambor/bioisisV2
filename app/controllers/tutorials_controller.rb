class TutorialsController < ApplicationController

  def index

    respond_to do |format| #this is REST web-service support telling the server to respond (respond_to) in one of two formats depending on the request
      format.html { render :action => "index"}
    end
  end

  def show
#    @versionhistory = ScatterUpdate.find(:all)
#    @versionhistory =  ScatterUpdate.order('created_at DESC')
    @version_history =  Scatter.order(:created_at => :desc).all

    respond_to do |format|
      format.html { render :action => "show"}
    end
  end



end
