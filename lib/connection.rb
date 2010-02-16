# Classes Java usadas nesse arquivo
import 'java.util.Hashtable'
import 'javax.naming.InitialContext'

module JSparrow
  module Connection

    #
    # Metodo usado para configurar a conexao com o provedor de JMS.
    #
    def self.configure
      @@config = Configuration.new
      
      yield @@config
      
      @@config
    end
    
    #
    # Metodo usado para obter a configuracao para conexao com o provedor de JMS.
    #
    def self.configuration
      @@config
    end
    
    #
    # Metodo usado para criar um novo Client JMS.
    #
    def self.new_client
      jndi_context_builder = JNDI::ContextBuilder.new(@@config.jms_client_jar, @@config.jndi_properties)
      
      Client.new(@@config, jndi_context_builder)
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
