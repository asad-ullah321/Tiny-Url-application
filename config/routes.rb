Rails.application.routes.draw do
  get_endpoint = ENV.fetch("GET_ENDPOINT", "tiny").to_s.gsub(%r{\A/+|/+\z}, "")

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "tiny_url#home"
  post "tiny_url/create", to: "tiny_url#create", as: :create_tiny_url
  get get_endpoint, to: "tiny_url#show", as: :tiny_url_show
end
