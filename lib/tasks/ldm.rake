require 'rubygems'
require 'net/ldap'
require 'digest'
require 'dotenv'
require 'ldm/ldap'

namespace :ldm do
  desc 'do user search, as a test'
  task :search => :environment do
    pp LDM::LDAP.search(base: "dc=ulive,dc=com", filter: "(uid=scatanzarite)")
  end

  desc 'get basic data about login user'
  task :user, [:login] => :environment do |_, args|
    login = args.login
    raise "must set login" unless login

    user = LDM::LDAP.get_user(login)
    groups = LDM::LDAP.get_user_groups(login)
    puts "%8d %s %s" % [user.uidnumber.first.to_i, user.gecos.first, groups.inspect]
  end

  desc 'attempt to bind with login / password'
  task :bind, [:login, :password] => :environment do |_, args|
    login = args.login
    raise "must set login" unless login
    password = args.password
    raise "must set password" unless password

    entry = LDM::LDAP.bind(login, password)
    puts "entry: #{entry.gecos.first}"
  end
end
