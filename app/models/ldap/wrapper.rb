module LDAP
  class Wrapper
    class << self
      def wrap(method)
        define_method method do |*args|
          response = @cnx.send(method, *args)
          result = @cnx.get_operation_result
          if result.code > 0
            raise "ldap error: #{result.message}: #{result.error_message}"
          end
          response
        end
      end
    end

    wrap :add
    wrap :delete
    wrap :modify
    wrap :search

    def initialize(cnx)
      @cnx = cnx
    end

    def get_operation_result
      @cnx.get_operation_result
    end

    def logger
      Rails.logger
    end
  end
end
