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
      search(base: @users, filter: "(objectClass=inetOrgPerson)").map { |e| LDAP::User.new(e) }.sort_by {|e| e.login}
    end

    def get_user(login)
      entry = search(base: @users, filter: "(uid=#{login})").first
      raise "could not find user: #{login}" unless entry
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

    def user_group_add(login, group)
      group = get_group(group)
      @ldap.modify(dn: group.dn, operations: [[:add, :memberuid, login]])
    end

    def user_group_remove(login, group)
      group = get_group(group)
      @ldap.modify(dn: group.dn, operations: [[:delete, :memberuid, login]])
    end

    def user_key_add(login, key)
      user = get_user(login)
      @ldap.modify(dn: user.dn, operations: [[:add, :sshpublickey, key]])
    end

    def user_key_remove(login, key_name)
      user = get_user(login)
      key = user.keys.detect {|e| e.split.last == key_name}
      raise "could not find key #{key_name}" unless key
      @ldap.modify(dn: user.dn, operations: [[:delete, :sshpublickey, key]])
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
      raise "could not find group: #{name}" unless entry
      LDAP::Group.new(entry)
    end

    class << self
      def instance
        @instance ||= self.new
      end
    end
  end
end
