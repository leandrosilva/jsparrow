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
      # Nome JNDI da connection factory que ser usada para criar conexoes JMS.
      #
      # Invariavelmente deve ser usado pelas subclasses para informar qual devera ser
      # a connection factory usada por esse listener.
      #
      def self.use_connection_factory(jndi_name)
        configure(:connection_factory_name, jndi_name)
      end
      
      #
      # Nome JNDI do destino JMS que sera escutado.
      #
      # Invariavelmente deve ser usado pelas subclasses, para informar o nome da queue
      # ou topico que sera escutado.
      #
      def self.listen_to_destination(jndi_name)
        configure(:destination_name, jndi_name)
      end
      
      #
      # Criterios de selecao de mensagens, seguindo o padrao JMS.
      #
      # Invariavelmente as subclasses precisam usar esse metodo, se quiserem definir
      # os criterios de recebimento que este listener levara em conta.
      #
      def self.receive_only_in_criteria(criteria = {:timeout => DEFAULT_RECEIVER_TIMEOUT, :selector => ''})
        # Valor default para timeout, caso nao tenha sido informado
        criteria[:timeout] ||= DEFAULT_RECEIVER_TIMEOUT
        
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
        
        connection_factory = @connection.lookup_resource(connection_factory_name)
        destination        = @connection.lookup_resource(destination_name)
        
        # Cria uma conexao para escuta de mensagens
        @listening_connection = connection_factory.create_connection
        
        # Cria uma sessao e um consumidor de qualquer tipo de mensagem
        session  = listening_connection.create_session(false, Session::AUTO_ACKNOWLEDGE)
        consumer = session.create_consumer(destination, @criteria_for_receiving[:selector])
        
        # Registra-se como ouvinte
        consumer.message_listener = self
        
        # Inicia a escuta de mensagens
        connection.start
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
          include MessageType
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
        raise Error::AbstractMethodError.new('on_receive_message')
      end
  
      # --- Private methods --- #
      private

        def self.configure(attribute, value)
          self.instance_eval do
            send(:define_method, attribute) do
              value
            end
          end
        end
    end
  end
end