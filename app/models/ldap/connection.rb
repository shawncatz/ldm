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

      c = Net::LDAP.new(options)
      c.auth(@user, @pass)
      c.bind
      @ldap = LDAP::Wrapper.new(c)
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

    def user_create(login, first_name, last_name, key, custom_attrs={})
      group = group_create(login, true)
      uid = (users.map{|e| e.uid.to_i}.max + 1).to_s

      name = "#{first_name} #{last_name}"
      dn = "cn=#{login},#{@users}"
      attrs = {
          objectclass: ["top", "inetOrgPerson", "posixAccount", "shadowAccount", "ldapPublicKey"],
          cn: name,
          uid: login,
          gidnumber: group.gid,
          sn: last_name,
          sshpublickey: [key],
          shadowmax: "99999",
          shadowmin: "0",
          shadowlastchange: "15140",
          shadowwarning: "7",
          homedirectory: "/home/#{login}",
          loginshell: "/bin/bash",
          employeetype: "1",
          uidnumber: uid,
          gecos: name,
          givenname: first_name,
      }.merge(custom_attrs)
      @ldap.add(dn: dn, attributes: attrs)
      logger.info "user_create:#{@ldap.get_operation_result}"
      get_user(login)
    end

    def user_destroy(login)
      dn = "cn=#{login},#{@users}"
      groups = get_user_groups(login)
      @ldap.delete(dn: dn)
      groups.each do |group|
        user_group_remove(login, group)
      end
      group_destroy(login)
      true
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

    def group_create(name, user_group=false)
      gid = (groups.map {|e| e.gid.to_i}.max + 1).to_s
      dn = "cn=#{name},#{@groups}"
      attrs = {
          objectclass: ["posixGroup", "top"],
          cn: name,
          gidnumber: gid,
      }
      attrs.merge!(memberuid: name) if user_group
      @ldap.add(dn: dn, attributes: attrs)
      logger.info "group_create:#{@ldap.get_operation_result}"
      get_group(name)
    end

    def group_destroy(name)
      dn = "cn=#{name},#{@groups}"
      @ldap.delete(dn: dn)
    end

    private

    def logger
      Rails.logger
    end

    class << self
      def instance
        @instance ||= self.new
      end
    end
  end
end
