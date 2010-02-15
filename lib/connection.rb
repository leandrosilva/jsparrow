# Classes Java usadas nesse arquivo
import 'java.util.Hashtable'
import 'javax.naming.InitialContext'

module Sparrow
  module Connection

    #
    # Metodo usado para configurar a conexao com o middleware de JMS.
    #
    def self.configure
      @@configuration = Configuration.new
      
      yield @@configuration
    end
    
    #
    # Metodo usado para obter a configuracao para conexao com o middleware de JMS.
    #
    def self.configuration
      @@configuration
    end
    
    #
    # Metodo usado para criar um novo Client JMS.
    #
    def self.new_client
      jndi_context_builder = JNDI::ContextBuilder.new(@@configuration.jms_client_jar, @@configuration.jndi_properties)
      
      Client.new(@@configuration, jndi_context_builder)
    end

    #
    # Configuracoes necessarias para que clientes JMS se conetem
    # ao middleware de mensageria via contexto JNDI.
    #
    class Configuration
      attr_reader :jms_client_jar, :jndi_properties,
                  :enabled_connection_factories, :enabled_queues, :enabled_topics
      
      def use_jms_client_jar(client_jar)
        @jms_client_jar = client_jar
      end
      
      def use_jndi_properties(jndi_properties = {})
        @jndi_properties = jndi_properties
      end
      
      def enable_connection_factories(jndi_names = {})
        @enabled_connection_factories = jndi_names
      end
      
      def enable_queues(jndi_names = {})
        @enabled_queues = jndi_names
      end
      
      def enable_topics(jndi_names = {})
        @enabled_topics = jndi_names
      end
    end

    #
    # Cliente JMS que possibilita a conexao com o servidor de aplicacoes Java EE
    # que prove o servico JMS.
    #
    class Client
      def initialize(configuration, jndi_context_builder)
        @configuration        = configuration
        @jndi_context_builder = jndi_context_builder
        
        @jndi_name_of_connection_factories = @configuration.enabled_connection_factories
        @jndi_name_of_enabled_queues       = {}
        @jndi_name_of_enabled_topics       = {}

        # Conexoes, filas, topicos, senders e receivers que serao habilitados
        @connection_factories               = {}
        @queues                             = {}
        @queue_senders                      = {}
        @queue_receivers                    = {}
        @topics                             = {}
        @topic_senders                      = {}
        @topic_receivers                    = {}

        # Foi startado?
        @started = false
      end
      
      def is_started?
        @started
      end
      
      def start
        raise StartClientError.new if is_started?
        
        begin
          @jndi_context = @jndi_context_builder.build
        rescue => cause
          raise ClientInitializationError.new(@configuration, cause)
        end
        
        @connection_factories = lookup_connection_factories(@jndi_name_of_connection_factories)
        @queues               = lookup_queues(@jndi_name_of_enabled_queues)
        @topics               = lookup_topics(@jndi_name_of_enabled_topics)
      end
      
      def is_stoped?
        !@started
      end
      
      def stop
        raise StopClientError.new if is_stoped?
        
        @jndi_context.close
      end

      def queue_connection_factory
        @connection_factories[:queue_connection_factory]
      end

      def topic_connection_factory
        @connection_factories[:topic_connection_factory]
      end

      def enable_queues(jndi_names = {})
        @jndi_name_of_enabled_queues = jndi_names
      end
      
      def queue_enabled?(queue_name)
        @jndi_name_of_enabled_queues.include?(queue_name)
      end
      
      def queue(queue_name)
        raise NameError, "Queue '#{queue_name}' does not exist." unless queue_enabled?(queue_name)
        
        @queues[queue_name]
      end

      def queue_sender(queue_name)
        @queue_senders[queue_name] ||=
            Messaging::Sender.new(queue_connection_factory, queue(queue_name))
      end

      def queue_receiver(queue_name)
        @queue_receivers[queue_name] ||=
            Messaging::Receiver.new(queue_connection_factory, queue(queue_name))
      end

      def enable_topics(jndi_names = {})
        @jndi_name_of_enabled_topics = jndi_names
      end
      
      def topic_enabled?(topic_name)
        @jndi_name_of_enabled_topics.include?(topic_name)
      end
      
      def topic(topic_name)
        raise NameError, "Topic '#{topic_name}' does not exist." unless topic_enabled?(topic_name)
        
        @topics[topic_name]
      end

      def topic_sender(topic_name)
        @topic_senders[topic_name] ||=
            Messaging::Sender.new(topic_connection_factory, topic(topic_name))
      end

      def topic_receiver(topic_name)
        @topic_receivers[topic_name] ||=
            Messaging::Receiver.new(topic_connection_factory, topic(topic_name))
      end
      
      # -- Private methods -- #
      private
      
        def lookup_connection_factories(jndi_names = {})
          lookuped_connection_factories = {}
          
          jndi_names.each_pair do |key, jndi_name|
            lookuped_connection_factories[key] = @jndi_context.lookup(jndi_name)
          end
          
          lookuped_connection_factories
        end

        def lookup_queues(jndi_names = {})
          lookuped_queues = {}
          
          jndi_names.each do |key, jndi_name|
            lookuped_queues[key] = @jndi_context.lookup(jndi_name)
          end
          
          lookuped_queues
        end

        def lookup_topics(jndi_names = {})
          lookuped_topics = {}
          
          jndi_names.each do |key, jndi_name|
            lookuped_topics[key] = @jndi_context.lookup(jndi_name)
          end
          
          lookuped_topics
        end
    end
    
    class ClientInitializationError < StandardError
      attr_reader :properties, :cause
      
      def initialize(properties, cause)
        super("Could not open connection to server. Verify the properties's properties.")
        
        @properties = properties
        @cause      = cause
      end
    end

    class StartClientError < StandardError
      def initialize
        super("Could not start client because it is already started.")
      end
    end

    class StopClientError < StandardError
      def initialize
        super("Could not stop client because it is already stoped.")
      end
    end
  end
  
  module JNDI
    
    #
    # Builder para construcao de contexto JNDI para conexao com o middleware
    # de JMS.
    #
    class ContextBuilder
      attr_accessor :jms_client_jar, :jndi_properties
      
      def initialize(jms_client_jar, jndi_properties)
        @jms_client_jar = jms_client_jar
        @jndi_properties   = jndi_properties
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
