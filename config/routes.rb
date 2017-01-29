Rails.application.routes.draw do
  root to:'records#index', format:'html'
  get 'update.json', to:'records#update'
  get 'graph.json', to:'records#graph'
  get 'today.json', to:'records#today'
  get ':date.json', to:'records#show'
end
