module JSparrow
  module Connection
    #
    # Connection configuration to connect the JMS provider.
    #
    class Configuration
      attr_accessor :jms_client_jar, :jndi_properties,
                    :enabled_connection_factories, :enabled_queues, :enabled_topics
    end
  
    #
    # Class methods to configure the connection with the JMS provider.
    #
    class << self

      def configure(&block)
        @@configuration = Configuration.new
      
        class_eval(&block)
      
        @@configuration
      end
  
      def configuration
        @@configuration
      end

      #
      # Example:
      #
      # use_jms_client_jar "path/to/name_of_the_client_jar_file.jar"
      #
      def use_jms_client_jar(client_jar)
        configuration.jms_client_jar = client_jar
      end
  
      #
      # Example:
      #
      #   use_jndi_properties :a_jndi_property_name_in_lower_case     => "a_value_of_property",
      #                       :other_jndi_property_name_in_lower_case => "other_value_of_property"
      #
      def use_jndi_properties(jndi_properties = {})
        configuration.jndi_properties = jndi_properties
      end
  
      #
      # Example:
      #
      #   enable_connection_factories :queue_connection_factory => "jndi_name_of_queue_connection_factory",
      #                               :topic_connection_factory => "jndi_name_of_topic_connection_factory"
      #
      def enable_connection_factories(jndi_names = {})
        configuration.enabled_connection_factories = jndi_names
      end
  
      #
      # Example:
      #
      #   enable_queues :a_queue_name_in_lower_case     => "jndi_name_of_a_queue",
      #                 :other_queue_name_in_lower_case => "jndi_name_of_other_queue"
      #
      def enable_queues(jndi_names = {})
        configuration.enabled_queues = jndi_names
      end
  
      #
      # Example:
      #
      #   enable_topics :a_topic_name_in_lower_case     => "jndi_name_of_a_topic",
      #                 :other_topic_name_in_lower_case => "jndi_name_of_other_topic"
      #
      def enable_topics(jndi_names = {})
        configuration.enabled_topics = jndi_names
      end

      #
      # Metodo usado para criar um novo Client JMS.
      #
      def new_client
        Client.new(new_connection)
      end

      #
      # Metodo usado para criar um novo Listener de mensagens JMS.
      #
      # Example:
      #
      #   new_listener :as => ListenerClass
      #
      # ou
      #
      #   new_listener(
      #     :listen_to => { :queue => :registered_name_of_queue },
      #     :receive_only_in_criteria => { :selector => "recipient = 'jsparrow-spec'" }
      #     ) do |received_message|
    
      #     # do something
      #   end
      #
      def new_listener(listener_spec, &on_receive_message)
        is_anonymous_listener = listener_spec[:as].nil?
      
        if is_anonymous_listener
          new_anonymous_listener(listener_spec, &on_receive_message)
        else
          new_named_listener(listener_spec)
        end
      end

      private

        def new_connection
          jndi_context_builder = JNDI::ContextBuilder.new(configuration.jms_client_jar, configuration.jndi_properties)
      
          connection = Provider.new(configuration, jndi_context_builder)
        end
      
        def new_named_listener(listener_spec)
          listener_spec[:as].new(new_connection)
        end
    
        def new_anonymous_listener(listener_spec, &on_receive_message)
          listener = JSparrow::Listener.new(new_connection)
      
          (class << listener; self; end;).class_eval do
            listen_to listener_spec[:listen_to] if listener_spec[:listen_to]
            receive_only_in_criteria listener_spec[:receive_only_in_criteria] if listener_spec[:receive_only_in_criteria]
          
            define_method(:on_receive_message, &on_receive_message)
          end
      
          listener
        end
    end
  end
end