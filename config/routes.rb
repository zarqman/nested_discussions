ActionController::Routing::Routes.draw do |map|

  map.namespace :admin do |a|
    a.resources :filters, :collection=>{:block_ip=>:post}
    a.resources :comments, :member=>{:approve=>:post, :disapprove=>:post}
  end

end
