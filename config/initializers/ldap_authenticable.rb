require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable
      def authenticate!
        if params[:user]
          entry = LDAP.bind(login, password)
          if entry
            user = User.find_or_create_by(login: login)
            attrs = {}
            attrs.merge!(email: entry.email) if entry.email
            attrs.merge!(name: entry.name) if entry.name
            puts "ATTRS: #{attrs.inspect}"
            user.update_attributes(attrs)

            success!(user)
          else
            fail(:invalid_login)
          end
        end
      end

      def login
        params[:user][:login]
      end

      def password
        params[:user][:password]
      end

    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
