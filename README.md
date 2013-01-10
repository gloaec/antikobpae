# Antikobpae 2.0

Antikobpae is a Rails 3.1 application that aims to be a simple interface for text 
plagiarism detection via a web browser. It includes file management & sharing 
possibilities based on [BoxRoom](http://boxroom.rubyforge.org/). The application lets users create
folders and upload and download files. For admins it is possible to create users,
groups and the CRU/D rights these groups have on folders. It makes the application
flexible depending on the organization's network (Intranet Application / Cloud Application)

Wiki:
[https://bitbucket.org/ghis182/kobpae-rails/wiki](https://bitbucket.org/ghis182/kobpae-rails/wiki)  

Bug reports and feature requests:  
[https://bitbucket.org/ghis182/kobpae-rails/issues/new](https://bitbucket.org/ghis182/kobpae-rails/issues/new)

# Requirements

The requirements for running Antikobpae are:

 * Ruby 1.9.3 (RVM recommended)
 * Rails 3.1.0
 * MySQL apt
 * Sphinx 2.0.4
 * OpenOffice or LibreOffice
 * -> add here server requirements ( built-in 'iconv' , 'swath' for ex.)
	
# Installation

Follow the these steps:

 1. `$ git clone https://ghis182@bitbucket.org/ghis182/kobpae-rails.git` Clone the project
    
or 

 1. Download and extract `kobpae-rails.zip`
 
 2. `$ cd kobpae-rails` Go to the project root directory
 3.	`$ bash install` Attempts to install all AntiKobpae's dependencies
 4. `$ bundle install` Install the bundle

You may need to configure the databases and specify the third party programs which will 
perform in document processing. Edit these entries for each environements :

`db/database.yml` MySQL configuration 

	username: <mysql_username>
	password: <mysql_username>
	socket:   <mysql_socket> 		# cf. /etc/[mysql/]my.cnf

`config/sphinx.yml` Sphinx configuration

	bin_path: <sphinx_bin_path> 	# ='/usr/[local/]bin'
 	searchd_binary_name: searchd 	# default
  	indexer_binary_name: indexer 	# default

`config/antikobpae.yml` Antikobpae configuration
	
	bing_api_key: "[Enter Google ID]"
	soffice_bin: <soffice_bin>
	swath_bin: <swath_bin>


 5. `$ rake db:install` Drop/Create/Migrate the database and the schema
 6. `$ rails s` Start the development server
 7. Point your browser to [http://localhost:3000/](http://localhost:3000/)

In order to switch the environement to _production_ with Apache, check out the **Production** section

# Stating Services

In order to maintain server-client communication performances and for a matter of necessary ordered jobs,
these followings tasks will be executed in the background by the delayed_job module :

 * Document importation/creation
 * Document conversion
 * Document segmentation
 * Document indexing
	* Sphinx indexing
	* Marshal indexing (words + ranges objects)
 * Scan Filter Search
 * Highlighting
	
It acts pretty much like CRON, for more information consult [delayed_job git repository](https://github.com/tobi/delayed_job).
Start the watcher by running :

	rake jobs:work

# Import Documents

Copy the file tree of the documents you wish to import into the `import/` folder. They will 
be automatically imported to the **Root Folder** by running this task :

	rake db:seed

# Mail settings

Antikobpae sends email when users want to reset their password or when they share files.
For this to work, depending on your environment, you have op to open
`config/environments/development.rb` or `config/environments/production.rb`, uncomment
the following lines and fill in the correct settings of your mail server:

    # config.action_mailer.delivery_method = :smtp
    # config.action_mailer.smtp_settings = {
    #   :address => 'mailhost',
    #   :port => 587,
    #   :user_name => 'user_name',
    #   :password => 'password',
    #   :authentication => 'plain'
    # }

In order for Antikobpae to send a user to the correct URL for either downloading a shared
file or for resetting passwords, you have to uncomment and update the following:

    # config.action_mailer.default_url_options = { :host => 'localhost:3000' }

You also have to choose a from address for the emails that will be sent. You can do
this by uncommenting and adjusting the following line:

    # ActionMailer::Base.default :from => 'Antikobpae <yourname@yourdomain.com>'

# Languages

Antikobpae is available in English/Thai and partially in Dutch, German and Italian. In order to create a 
new language, edit/create files in `config/locales`.

English is the default. To change the language, open `config/application.rb` and change the following line:

    config.i18n.default_locale = :en

to:

	config.i18n.default_locale = :th # Thai
    config.i18n.default_locale = :nl # Dutch
    config.i18n.default_locale = :de # German
    config.i18n.default_locale = :it # Italian

# Downloaded files are empty

If you encounter an issue with Antikobpae where downloaded files are always empty,
it may help to uncomment the following line in `config/environments/production.rb`:

    # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

# Deployment

(source: [kris.me.uk](http://kris.me.uk/2011/10/28/rails-rvm-passenger-capistrano-git-apache.html))

Once more for performances expectations, here is how to use Apache web server for the production environement.
At the time of writing, the latest versions of the software in use are:

 * RVM: 1.9.0
 * Ruby: 1.9.3-p194
 * Passenger: 3.0.9
 * Rails: 3.1.1
 * Capistrano: 2.9.0

## RVM Multi User Install

RVM can be installed for multiple users by installing as root. This allows installations to be shared across different users, although different users can use which ever version they wish.

	sudo curl -L https://get.rvm.io | bash -s stable --rails
	
In order for a user to use the multi user RVM installation the must belong to the rvm group. Also check that they do not have a ~/.rvm directory as this takes precedence over the multi user install for that user.

The rvm function will be automatically configured for every user on the system if you install with sudo. This is accomplished by loading `/etc/profile.d/rvm.sh` on login. Most Linux distributions default to parsing `/etc/profile` which contains the logic to load all files residing in the `/etc/profile.d/` directory. Once you have added the users you want to be able to use RVM to the rvm grou p, those users MUST log out and back in to gain rvm group membership because group memberships are only evaluated by the operating system at initial login time. Zsh not always sources `/etc/profile` so you might need to add this in `/etc/**/zprofile`:

	source /etc/profile

## Create Passenger User

It is a good idea to create a passenger user on the server to install services as so that it is isolated from other users. You can also deploy your applications using this user. The passenger user needs sudo rights for installing packages using apt-get and running the passenger install script, and needs to be a member of the rvm group to use the multi user install.

	sudo adduser passenger
	sudo usermod -G passenger,www-data,sudo,rvm passenger
	su - passenger

You can remove the sudo right after completing the installation using the following:

	sudo usermod -G passenger,www-data,rvm passenger

Generate a key pair for ssh too. On your client machine, create a key and use a string pass phrase:

	ssh-keygen -v -t rsa -f passenger@domainname -C passenger@domainname

This will create a private key called passenger@domainname and a public key called passenger@domainname.pub. Keep these somewhere safe.

You can register the public key into authorized_keys to allow key based ssh authentication. Run the following on your client machine:

	scp passenger@domainname.pub passenger@hostname:~/.ssh/authorized_keys
	
Depending on the client and your preference, you can either enter the passphrase for you private key each time you connect, or run ssh-agent and register the key using ssh-add. To register the private key into your ssh agent on your client machine run the following and enter the passphrase when prompted:

	ssh-add passenger@domainname

You should now be able to ssh to the server without being challenged for the password, e.g:

	ssh passenger@hostname

## Passenger RVM Configuration

Note: if you previously had RVM installed as a single user you need to remove the old source line for `$HOME/.rvm/scripts/rvm` and move (or delete) the `.rvm` directory so that the system wide installation is picked up instead.

Log out and log in again as passenger to ensure the scripts work as expected. You can test RVM is available correctly by running:

	type rvm | head -n1

You should then see the following output:

	rvm is a function
	
If you have troubles loading the environment, you can run : `source /usr/local/rvm/script/rvm`

You can view the requirements for installing the different rubies by running rvm requirements.

To install the packages (requires sudo):

	sudo apt-get install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion

To install ruby 1.9.3:

	rvm install 1.9.3
	rvm use --default 1.9.3

You can can now verify the ruby version and install some gems, e.g.:

	ruby -v
	gem install bundler rails
	
## Passenger

Passenger is very easy to install. RVM provides some instructions specifically for passenger.

Install the gem and run the installation script. It will tell you what dependencies you are missing and how to install them:

	gem install passenger
	passenger-install-apache2-module

Passenger provides some instructions on how to configure apache. I like to treat passenger as a mod for apache, allowing it to be enabled and disabled as required through the a2enmod and a2dismod commands respectively.

First, disable the default module :

	sudo a2dissite 000-default 

To enable passenger, create `/etc/apache2/mods-available/passenger.load` with the following contents:

	LoadModule passenger_module /usr/local/rvm/gems/ruby-1.9.3-p194/gems/passenger-3.0.9/ext/apache2/mod_passenger.so
	
and /etc/apache2/mods-available/passenger.conf with the following contents:

	PassengerRoot /usr/local/rvm/gems/ruby-1.9.3-p194/gems/passenger-3.0.9
	PassengerRuby /usr/local/rvm/wrappers/ruby-1.9.3-p194/ruby	

then enable the module and reload apache:

	sudo a2enmod passenger
	sudo /etc/init.d/apache2 reload

## Apache

Create `/etc/apache2/sites-available/antikobpae` with the following contents:

	<VirtualHost *:80>
	    ServerName antikobpae
	    DocumentRoot /home/passenger/antikobpae/current/public
	    <Directory /home/passenger/antikobpae/current/public>
	        AllowOverride all
	        Options -MultiViews
	    </Directory>
	</VirtualHost>

Enable the site, although there is nothing there to view until we have deployed it:

	sudo a2ensite antikobpae
	sudo /etc/init.d/apache2 reload
	
## God

	apt-get install chkconfig
	

Antikobpae uses [god](http://godrb.com/) to monitor these services :

 * apache
 * sphinx
 * mysql
 * delayed_job 

Install god on the server as passenger :

	gem install god
	
Any monitoring solution isn’t complete until it takes care of starting/stopping itself automatically. God has to be configured to start automatically on server reboot. But don't worry, there is already a deploy task to perform the deamon configuration.
	
## Capistrano

### Configuration

On you local machine, make sure you have capistrano installed:

	gem install capistrano
	
For the last time, you are __NOT__ the only one working on this project, so for god sakes:

**!!! PLEASE CREATE YOU OWN BRANCH !!!** on git :

	git branch my_branch
	git checkout my_branch
	
Then edit in the file `config/deploy.rb` the following entries:

	set :branch, 'my_branch'
	set :server, "domain_ip"
	set :application, "domainname"
	role :web, "domain_ip"
	role :app, "domain_ip"
	role :db,  "domain_ip", :primary => true
	
Finally, we will create a folder with the proper configuration for the server you want to deploy.
Run the rake task :

	rake generate:config['domain_ip']
	
And then edit the following files :

	config/deploy/templates/#{domain_ip}/antikopbae.yml
	config/deploy/templates/#{domain_ip}/database.yml
	config/deploy/templates/#{domain_ip}/ldap.yml
	config/deploy/templates/#{domain_ip}/sphinx.yml
	
### Deployment

Everytime you want to deploy your code to the server, commit & push your modifications first :

	git commit -am"Commit Message"
	git push

The first time you deploy to the server you should run the deployment setup task:

	cap deploy:setup

Thereafter you can deploy using:

	cap deploy
	cap deploy:migrations

You may get some strange errors or failures when deploying. If you have followed the steps I have mentioned in this guide then hopefully you shouldn’t have many problems. Common problems are:

 * wrong permissions of `/home/passenger/antikobpae/`
 * wrong permissions of `passenger` user
 * not having rvm installed for `passenger` user
 * not having the basic gems required to use capistrano on the server, simply install them as the passenger user

Here are some other cap commands that can be useful :

	cap
		god
			:deploy				# Deploy the god monitor configuration on server & restart services
			:start				# Start the god monitor & services
			:stop				# Stop the god monitor & services
			:restart			# Restart the god monitor & services
			:status				# Check services status (up/unmonitored)
			:log				# Display god monitor log
			:deploy_config		# Deploy monitoring instructions on server 
			:deploy_init_script # Deploy god monitor deamon script on server
			:load_config		# Load monitoring instructions

		deploy
			:assets
				:precompile		# Compile files in the app/assets path ( /!\ Very Long
			:config				# Copy YMLs from config/templates/#{domain_ip} to shared 
			:config_symlink		# Create Symbolic links of YML config from shared/ to release/
			:start, :restart	# Restart Apache 
			:update_code		# Pull the latest git commit from deploy branch on server
			:finalize_update	# 
		
		thinking_sphinx
			:start				# Start searchd
			:stop				# Stop searchd
			:restart			# Restart searchd
			:symlink_indexes	# Create Symbolic links of Sphinx indexes from shared/ to release/
			
		delayed_job
			:start				# Start the workers manually
			:stop				# Stop the workers manually
			:restart			# Restart the workers manually
			:clear				# Clear all the queues
			:clear['queue']		# Clear a queue by name [scans, documents, delta]

# TODO

Setup Git Submodules to public (no SHH keys)   

# Additional Packages

sudo apt-get install libmagick9-dev apache2-threaded-dev libcurl4-openssl-dev


	
	
	
