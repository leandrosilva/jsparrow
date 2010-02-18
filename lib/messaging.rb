# Classes Java usadas nesse arquivo
import 'javax.jms.Session'
import 'javax.jms.MessageListener'

module JSparrow
  module Messaging

    #
    # Tempo padrao de timeout no recebimento de mensagens = 1 milesegundo.
    #
    DEFAULT_RECEIVER_TIMEOUT = 1000
  
    #
    # Classe base para mensageiros, que enviam ou recebem mensagens, tanto
    # para filas ou topicos.
    #
    class Base
      def initialize(connection_factory, destination)
        # Fabrica de conexoes JMS
        @connection_factory = connection_factory

        # Destino JMS para envio ou recebimento de mensagens
        @destination = destination
      end
    end
    
    #
    # Emissor de mensagens.
    #
    class Sender < Base
      def send_text_message(text)
        send_message do |session|
          text_message = session.create_text_message(text)
          
          if block_given?
            yield(text_message)
          end
          
          text_message
        end          
      end
      
      def send_object_message(object)
        send_message do |session|
          object_message = session.create_object_message(object)
          
          if block_given?
            yield(object_message)
          end
          
          object_message
        end
      end
      
      def send_map_message
        send_message do |session|
          map_message = session.create_map_message
          
          if block_given?
            yield(map_message)
          end
          
          map_message
        end
      end
      
      def send_messages(&message_sender)
        # Cria uma conexao, uma sessao e um emissor de qualquer tipo de mensagem
        connection = @connection_factory.create_connection
        session    = connection.create_session(true, Session::AUTO_ACKNOWLEDGE)
        producer   = session.create_producer(@destination)
        
        # Passa o controle que trata a emissao de mensagens
        message_sender.call(session, producer)

        # Fecha a conexao
        connection.close
      end
      
      # --- Private methods --- #
      private
      
        def send_message(&message_creator)
          # Cria uma conexao, uma sessao e um emissor de qualquer tipo de mensagem
          connection = @connection_factory.create_connection
          session    = connection.create_session(true, Session::AUTO_ACKNOWLEDGE)
          producer   = session.create_producer(@destination)
        
          # Obtem uma mensagem (TextMessage, ObjectMessage ou MapMessage) do criador especifico
          message = message_creator.call(session)
        
          # Envia a mensagem
          producer.send(message)
        
          # Commita a sessao e fecha a conexao
          session.commit
          connection.close
        end
    end
    
    #
    # Receptor de mensagens.
    #
    class Receiver < Base    
      def receive_message(criteria_for_receiving = {:timeout => DEFAULT_RECEIVER_TIMEOUT, :selector => ''}, &message_handler)
        # Cria uma conexao, uma sessao e um consumidor de qualquer tipo de mensagem
        connection = @connection_factory.create_connection
        session    = connection.create_session(false, Session::AUTO_ACKNOWLEDGE)
        consumer   = session.create_consumer(@destination, criteria_for_receiving[:selector])
        
        # Prepara a conexao para receber mensagens
        connection.start
        
        # Inicia o recebimento de mensagens
        timeout = criteria_for_receiving[:timeout] || DEFAULT_RECEIVER_TIMEOUT
        
        while (received_message = consumer.receive(timeout))
          # Inclui o modulo de identificacao de mensagem, util para o message_handler
          class << received_message
            include MessageType
          end
        
          # Delega o tratamento da mensagem para o bloco recebido
          message_handler.call(received_message)
        end
        
        # Fecha a conexao
        connection.close
      end
    end
    
    #
    # Ouvintes de mensagens.
    #
    # TODO: Completar a implementacao. Ainda nao esta legal. (Ja dei um tapinha,
    #       acho que agora ta bem proximo do que deve ser.)
    #
    module Listener
      include MessageListener
      
      #
      # Nome JNDI da connection factory que ser usada para criar conexoes JMS.
      #
      # Invariavelmente deve ser usado pelas subclasses para informar qual devera
      # ser a connection factory usada por esse listener.
      #
      def self.use_connection_factory(jndi_name)
        configure(:connection_factory, jndi_name)
      end
      
      #
      # Nome JNDI do destino JMS que sera escutado.
      #
      # Invariavelmente deve ser usado pelas subclasses, para informar o nome
      # da queue ou topico que sera escutado.
      #
      def self.listen_to_destination(jndi_name)
        configure(:destination_name, jndi_name)
      end
      
      #
      # Criterios de selecao de mensagens, seguindo o padrao JMS.
      #
      # Invariavelmente as subclasses precisam usar esse metodo para definir
      # os criterios de recebimento que este listener levara em conta.
      #
      def self.receive_only_in_criteria(criteria = {:timeout => DEFAULT_RECEIVER_TIMEOUT, :selector => ''})
        # Valor default para timeout, caso nao tenha sido informado
        criteria[:timeout] ||= DEFAULT_RECEIVER_TIMEOUT
        
        configure(:criteria_to_receiving, criteria)
      end

      #
      # Inicia a escuta de mensagens.
      #
      def start_listening
        # Cria uma conexao, uma sessao e um consumidor de qualquer tipo de mensagem
        connection = @connection_factory.create_connection
        session    = connection.create_session(false, Session::AUTO_ACKNOWLEDGE)
        consumer   = session.create_consumer(@destination, @criteria_for_receiving[:selector])
        
        # Registra-se como ouvinte
        consumer.message_listener = self
        
        # Inicia a escuta de mensagens
        connection.start
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
  
  #
  # Identifica o tipo de uma mensagem.
  #
  module MessageType
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
end