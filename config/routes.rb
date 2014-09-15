Rails.application.routes.draw do

  root 'screens#index'

  resources :screens
  get 'slideshows' => 'slideshows#index'

end
