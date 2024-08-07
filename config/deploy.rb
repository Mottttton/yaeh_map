# config valid for current version and patch releases of Capistrano
lock "~> 3.18.1"

set :application, "yaeh_map"
set :repo_url, "https://github.com/Mottttton/yaeh_map.git"
set :branch, 'main'
set :linked_files, %w{config/secrets.yml .env}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets public/uploads}   # 5
set :keep_releases, 5
set :rbenv_ruby, '3.0.1'
set :log_level, :info

after "deploy:restart", "deploy:cleanup"
after 'deploy:published', 'deploy:seed'   # 9
after 'deploy:finished', 'deploy:restart'   # 10

namespace :deploy do
  desc 'Run seed'
  task :seed do
    on roles(:db) do
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :bundle, :exec, :rake, 'db:seed'
        end
      end
    end
  end
  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart'
  end
end
