Rails.application.routes.draw do
  root "pages#main"
  get 'pages/pupil_tt'
  get 'pages/teacher_tt'
  get 'pages/cabinet_tt'
  get 'pages/bells'
  get 'pages/workload'
  get 'pages/transfer'
  get 'pages/subj_in_bg'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
