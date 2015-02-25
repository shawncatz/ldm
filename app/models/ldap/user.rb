module LDAP
  class User < Entry
    def initialize(entry)
      @_data = entry
    end

    # attr_reader :groups

    def uid
      @_data.uidnumber.first
    end

    def login
      @_data.uid.first
    end

    def password
      @_data.userpassword.first
    end

    def groups
      @groups ||= LDAP::Group.for_user(login)
    end

    def name
      @_data.gecos.first
    end

    def email
      @_data.mail.first rescue nil
    end

    def keys
      @_data.sshpublickey
    end

    def shell
      @_data.loginshell.first
    end

    def enabled?
      employeetype == 1
    end

    def disabled?
      employeetype == 0
    end

    def employeetype
      @_data.employeetype.first.to_i
    end

    class << self
      def find(login)
        admin.get_user(login)
      end

      def all
        admin.users
      end

      def update(login, attrs)
        raise "not implemented"
      end

      def password(login, password)
        admin.user_password(login, password)
      end
    end
  end
end
