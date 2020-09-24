class NewsController < ApplicationController
  before_action :set_news, only: [:show, :edit, :update, :destroy]

  # GET /news
  # GET /news.json
  def index
    @pagy, @news = pagy(News.order(:id => :desc).all)
  end

  # GET /news/1
  # GET /news/1.json
  def show
  end

  # GET /news/new
  def new
    @news = News.new
    authorize! :manage, @news
  end

  # GET /news/1/edit
  def edit
    authorize! :manage, @news
  end

  # POST /news
  # POST /news.json
  def create
    @news = News.new(news_params)
    authorize! :manage, @news
    @news.user_id = current_user.id

    respond_to do |format|
      if @news.save
        format.html { redirect_to @news, notice: 'News was successfully created.' }
        format.json { render :show, status: :created, location: @news }
      else
        format.html { render :new }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /news/1
  # PATCH/PUT /news/1.json
  def update
    authorize! :manage, @news
    respond_to do |format|
      if @news.update(news_params)
        format.html { redirect_to @news, notice: 'News was successfully updated.' }
        format.json { render :show, status: :ok, location: @news }
      else
        format.html { render :edit }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news/1
  # DELETE /news/1.json
  def destroy
    authorize! :manage, @news
    @news.destroy
    respond_to do |format|
      format.html { redirect_to news_index_url, notice: 'News was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  def reviews
    #Person.exists?(['name LIKE ?', "%#{query}%"])
    @pagy, @news = pagy(News.order(:created_at => :desc).where("category LIKE '%review%'"))
    respond_to do |format|
      format.html
    end
  end

  def articles
    @pagy, @news = pagy(News.order(:created_at => :desc).where("category LIKE '%article%'"))
    respond_to do |format|
      format.html
    end
  end

  def updates
    @pagy, @news = pagy(News.order(:created_at => :desc).where("category LIKE '%updates%'"))
    puts "total news #{@news.size}"
    respond_to do |format|
      format.html {render :general_info}
    end
  end

  def general_info
    @pagy, @news = pagy(News.order(:created_at => :desc).where("category LIKE '%general%'"))
    respond_to do |format|
      format.html
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_news
      @news = News.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def news_params
      params.require(:news).permit(:title, :journal_info, :category, :abstract, :link, :notes, :figure, :publication_date)
    end
end
