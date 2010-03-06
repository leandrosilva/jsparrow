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
      def use_jms_client_jar(jms_client_jar)
        configuration.jms_client_jar = jms_client_jar
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
    end
    
    #
    # Factory method.
    #
    def self.new
      jndi_context_builder = JNDI::ContextBuilder.new(configuration.jms_client_jar, configuration.jndi_properties)
  
      connection = Provider.new(configuration, jndi_context_builder)
    end
  end
end