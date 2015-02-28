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
      @_data.memberuid rescue []
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

      def add_user(name, login)
        admin.user_group_add(login, name)
      end

      def create(name)
        admin.group_create(name)
      end

      def destroy(name)
        admin.group_destroy(name)
      end
    end
  end
end
