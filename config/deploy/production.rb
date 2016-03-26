require 'aws-sdk-resources'
set :stage, :production
aws = Aws::EC2::Resource.new
aws.instances(filters:[{name: 'instance-state-name', values: ['running']}, name: 'tag:Name', values: [ENV['DEPLOY_SERVER_TAG']]]).each do |instance|
  server instance.private_ip_address, user: ENV['DEPLOY_USER'], roles: %w{web app}
end

set :deploy_to, '/srv/ldm'
set :nginx_server_name, 'ldap.ulive.sh'
