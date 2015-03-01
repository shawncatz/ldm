set :stage, :production
server 'ldap.rgops.com', user: ENV['DEPLOY_USER'], roles: %w{web app}
set :deploy_to, '/srv/apps/ldm'

set :nginx_server_name, 'ldap.rgops.com'
