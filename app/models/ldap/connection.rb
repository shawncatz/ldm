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
      search(base: @users, filter: "(objectClass=inetOrgPerson)").map { |e| LDAP::User.new(e) }
    end

    def get_user(login)
      entry = search(base: @users, filter: "(uid=#{login})").first
      LDAP::User.new(entry)
    end

    def user_password(login, password)
      user = get_user(login)
      @ldap.modify(dn: user.dn, operations: [[:replace, :userpassword, password]])
    end

    def user_disable(login)
      user = get_user(login)
      @ldap.modify(dn: user.dn, operations: [[:replace, :employeetype, "0"],[:replace, :loginshell, "/bin/false"]])
    end

    def user_enable(login)
      user = get_user(login)
      @ldap.modify(dn: user.dn, operations: [[:replace, :employeetype, "1"],[:replace, :loginshell, "/bin/bash"]])
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
