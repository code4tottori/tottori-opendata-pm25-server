Rails.application.routes.draw do

  root to:'records#index', format:'html'
  get 'graph.json', to:'records#graph'
  get ':date.json', to:'records#show'
end
