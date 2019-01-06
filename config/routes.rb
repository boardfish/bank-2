Rails.application.routes.draw do
  root 'root#index'
  get '/', to: 'root#index'
  get 'callback', to: 'root#callback'
  get 'logout', to: 'root#logout'
  get 'set_category', to: 'root#set_category'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
