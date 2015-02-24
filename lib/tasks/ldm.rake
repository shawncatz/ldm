require 'rubygems'
require 'net/ldap'
require 'digest'
require 'dotenv'

namespace :ldm do
  desc 'do user search, as a test'
  task :search => :environment do
    pp LDAP.search(base: "dc=ulive,dc=com", filter: "(uid=scatanzarite)")
  end

  desc 'get basic data about login user'
  task :user, [:login] => :environment do |_, args|
    login = args.login
    raise "must set login" unless login

    user = LDAP::User.find(login)
    groups = user.groups
    puts "%8d %s %s" % [user.uidnumber.first.to_i, user.gecos.first, groups.inspect]
  end

  desc 'attempt to bind with login / password'
  task :bind, [:login, :password] => :environment do |_, args|
    login = args.login
    raise "must set login" unless login
    password = args.password
    raise "must set password" unless password

    entry = LDAP.bind(login, password)
    puts "entry: #{entry.gecos.first}"
  end
end
