module LDM
  module LDAP
    class User < Entry
      def initialize(entry)
        @_data = entry
        @groups = LDM::LDAP.get_user_groups(entry.uid.first)
      end

      attr_reader :groups

      def dn
        @_data.dn
      end

      def uid
        @_data.uidnumber.first
      end

      def login
        @_data.uid.first
      end

      def password
        @_data.userpassword.first
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

      def objectclasses
        @_data.objectclass
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
    end
  end
end
