module JSparrow
  module Connection
    
    #
    # Class for establish connection with JMS provider throught JNDI. 
    #
    class Provider
      attr_reader :configuration
    
      def initialize(configuration, jndi_context_builder)
        @configuration        = configuration
        @jndi_context_builder = jndi_context_builder

        # Foi estabelecida?
        @opened = false
      end
    
      def is_opened?
        @opened
      end
    
      def open
        raise InvalidStateError.new('opened', 'open') if is_opened?
  
        begin
          @jndi_context = @jndi_context_builder.build
        rescue => cause
          raise InitializationError.new(@configuration, cause)
        end
      
        @opened = true
      end
    
      def is_closed?
        not @opened
      end

      def close
        raise InvalidStateError.new('closed', 'close') if is_closed?
  
        @jndi_context.close
  
        @opened = false  
      end

      def lookup_resources(resources = {})
        lookuped_resource = {}

        return lookuped_resource unless resources
  
        resources.each do |name, jndi_name|
          lookuped_resource[name] = lookup_resource(jndi_name)
        end

        lookuped_resource
      end
    
      def lookup_resource(jndi_name)
        @jndi_context.lookup(jndi_name)
      end
    end

    #
    # Error to signal invalid state on open or close operation.
    #
    class InvalidStateError < StandardError
      attr_reader :state, :operation

      def initialize(state, operation)
        super("Could not did #{operation} because connection is #{state}.")

        @state     = state
        @operation = operation
      end
    end

    #
    # Error to signal impossibility to connect the JMS provider.
    #
    class InitializationError < StandardError
      attr_reader :configuration, :cause

      def initialize(configuration, cause)
        super("Could not open connection to JMS provider. Verify the config's config.")

        @configuration = configuration
        @cause         = cause
      end
    end
  end
end
