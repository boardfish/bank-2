Rails.application.routes.draw do
  root 'root#index'
  get 'root/index'
  get 'callback', to: 'root#callback'
  get 'root/logout'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
