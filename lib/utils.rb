module Sparrow
  module Utils
    module Exception
      class AbstractMethodError < StandardError
        def initialize(method_name)
          super("The '#{self.class}##{method_name}' is a abstract method. Definition is a subclass responsibility.")
        end
      end
    end
  end
end