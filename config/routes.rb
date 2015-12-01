AutomationMonitor::Application.routes.draw do
  root :to => "auth#index"

  match 'auth/github_callback' => "auth#github_callback", :action => "get"
  match 'auth/github' => "auth#github", :action => "get"
  match 'auth/logout' => "auth#logout"

  resources :automation_set

  match 'automation_list' => "automation_set#list"
end
