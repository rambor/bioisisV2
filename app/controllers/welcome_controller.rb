class WelcomeController < ApplicationController
  def index
    @featured_experiment = Experiment.find_by(id: 1)

    @latest = Experiment.where(approved: true).order(created_at: :desc).limit(5)
    @news = News.all.order(created_at: :desc).limit(4)
    #
    #    @total_SAXS = Experiment.find(:all).size


  end
end
