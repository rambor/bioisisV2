json.extract! experiment, :id, :description, :title, :status, :publication, :bioisis_id, :created_at, :updated_at
json.url experiment_url(experiment, format: :json)
