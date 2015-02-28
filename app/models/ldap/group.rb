module LDAP
  class Group < Entry
    def initialize(entry)
      @_data = entry
    end

    def name
      cn
    end

    def gid
      @_data.gidnumber.first
    end

    def members
      @_data.memberuid
    end

    class << self
      def find(name)
        admin.get_group(name)
      end

      def all
        admin.groups
      end

      def update(name, attrs)
        raise "not implemented"
      end

      def for_user(login)
        admin.get_user_groups(login)
      end
    end
  end
end
