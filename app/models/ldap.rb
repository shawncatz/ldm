module LDAP
  class << self
    def search(options)
      admin.search(options)
    end

    # def users
    #   admin.users
    # end
    #
    # def get_user(login)
    #   admin.get_user(login)
    # end
    #
    # def get_user_groups(login)
    #   admin.get_user_groups(login)
    # end

    def bind(login, password)
      cfg = Rails.application.secrets.ldap
      host = cfg['host']
      port = cfg['port']
      ssl = cfg['ssl'].to_sym
      # base = cfg['base']
      users = cfg['users']
      # groups = cfg['groups']

      options = {
          host: host,
          port: port,
          encryption: ssl,
      }

      ldap = Net::LDAP.new(options)
      ldap.auth("cn=#{login},#{users}", password)
      return LDAP::User.find(login) if ldap.bind
      false
    end

    private

    def admin
      LDAP::Connection.instance
    end
  end
end
