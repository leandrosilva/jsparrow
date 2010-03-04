# Classes Java usadas nesse arquivo
import 'java.util.Hashtable'
import 'javax.naming.InitialContext'

module JSparrow
  module Connection

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
      def new_listener(listener_spec)
        listener_spec[:as].new(new_connection)
      end
      
      #
      # Metodo usado para construir Listener de mensagens JMS. Deve receber um Hash com os parametros do
      # listener e um bloco que sera usado para tratar atender ao metodo on_receive_message.
      #
      # Use:
      #
      #   create_listener(
      #     :queue => :registered_name_of_queue,
      #     :receive_only_in_criteria => { :selector => "recipient = 'jsparrow-spec' and to_listener = 'TestQueueListener'" }
      #   ) do |received_message|
      #     # do something
      #   end
      #
      def create_listener(listener_spec, &on_receive_message)
        listener = JSparrow::Connection::Listener.new(new_connection)
        
        (class << listener; self; end;).class_eval do
          listen_to listener_spec[:listen_to] if listener_spec[:listen_to]
          receive_only_in_criteria listener_spec[:receive_only_in_criteria] if listener_spec[:receive_only_in_criteria]
        
          define_method(:on_receive_message, &on_receive_message)
        end
        
        listener
      end

      # --- Private methods --- #
      private

        #
        # Metodo usado para criar uma nova Connection
        #
        def new_connection
          jndi_context_builder = JNDI::ContextBuilder.new(configuration.jms_client_jar, configuration.jndi_properties)
        
          connection = Base.new(configuration, jndi_context_builder)
        end
    end

    #
    # Classe base para estabelecer conexao com o provedor JMS via JNDI. 
    #
    class Base
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
    # Configuracoes necessarias para que clientes JMS se conetem
    # ao provedor de mensageria via contexto JNDI.
    #
    class Configuration
      attr_accessor :jms_client_jar, :jndi_properties,
                    :enabled_connection_factories, :enabled_queues, :enabled_topics
    end

    #
    # Erro para quando uma conexao esta num estado invalido para uma operacao (open ou close).
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
    # Erro para quando nao for possivel estabelecer conexao com o provedor JMS.
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
  
  module JNDI
    
    #
    # Builder para construcao de contexto JNDI para conexao com o provedor
    # de JMS.
    #
    class ContextBuilder
      attr_accessor :jms_client_jar, :jndi_properties
      
      def initialize(jms_client_jar, jndi_properties)
        @jms_client_jar  = jms_client_jar
        @jndi_properties = jndi_properties
      end
      
      #
      # Constroi um contexto JNDI inicial a partir das configuracoes atuais.
      #
      def build
          # Carrega a biblioteca cliente do servidor de aplicacoes
          require @jms_client_jar
          
          InitialContext.new(to_jndi_environment_hashtable)
      end

      # --- Private methods --- #
      private

        #
        # Cria um Hashtable Java contendo as configuracoes atuais.
        #
        def to_jndi_environment_hashtable
          jndi_env = Hashtable.new
        
          jndi_env.put(
            InitialContext::INITIAL_CONTEXT_FACTORY,
            @jndi_properties[:initial_context_factory])
            
          jndi_env.put(
            InitialContext::PROVIDER_URL,
            @jndi_properties[:provider_url])
            
          jndi_env.put(
            InitialContext::SECURITY_PRINCIPAL,
            @jndi_properties[:security_principal]) if @jndi_properties[:security_principal]
            
          jndi_env.put(
            InitialContext::SECURITY_CREDENTIALS,
            @jndi_properties[:security_credentials]) if @jndi_properties[:security_credentials]
        
          jndi_env
        end
    end
  end
end
