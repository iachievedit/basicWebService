require 'bundler/capistrano'

set :application, "basicWebService"
set :repository,  "git@github.com:iachievedit/basicWebService"

set :scm, :git
set :deploy_via, :remote_cache

role :app, "dev.iachieved.it"

after "deploy:restart", "deploy:cleanup"

task :development do
  set :user,      "webservice"
  set :use_sudo,  false
  set :stage,     "development"
  set :branch,    "with_mysql"
  set :deploy_to, "/web/apps/#{stage}/#{application}"
end

namespace :deploy do

  after 'deploy:update_code', 'deploy:symlink_configs'

  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :symlink_configs, :roles => :app do
    run <<-CMD
   
      cd #{release_path} &&
      ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml
    CMD
  end
  
end
