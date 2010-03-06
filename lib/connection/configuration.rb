module JSparrow
  module Connection
    #
    # Configuracoes necessarias para que clientes JMS se conetem
    # ao provedor de mensageria via contexto JNDI.
    #
    class Configuration
      attr_accessor :jms_client_jar, :jndi_properties,
                    :enabled_connection_factories, :enabled_queues, :enabled_topics
    end
  
    #
    # Metodos de configuracao da conexao com o provedor JMS.
    #
    class << self
      #
      # Metodo usado para configurar a conexao.
      #
      def configure(&block)
        @@configuration = Configuration.new
      
        class_eval(&block)
      
        @@configuration
      end
  
      #
      # Metodo usado para obter a configuracao para conexao com o provedor de JMS.
      #
      def configuration
        @@configuration
      end

      #
      # Use:
      #
      # use_jms_client_jar "path/to/name_of_the_client_jar_file.jar"
      #
      def use_jms_client_jar(client_jar)
        configuration.jms_client_jar = client_jar
      end
  
      #
      # Use:
      #
      #   use_jndi_properties :a_jndi_property_name_in_lower_case     => "a_value_of_property",
      #                       :other_jndi_property_name_in_lower_case => "other_value_of_property"
      #
      def use_jndi_properties(jndi_properties = {})
        configuration.jndi_properties = jndi_properties
      end
  
      #
      # Use:
      #
      #   enable_connection_factories :queue_connection_factory => "jndi_name_of_queue_connection_factory",
      #                               :topic_connection_factory => "jndi_name_of_topic_connection_factory"
      #
      def enable_connection_factories(jndi_names = {})
        configuration.enabled_connection_factories = jndi_names
      end
  
      #
      # Use:
      #
      #   enable_queues :a_queue_name_in_lower_case     => "jndi_name_of_a_queue",
      #                 :other_queue_name_in_lower_case => "jndi_name_of_other_queue"
      #
      def enable_queues(jndi_names = {})
        configuration.enabled_queues = jndi_names
      end
  
      #
      # Use:
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
      # Use:
      #
      #   new_listener(:as => ListenerClass)
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

      # --- Private methods --- #
      private

        #
        # Metodo usado para criar uma nova Connection
        #
        def new_connection
          jndi_context_builder = JNDI::ContextBuilder.new(configuration.jms_client_jar, configuration.jndi_properties)
      
          connection = Provider.new(configuration, jndi_context_builder)
        end
      
        #
        # Metodo usado para construir Listener de mensagens JMS declarado.
        #
        def new_named_listener(listener_spec)
          listener_spec[:as].new(new_connection)
        end
    
        #
        # Metodo usado para construir Listener de mensagens JMS anonimo.
        #
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