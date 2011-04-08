ActionController::Routing::Routes.draw do |map|
  map.resources :aging_issue_statuses, :only => [:index]
end
