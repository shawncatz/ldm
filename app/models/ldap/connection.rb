require 'net/ldap'

module LDAP
  class Connection
    def initialize
      cfg = Rails.application.secrets.ldap
      @host = cfg['host']
      @port = cfg['port']
      @user = cfg['user']
      @pass = cfg['password']
      @ssl = cfg['ssl'].to_sym
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
      search(base: @users, filter: "(employeetype=1)").map { |e| LDAP::User.new(e) }
    end

    def get_user(login)
      entry = search(base: @users, filter: "(uid=#{login})").first
      LDAP::User.new(entry)
    end

    def get_user_groups(login)
      list = search(base: @groups, filter: "(memberUid=#{login})")
      return [] unless list.count > 0
      list.collect { |e| e.cn.first }
    end

    def groups
      search(base: @groups, filter: "(objectClass=posixGroup)").map {|e| LDAP::Group.new(e)}
    end

    def get_group(name)
      entry = search(base: @groups, filter: "(cn=#{name})").first
      LDAP::Group.new(entry)
    end

    class << self
      def instance
        @instance ||= self.new
      end
    end
  end
end
