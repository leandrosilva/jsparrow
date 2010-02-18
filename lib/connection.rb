# Classes Java usadas nesse arquivo
import 'java.util.Hashtable'
import 'javax.naming.InitialContext'

module JSparrow
  module Connection

    #
    # Metodo usado para configurar a conexao com o provedor de JMS.
    #
    def self.configure
      @@configuration = Configuration.new
      
      yield @@configuration
      
      @@jndi_context_builder = JNDI::ContextBuilder.new(@@configuration.jms_client_jar, @@configuration.jndi_properties)

      @@configuration
    end
    
    #
    # Metodo usado para obter a configuracao para conexao com o provedor de JMS.
    #
    def self.configuration
      @@configuration
    end
    
    #
    # Metodo usado para criar um novo Client JMS.
    #
    def self.new_client
      connection = Base.new(@@configuration, @@jndi_context_builder)
      
      Client.new(connection)
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
        !@opened
      end

      def close
        raise InvalidStateError.new('closed', 'close') if is_closed?
    
        @jndi_context.close
    
        @opened = false  
      end

      def lookup_resource(jndi_names = {})
        lookuped_resource = {}

        return lookuped_resource unless jndi_names
    
        jndi_names.each do |key, jndi_name|
          lookuped_resource[key] = @jndi_context.lookup(jndi_name)
        end

        lookuped_resource
      end
    end

    #
    # Configuracoes necessarias para que clientes JMS se conetem
    # ao provedor de mensageria via contexto JNDI.
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
