class SubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_submission, only: [:save_and_exit, :show, :edit, :update, :destroy, :review, :completed, :approve]

  # GET /submissions
  # GET /submissions.json
  def index

    @submissions = Submission.all
    authorize! :manage, @submissions
  end

  # GET /submissions/1
  # GET /submissions/1.json
  def show
    authorize! :manage, @submissions
  end

  # GET /submissions/new
  def new
    @submission = Submission.new
    @submission.email = current_user.email
    @submission.user_id = current_user.id
  end

  # GET /submissions/1/edit
  def edit
    # @submission = Submission.find_by_data_directory(params[:id])
    authorize! :edit, @submission

    if @submission.status
      redirect_to completed_url(:id => @submission.data_directory), notice: 'Submission was already completed.'
    else

      @experiment = Experiment.find_by_submission_id(@submission.id)
      @experiment.valid?

      if @experiment.data_sets.size == 0
        @experiment.errors.add(:data_sets, "dataset required")
      end

      unless @experiment.figure.attached?
        @experiment.errors.add(:figure, "missing supporting figure")
      end

      # check if any dataset is empty with respect to data files
      @total_attached_files = 0
      if @experiment.data_sets.size > 0
        @experiment.data_sets.each do |ds|
          if ds.reciprocal_space_files.size == 0
            @experiment.errors.add(:data_files, "DataSet missing Reciprocal-Space Files")
            @total_attached_files = 0
            break
          else
            @total_attached_files += ds.reciprocal_space_files.size
          end
        end
      end

      if @experiment.figure.attached?
        @experiment.errors.add(:figure, "Missing Supporting Figure")
      end
    end

  end

  def bid_lookup

    @code = params[:bioisis_id].upcase

    @use_code = true
    if @code.size == 6
      exps = Experiment.search(@code).size
      subs = Submission.search(@code).size
      if exps > 0 || subs > 0
        @use_code = false
      end
    else
      @use_code = false
    end

    respond_to do |format|
      format.js
    end
  end

  def complete

    permitted = params.permit(:submission_id, :experiment_id, :bioisis_id, :release_date)

    @submission = Submission.find_by(:id => permitted[:submission_id])
    authorize! :manage, @submission

    @continue_on = true
    begin
      Date.parse(permitted[:release_date])
    rescue
      @continue_on = false
      @submission.errors.add(:release_date, "Improperly formatted date #{permitted[:release_date]}")
    end

    if permitted[:bioisis_id].size != 6
      @continue_on = false
      @submission.errors.add(:bioisis_id, "BioIsisID too short, needs to be 6 characters #{permitted[:bioisis_id]}")
    end

    unless Experiment.find_by_bioisis_id(permitted[:bioisis_id].upcase).nil?
      @continue_on = false
      @submission.errors.add(:bioisis_id, "ID not unique, choose another => #{permitted[:bioisis_id]}")
    end

    respond_to do |format|
      if permitted.permitted? && @continue_on

        @experiment = Experiment.find_by(:id => permitted[:experiment_id])
        @submission.bioisis_id = permitted[:bioisis_id].upcase
        @submission.status = true # true means completed, false means pending
        @experiment.bioisis_id = permitted[:bioisis_id].upcase
        @experiment.status = false # @submission.status = true and experiment.status = false means unapproved
        @experiment.release_date = permitted[:release_date]

        if @submission.save && @experiment.save
          #NotifierMailer.with(submission: @submission).registration.deliver
          format.html {redirect_to completed_path(:id => @submission.data_directory), notice: 'Submission was successfully completed.' }
        else
          format.js {render :submission_errors}
          # format.html {render :submission_error, notice: 'Submission was not successful, please contact admin'}
        end
      else
        format.js {render :submission_errors}
        # format.html {render :submission_error, notice: 'Submission was not successful, please contact admin'}
        # format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  def completed
    respond_to do |format|
      format.html {render :completed}
    end
  end

  def pending
    #
    # load submissions with status = 0 that do not have a corresponding entry in Experiments
    # experiments that are not approved but completed
    # experiments.approved = false
    # experiments.status = 0
    # submission.status =
    #
    #@pagy, @submissions = pagy(Submission.where(:status => 1), items:10)
    @pagy, @submissions = pagy(Submission.where(:status => true, experiment: Experiment.where(["status = ? and approved = ?", false, false])).includes(:experiment), items:10)
    authorize! :manage, @submissions
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def active

    @pagy, @submissions = pagy(Submission.where(:status => 0), items:10)

    respond_to do |format|
      format.html {render :pending}# index.html.erb
    end
  end

  def view_archive
    permitted = params.permit(:archive_id)
    if permitted.permitted?
      @archive = Archive.find_by(params[:archive_id])
      respond_to do |format|
        format.js # index.html.erb
      end
    end

  end

  def review
    authorize! :manage, @submissions
    @experiment = Experiment.find_by_submission_id(@submission.id)
  end

  def approve

    resolved=0

    @submission&.comments.each do |comment|
      unless comment.resolved
        resolved += 1
      end
    end

    @submission.status = true
    @submission.experiment.approved = true
    @submission.experiment.bioisis_id = @submission.bioisis_id

    # if @submission.experiment.release_date <= Date.today
    #
    # end

    respond_to do |format|
      if resolved == 0 && @submission.save # can not approve submission, unresolved issues remain
        @experiment = @submission.experiment
        format.html
      else
        format.html { redirect_to root_path }
      end
    end

  end

  # POST /submissions
  # POST /submissions.json
  def create
    #
    @submission = Submission.new(submission_params)
    #
    # add current_user id to @submission, must be logged in
    #
    @submission.user_id = current_user.id
    @submission.status = false # false means not submitted and is editable by user
    #
    # Create data directory
    #
    @submission.data_directory = Time.now.to_i.to_s
    #directory = Rails.root.join("public", "BIDRECORDS", @submission.data_directory)
    @submission.editing_count = 1
    #Dir.mkdir(directory)
    #
    # Write out blank Summary file
    #
    respond_to do |format|
      if @submission.save
        #
        # Send email link
        #
        @submission.create_experiment(:description => "Please Provide a Description via EDIT DETAILS", :title=>"Please provide a suitable title via EDIT DETAILS", :user_id => @submission.user_id, :state => "unpublished")
        # set default user
        user = User.find_by(:id =>  @submission.user_id)
        @submission.experiment.contributors.create(:last_name => user.last_name, :given_names=> user.first_name)
        @submission.save

        NotifierMailer.with(submission: @submission).registration.deliver
        #NotifierMailer.registration(@submission).deliver
        format.html { redirect_to edit_submission_path(:id => @submission.data_directory), notice: 'Submission was successfully created.' }
        format.json { render :show, status: :created, location: @submission }
        # format.html { redirect_to(@submission, :notice => 'Submission registration was successful. Please check your email account!') }
        # format.xml  { render :xml => @submission, :status => :created, :location => @submission }
      else
        format.html { render :new }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
        # format.html { render :action => "new" }
        # format.xml  { render :xml => @submission.errors, :status => :unprocessable_entity }
      end
    end


    # @submission = Submission.new(submission_params)
    #
    # respond_to do |format|
    #   if @submission.save
    #     format.html { redirect_to @submission, notice: 'Submission was successfully created.' }
    #     format.json { render :show, status: :created, location: @submission }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @submission.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /submissions/1
  # PATCH/PUT /submissions/1.json
  def update
    respond_to do |format|
      if @submission.update(params.require(:submission).permit(:email))
        format.html { redirect_to @submission, notice: 'Submission was successfully updated.' }
        format.json { render :show, status: :ok, location: @submission }
      else
        format.html { render :edit }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /submissions/1
  # DELETE /submissions/1.json
  def destroy
    @submission.destroy
    respond_to do |format|
      format.html { redirect_to submissions_url, notice: 'Submission was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def save_and_exit
    #
    # Write contents to file, send an email and redirect user
    #
    authorize! :modify, @submission

    NotifierMailer.with(submission: @submission).save_and_exit.deliver
    respond_to do |format|
      format.text {render 'save_and_exit'}
      format.html
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_submission
      @submission = Submission.find_by_data_directory(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def submission_params
      params.require(:submission).permit(:email)
        #params.fetch(:submission, {})
    end

end
