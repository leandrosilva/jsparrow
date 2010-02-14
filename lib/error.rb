module Sparrow
  module Error
    class AbstractMethodError < StandardError
      def initialize(class_name, method_name)
        super("The '#{class_name}##{method_name}' is a abstract method. Definition is a subclass responsibility.")
      end
    end
  end
end