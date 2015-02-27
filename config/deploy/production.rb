set :stage, :production
server 'ldap.rgops.com', user: ENV['DEPLOY_USER'], roles: %w{web app}
set :deploy_to, '/srv/apps/ldm'

set :nginx_server_name, 'ldap.rgops.com'
# ignore this if you do not need SSL
# set :nginx_use_ssl, true
# set :nginx_ssl_cert_local_path, '/path/to/ssl_cert.crt'
# set :nginx_ssl_cert_key_local_path, '/path/to/ssl_cert.key'
