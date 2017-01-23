Rails.application.routes.draw do

  root to:'records#index', format:'html'
  get ':date.json', to:'records#show'

end
