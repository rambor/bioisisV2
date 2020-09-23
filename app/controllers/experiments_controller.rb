class ExperimentsController < ApplicationController
  before_action :set_experiment, only: [:show, :edit, :update, :destroy]
  # GET /experiments
  # GET /experiments.json
  def index
    @title = "Most Recent"
    @pagy, @experiments = pagy(Experiment.where(approved: true).order(created_at: :desc))
  end

  # GET /experiments/1
  # GET /experiments/1.json
  def by_material

    index = params[:id].to_i
    case index
    when 0
      @title = "Protein"
      @pagy, @experiments = pagy(Experiment.joins(data_sets: [:materials]).where(materials: {material: "protein"}, approved: true).order(created_at: :desc))
    when 1
      @title = "Lipids"
      @pagy, @experiments = pagy(Experiment.joins(data_sets: [:materials]).where(materials: {material: "lipids"}, approved: true).or(Experiment.joins(data_sets: [:materials]).where(materials: {material: "detergents"}, approved: true)).order(created_at: :desc))
    when 2
      @title = "Surfactants"
      @pagy, @experiments = pagy(Experiment.joins(data_sets: [:materials]).where(materials: {material: "surfactants"}, approved: true).order(created_at: :desc))
    when 3
      @title = "RNA Related"
      @pagy, @experiments = pagy(Experiment.joins(data_sets: [:materials]).where(materials: {material: "RNA"}, approved: true).order(created_at: :desc))
    when 4
      @title = "DNA Related"
      @pagy, @experiments = pagy(Experiment.joins(data_sets: [:materials]).where(materials: {material: "DNA"}, approved: true).order(created_at: :desc))
    when 5
      @title = "Carbohydrates and Glycosylated"
      @pagy, @experiments = pagy(Experiment.joins(data_sets: [:materials]).where(materials: {material: "carbohydrates"}, approved: true).or(Experiment.joins(data_sets: [:materials]).where(materials: {material: "glycosylated"}, approved: true)).order(created_at: :desc))
    when 6
      @title = "Gels"
      @pagy, @experiments = pagy(Experiment.joins(data_sets: [:materials]).where(materials: {material: "gels"}, approved: true).or(Experiment.joins(data_sets: [:materials]).where(materials: {material: "glycosylated"}, approved: true)).order(created_at: :desc))
    when 7
      @title = "Other"
      @pagy, @experiments = pagy(Experiment.joins(data_sets: [:materials]).where(materials: {material: "other"}, approved: true).order(created_at: :desc))
    else
      @pagy, @experiments = pagy(Experiment.where(approved: true))
    end

    respond_to do |format|
      format.html { render "index" } # new.html.erb
    end
  end

  # GET /experiments/1
  # GET /experiments/1.json
  def show

  end

  # GET /experiments/1/edit
  def admin_list
    @pagy, @experiments = pagy(Experiment.order(:id => :desc).all)

    authorize! :manage, @experiments
    respond_to do |format|
      format.html { render :action => "admin_list" } # new.html.erb
      format.xml  { render :xml => @experiment }
    end
  end

  # GET /experiments/new
  def new
    @experiment = Experiment.new
  end

  def remove_contributor

    @contributor = Contributor.find_by(:id => params[:id])
    @con_tag ="contributor_#{@contributor.id}"
    @experiment = Experiment.find_by(:id => @contributor.experiment.id)

    respond_to do |format|
      if @contributor.destroy
        format.js
      else
        format.html{ render :edit, :id => @experiment.id }
      end
    end
  end

  def add_contributor

    @contributor = Contributor.new(params.require(:contributor).permit(:last_name, :given_names, :experiment_id))
    permitted = params.permit(:tr_to_remove, :id)
    @experiment = Experiment.find_by(:id => permitted[:id])
    @contributor.experiment_id = @experiment.id
    @tr_to_remove = permitted[:tr_to_remove]

    #
    if @contributor.save
      @success = true
    else
      @success = false
    end

    respond_to do |format|
      format.js
    end
  end

  # GET /experiments/1/edit
  def edit
    # set experiment before_action loads @experiment
    @experiment = Experiment.find_by(:id => params[:id])
    @status_of = [['unpublished', 'unpublished'], ['thesis', 'thesis'],['journal','journal']]
    @total_rows = (!@experiment.description.nil? && @experiment.description.size > 140) ? (@experiment.description.size/74.0).ceil : 6
    if @experiment.publications.size == 0
      @experiment.publications << Publication.new
    end
  end

  def add_figure
    @experiment = Experiment.find_by(:id => params[:id])
    @total_rows = (!@experiment.description.nil? && @experiment.description.size > 140) ? (@experiment.description.size/74.0).ceil : 2
  end


  def add_supporting_file
    @experiment = Experiment.find_by(:id => params[:id])

  end

  def upload_figure
    @experiment = Experiment.find_by(:id => params[:id])

    respond_to do |format|
      if @experiment.update(params.require(:experiment).permit(:description, :figure))
        # use JSON to upload image to the form
        format.js { redirect_to  edit_submission_path(:id =>@experiment.submission.data_directory) }
      else
        format.js { render 'errors'}
      end
    end
  end
  # <%= render  :partial => "mini_scatter_plot", locals: {data_to_plot: experiment.get_random_data_to_plot} %>
  def doi_lookup
    Serrano.configuration do |config|
      config.mailto = "robert_p_rambo@hotmail.com"
    end

    permitted = params.require(:experiment).permit(:publication_doi, :experiment_id)
    @publication = Publication.new
    @contributors =[]

    if permitted.permitted?

      address = params[:experiment][:publication_doi].strip
      # 10.1146/annurev-biophys-083012-130301
      if address =~ /https?:\/\/doi\.org\// || address =~ /[0-9]+\.[0-9]+\/[A-Za-z0-9]+/

        if address[0] == "/" # assume it is /10.1109/5.771073
          address = address[1..-1]
        end

        unless address.include?("http")
          address = "https://doi.org/#{address}"
        end

        query = Serrano.works(ids: address)
        if query.size > 0 && query[0]["status"].downcase == "ok"
          info = query[0]["message"]
          @publication.container_title = info["container-title"][0]
          @publication.title = info["title"][0]
          @publication.volume = info["volume"]
          @publication.issue = info["issue"]
          @publication.year = info["issued"]["date-parts"][0][0].to_i
          @publication.page = info["page"]
          @publication.url = address


          # remove all prior contributors
          #@experiment = Experiment.find_by(:id => params[:experiment][:id])

          if info["author"].size > 0
            authors = info["author"]
            authors.each do |ath|
              unless ath["given"].nil? && ath["family"].nil?
                @contributors << Contributor.new(last_name: ath["family"], given_names: ath["given"], experiment_id: params[:experiment_id]);
              end
            end
          end

          month = info["issued"]["date-parts"][0][1]
          if month > 0 && month < 12
            @publication.month = month
          elsif month.is_a? String
            if month.size <3 && month =~ /^[0-9]{1,2}[:.,-]?$/
              @publication.month = month.to_i
            elsif month =~ /[A-Za-z]+/
              @publication.month = getMonth(month)
            end
          end
        end
      end

      puts "PERMITTED DOI LOOKUP :: #{params[:experiment][:publication_doi]}"

      render 'publication.js.erb'
    end
  end

  # POST /experiments
  # POST /experiments.json
  # def create
  #   @experiment = Experiment.new(experiment_params)
  #
  #   respond_to do |format|
  #     if @experiment.save
  #       format.html { redirect_to @experiment, notice: 'Experiment was successfully created.' }
  #       format.json { render :show, status: :created, location: @experiment }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @experiment.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /experiments/1
  # PATCH/PUT /experiments/1.json
  def update
    respond_to do |format|
      if @experiment.update(experiment_params)
        format.html { redirect_to deposition_path(:id => @experiment.submission.data_directory), notice: 'Experiment was successfully updated.' }
        #format.json { render :show, status: :ok, location: @experiment }
      else
        format.html { render :edit }
        format.json { render json: @experiment.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end



  # DELETE /experiments/1
  # DELETE /experiments/1.json
  def destroy
    @experiment.destroy
    respond_to do |format|
      format.html { redirect_to experiments_url, notice: 'Experiment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_experiment
    @experiment = Experiment.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def experiment_params
    params.require(:experiment).permit(:description, :title, :state, :publication, :publication_doi, publications_attributes: [:id, :container_title, :title, :volume, :issue, :page, :year, :month])
  end

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
end
