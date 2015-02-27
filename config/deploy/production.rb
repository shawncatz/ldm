set :stage, :production
server 'ldap.rgops.com', user: ENV['DEPLOY_USER'], roles: %w{web app}
set :deploy_to, '/srv/apps/ldm'

set :nginx_server_name, 'ldap.rgops.com'
# ignore this if you do not need SSL
set :nginx_use_ssl, true
set :nginx_upload_local_cert, false # already installed on server
set :nginx_ssl_cert, 'wildcard.rgops.com.combined.crt'
set :nginx_ssl_cert_key, 'wildcard.rgops.com.key'
