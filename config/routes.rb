Rails.application.routes.draw do

  resources :news
  get 'deposition/:id', :to => 'submissions#edit', :as => :deposition
  get 'submissions/save_and_exit/:id', :to => 'submissions#save_and_exit', :as => :save_and_exit
  post 'submissions/:id/bid_lookup', :to => 'submissions#bid_lookup', :as => :bid_lookup
  post 'submissions/complete', :to => 'submissions#complete', :as => :complete_submission
  get 'submissions/completed/:id', :to => 'submissions#completed', :as => :completed

  get 'submissions/pending', :to => 'submissions#pending', :as => :pending_submissions
  get 'submissions/active', :to => 'submissions#active', :as => :active_submissions
  get 'submissions/:id/review', :to => 'submissions#review', :as => :review_submission
  get 'submissions/:id/approve', :to => 'submissions#approve', :as => :approve_submission

  post 'submissions/:id/archive', :to => 'submissions#view_archive', :as => :view_archive
  post 'submissions/:id/submit_review', :to => 'submission#submit_review', :as => :submit_review

  get 'data_set/:id/view', :to => 'data_set#view', :as => :view_data_set
  post 'data_set/:id/get_data_to_plot', :to => 'data_set#get_data_to_plot', :as => :view_data_plot

  resources :submissions
  resources :comments

  #devise_for :users
  get 'experiments/admin_list', :to => 'experiments#admin_list', :as => :experiments_admin_list
  get 'experiments/by_material/:id', :to => 'experiments#by_material', :as => :experiments_by_material
  resources :experiments
  get 'welcome/index'

  get 'data_set/add/:id', :to => 'data_set#add', :as => :add_data_set
  get 'data_set/edit/:id', :to => 'data_set#edit', :as => :edit_data_set
  post 'data_set/create/:id', :to => 'data_set#create', :as => :create_data_set
  post 'data_set/upload/:id', :to => 'data_set#upload_data_file', :as => :upload_data_file
  patch 'data_set/upload/:id', :to => 'data_set#upload_data_file'

  get 'data_set/view_data_file', :to => 'data_set#view_data_file', :as => :view_data_file
  get 'data_set/remove_file', :to => 'data_set#remove_file', :as => :remove_data_file

  patch 'experiments/:id/upload_figure', :to => 'experiments#upload_figure', :as => :upload_figure
  get 'experiments/:id/doi_lookup', :to => 'experiments#doi_lookup', :as => :doi_lookup
  get 'experiments/:id/add_figure', :to => 'experiments#add_figure', :as => :add_supporting_figure
  get 'experiments/:id/add_supporting_file', :to => 'experiments#add_supporting_file', :as => :add_supporting_file
  post 'experiments/:id/contributors', :to => 'experiments#add_contributor', :as => :contributors


  get 'archive/:id/new', :to => 'archive#new', :as => :new_archive
  post 'archive/:id/create', :to => 'archive#create', :as => :create_archive
  get 'archive/remove_archive/:id', :to => 'archive#remove', :as => :remove_archive
  get 'archive/edit/:id', :to => 'archive#edit', :as => :edit_archive
  patch 'archive/update/:id', to: 'archive#update', :as => :update_archive

  patch 'data_set/update/:id', to: 'data_set#update_data_set', as: 'update_data_set'
  get 'data_set/add_datafile/:id', :to => 'data_set#add_datafile', :as => :add_datafile
  get 'data_set/add_real_space_file', :to => 'data_set#add_real_space_file', :as => :add_real_space_file
  post 'data_set/upload_real_space_file/', :to => 'data_set#upload_real_space_file', :as => :upload_real_space_file
  get 'data_set/destroy/:id', :to => 'data_set#destroy', :as => :remove_data_set
  get 'real_space_files/destroy', :to => 'real_space_files#destroy', :as => :remove_real_space_file
  get 'real_space_files/view', :to => 'real_space_files#view', :as => :view_real_space_file

  get 'experiments/remove_contributor/:id', :to => 'experiments#remove_contributor', :as => :remove_contributor
  #get 'submissions/add_data_files/:id', :to => 'submissions#add_data_files', :as => :add_data
  #
  # Tutorial
  #
  get '/tutorials/:id', to: 'tutorials#show', :as => :tutorialshow
  get '/tutorials', to: 'tutorials#index'
  #
  # News
  #
  resources :news
  get 'articles', :to => 'news#articles', :as => :news_articles
  get 'updates', :to => 'news#updates', :as => :news_updates
  get 'general_info', :to => 'news#general_info', :as => :news_general_info
  get 'reviews', :to => 'news#reviews', :as => :news_reviews


  get 'user_admin/index', :to => 'user_admin#index'
  get 'user_admin/destroy/:id', :to => 'user_admin#destroy', :as => :destroy_user
  get 'user_admin/edit/:id', :to => 'user_admin#edit', :as => :edit_user
  devise_for :users, controllers: { registrations: 'users/registrations' }

  get 'scatters/download', :to => 'scatters#download', :as => :scatter_download
  post 'scatters/agree_to_download', :to => 'scatters#agree_to_download', :as => :agree_to_download
  get 'scatters/download_file', :to => 'scatters#download_file', :as => :download_file
  get 'scatters/validate_download', :to => 'scatters#validate_download', :as => :validate_download
  resources :scatters

  get 'about', :to => 'about#index', :as => :about

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/user' => "welcome#index", :as => :user_root
  root 'welcome#index'
end
