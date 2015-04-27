set :application, "ldm"
set :repo_url, 'git@github.com:shawncatz/ldm'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :scm, :git
rubyversion = File.read(".ruby-version").chomp
rubygemset = File.read(".ruby-gemset").chomp
set :rvm_ruby_version, "#{rubyversion}@#{rubygemset}"

# set :format, :pretty
# set :log_level, :debug
# set :pty, true
set :linked_files, %w{ .env }
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

set :migration_role, 'app'
set :conditionally_migrate, true

set :unicorn_logrotate_enabled, true
# ignore this if you do not need SSL
set :nginx_use_ssl, true
set :nginx_upload_local_cert, false # already installed on server
set :nginx_ssl_cert, 'wildcard.rgops.com.combined.crt'
set :nginx_ssl_cert_key, 'wildcard.rgops.com.key'

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'

end
