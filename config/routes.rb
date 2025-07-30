Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "forecast#index"

  get "forecast", to: "forecast#show", as: :forecast
end
