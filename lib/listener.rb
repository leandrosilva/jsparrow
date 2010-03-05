# Classes Java usadas nesse arquivo
import 'javax.naming.InitialContext'
import 'javax.jms.MessageListener'

module JSparrow
  module Connection
    
    #
    # Ouvintes de mensagens.
    #
    # Sao como clientes JMS, mas apenas para recebimento de mensagens.
    #
    class Listener
      include MessageListener
      
      #
      # Nome (configurado no setup da conexao) do destino JMS que sera escutado.
      #
      # Invariavelmente deve ser usado pelas subclasses, para informar o nome da queue
      # ou topico que sera escutado.
      #
      # listen_to :queue => :registered_name_of_queue
      # listen_to :topic => :registered_name_of_topic
      #
      def self.listen_to(destination)
        configure(:listen_to_destination, destination)
      end
      
      #
      # Criterios de selecao de mensagens, seguindo o padrao JMS.
      #
      # Invariavelmente as subclasses precisam usar esse metodo, se quiserem definir
      # os criterios de recebimento que este listener levara em conta.
      #
      # receive_only_in_criteria :selector => "recipient = 'jsparrow-spec' and to_listener = 'TestQueueListener'"
      #
      def self.receive_only_in_criteria(criteria = {:selector => ''})
        configure(:criteria_to_receiving, criteria)
      end
      
      def initialize(connection)
        @connection = connection
      end

      def is_listening?
        @connection.is_opened?
      end

      #
      # Inicia a escuta de mensagens.
      #
      def start_listening
        @connection.open
        
        connection_factory, destination = lookup_resources
        
        selector = criteria_to_receiving[:selector] if respond_to? :criteria_to_receiving
        
        # Cria uma conexao para escuta de mensagens
        @listening_connection = connection_factory.create_connection
        
        # Cria uma sessao e um consumidor de qualquer tipo de mensagem
        session  = @listening_connection.create_session(false, Session::AUTO_ACKNOWLEDGE)
        consumer = session.create_consumer(destination, selector)
        
        # Registra-se como ouvinte
        consumer.message_listener = self
        
        # Inicia a escuta de mensagens
        @listening_connection.start
      end
      
      #
      # Finaliza a escuta de mensagens.
      #
      def stop_listening
        @listening_connection.close
        
        @connection.close
      end
      
      #
      # Faz o enriquecimento do objeto mensagem e delega para o metodo on_receive_message
      # que, implementado pelas subclasses, efetivamente trata a mensagem.
      #
      # Nao deve ser re-implementado por subclasses.
      #
      def on_message(received_message)
        class << received_message
          include Messaging::MessageType
        end
        
        on_receive_message(received_message)
      end
      
      #
      # E executado todas as vezes que chega uma mensagem que atenda aos criterios
      # definido para este listener (na variavel de instancia @criteria_for_receiving).
      #
      # Invariavelmente deve ser re-implementado nas subclasses.
      #
      def on_receive_message(received_message)
        raise Error::AbstractMethodError.new(self.class.superclass, 'on_receive_message')
      end
  
      # --- Private methods --- #
      private

        def self.configure(attribute, value)
          instance_eval do
            send(:define_method, attribute) do
              value
            end
          end
        end
      
        def lookup_resources
          destination_type, destination_name = get_destination_info
          
          jndi_name_of_connection_factory = get_jndi_name_of_connection_factory(destination_type, destination_name)
          jndi_name_of_destination        = get_jndi_name_of_destination(destination_type, destination_name)
          
          lookuped_connection_factory = @connection.lookup_resource(jndi_name_of_connection_factory)
          lookuped_destination        = @connection.lookup_resource(jndi_name_of_destination)
          
          return lookuped_connection_factory, lookuped_destination
        end
        
        def get_destination_info
          return listen_to_destination.keys[0], listen_to_destination.values[0]
        end
        
        def get_jndi_name_of_connection_factory(destination_type, destination_name)
          connection_factory_name = "#{destination_type}_connection_factory".to_sym
          
          @connection.configuration.enabled_connection_factories[connection_factory_name]
        end
        
        def get_jndi_name_of_destination(destination_type, destination_name)
          enabled_method_for_destinations = "enabled_#{destination_type}s"
          
          @connection.configuration.send(enabled_method_for_destinations)[destination_name]
        end
    end
  end
end