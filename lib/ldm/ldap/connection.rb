require 'net/ldap'
require 'rails'

module LDM
  module LDAP
    class Connection
      def initialize
        cfg = Rails.application.secrets.ldap
        @host = cfg['host']
        @port = cfg['port']
        @user = cfg['user']
        @pass = cfg['password']
        @ssl  = cfg['ssl'].to_sym
        @base = cfg['base']
        @users = cfg['users']
        @groups = cfg['groups']

        options = {
            host: @host,
            port: @port,
            encryption: @ssl,
        }

        @ldap = Net::LDAP.new(options)
        @ldap.auth(@user, @pass)
      end

      def search(options)
        @ldap.search(options)
      end

      def users
        search(base: @users, filter: "(employeetype=1)").map {|e| LDM::LDAP::User.new(e)}
      end

      def get_user(login)
        entry = search(base: @users, filter: "(uid=#{login})").first
        LDM::LDAP::User.new(entry)
      end

      def get_user_groups(login)
        list = search(base: @groups, filter: "(memberUid=#{login})")
        return [] unless list.count > 0
        list.collect{|e| e.cn.first}
      end

      class << self
        def instance
          @instance ||= self.new
        end
      end
    end
  end
end
