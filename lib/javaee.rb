# Libs directory definition
JEE_LIB_DIR = File.expand_path(File.dirname(__FILE__)) + '/javaee'

require 'java'
require "#{JEE_LIB_DIR}/jsparrow-essential.jar"
require "#{JEE_LIB_DIR}/javaee-1.5.jar"
require "#{JEE_LIB_DIR}/jms.jar"

module JSparrow
  module JMS

    module Session
      #
      # Sobrescreve metodos de instancia.
      #
      module OverrideMethods
        def create_text_message(text_message)
          enriches_message super(text_message)
        end

        def create_object_message(object_message)
          enriches_message super(object_message)
        end

        def create_map_message
          enriches_message super
        end
      
        def create_consumer(destination, criteria_for_receiving)
          enriches_consumer super(destination, criteria_for_receiving)
        end
      
        # --- Private methods -- #
        private
      
          def enriches_message(message)
            class << message
              include Message::TypingMethods
              include Message::CriteriaMethods
            end
          
            message
          end
        
          def enriches_consumer(consumer)
            class << consumer
              include Consumer::OverrideMethods
            end
          
            consumer
          end
      end
    end
    
    module Consumer
      #
      # Sobrescreve metodos de instancia.
      #
      module OverrideMethods
        def receive(timeout)
          received_message = super(timeout)
        
          if received_message.nil?
            received_message
          else
            enriches_message received_message
          end
        end
      
        # --- Private methods -- #
        private
      
          def enriches_message(message)
            class << message
              include Message::TypingMethods
            end
          
            message
          end
      end
    end
    
    module Message
      #
      # Identifica o tipo de uma mensagem.
      #
      module TypingMethods
        def is_text_message?
          respond_to? :get_text
        end
    
        def is_object_message?
          (respond_to? :get_object and !(respond_to? :get_long))
        end
    
        def is_map_message?
          respond_to? :get_long
        end
      end
    
      #
      # Adiciona criterios a mensagem.
      #
      module CriteriaMethods
        def add_criteria_to_reception(name, value)
          set_string_property(name, value)
        end
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