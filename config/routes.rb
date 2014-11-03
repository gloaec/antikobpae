Antikobpae::Application.routes.draw do

  class FormatTest
    attr_accessor :mime_type

    def initialize(format)
      @mime_type = Mime::Type.lookup_by_extension(format)
    end

    def matches?(request)
      request.format == mime_type
    end
  end

  devise_for :users, :path_prefix => 'auth', :controllers => {
    :sessions => 'users/sessions',
    :registrations => 'users/registrations'
  }
  
  get '*foo', :to => 'application#index', :constraints => FormatTest.new(:html)
  get '/', :to => 'application#index', :constraints => FormatTest.new(:html)
  get '/stats', :to => 'application#stats', :constraints => FormatTest.new(:json)

  resources :routes

  resources :domains

  root :to => 'application#index' # folders#index'
  
  mount Ckeditor::Engine => '/ckeditor'
  
  match 'plupload_rails/_plupload_uploader', 
    :controller => 'documents', 
    :action => '_plupload_uploader', 
    :as => 'pluploader'

  match '/typeahead' => 'documents#typeahead'
  match '/search' => 'documents#search'
  
  resources :users
  resources :groups, :except => :show
  
  resources :users, :only => :create do
    resources :folders
  end

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
    get :files, :on => :member
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
