AntiKobpae::Application.routes.draw do

  resources :routes

  resources :domains

  root :to => 'home#index' # folders#index'
  
  mount Ckeditor::Engine => '/ckeditor'
  
  match 'plupload_rails/_plupload_uploader', 
    :controller => 'documents', 
    :action => '_plupload_uploader', 
    :as => 'pluploader'

  match '/typeahead' => 'documents#typeahead'
  match '/search' => 'documents#search'
  
  devise_for :users, :path_prefix => 'auth', :controllers => {
    :sessions => 'users/sessions',
    :registrations => 'users/registrations'
  }
  
  resources :users, :except => :show
  resources :groups, :except => :show
  
  resources :clipboard, :only => [:create, :destroy] do
    member do
      post 'copy'
      post 'move'
      put 'reset'
    end
  end
 
  # Update a collection of permissions
  resources :group_folder_permissions, :only => :update_multiple do
    put :update_multiple, :on => :collection
  end
  
  resources :user_folder_permissions, :only => :update_multiple do
    put :update_multiple, :on => :collection
  end
  
  # Nested resources
  resources :folders, :shallow => true, :except => [:new, :create] do
    resources :folders, :only => [:new, :create]
    resources :documents, :only => [:new, :create] 
  end
  
  resources :documents, :except => [:index, :new, :create] 
  
  resources :documents do
    member do
      get :image
      get :download
      get :xmlpipe
    end
  end
	
  resources :documents, :shallow => :true, :only => :show do
    resources :share_links, :only => [:new, :create]
  end
  
  resources :folders  do
    get :statement, :on => :member
  end
  
  resources :scans  do
    member do
      get :start
      get :statement
      get :statements
    end
  end
  
  resources :scans, :shallow => true, :except => [:new, :create] do
    resources :scans, :only => [:new, :create] 
    resources :documents, :only => [:new, :create] 
    resources :folders, :only => [:new, :create]
  end
   
   resources :domains, :shallow => true, :except => [:new, :create] do
    resources :domains, :only => [:new, :create] 
    resources :documents, :only => [:new, :create] 
    resources :folders, :only => [:new, :create]
    resources :document_text
  end

  resources :scan_files, :shallow => true, :except => [:new, :create] do
    resources :similarities, :only => [:index, :new, :create]
  end

end
