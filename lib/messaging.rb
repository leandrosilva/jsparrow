# Classes Java usadas nesse arquivo
import 'javax.jms.Session'

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
        
        class << session
          include JMS::Session::OverrideMethods
        end
        
        # Passa o controle para quem trata a emissao de mensagens
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
        
          class << session
            include JMS::Session::OverrideMethods
          end
        
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
        receive(:one_message, criteria_for_receiving, &message_handler)
      end

      def receive_messages(criteria_for_receiving = {:timeout => DEFAULT_RECEIVER_TIMEOUT, :selector => ''}, &message_handler)
        receive(:many_messages, criteria_for_receiving, &message_handler)
      end
      
      # --- Private methods --- #
      private
      
        def receive(how_much_messages, criteria_for_receiving, &message_handler)
          # Cria uma conexao, uma sessao e um consumidor de qualquer tipo de mensagem
          connection = @connection_factory.create_connection
          session    = connection.create_session(false, Session::AUTO_ACKNOWLEDGE)
      
          class << session
            include JMS::Session::OverrideMethods
          end

          consumer = session.create_consumer(@destination, criteria_for_receiving[:selector])
        
          # Prepara a conexao para receber mensagens
          connection.start
        
          # Inicia o recebimento de mensagens
          timeout = criteria_for_receiving[:timeout] || DEFAULT_RECEIVER_TIMEOUT
          
          # Uma (if) mensagem ou muitas (while) mensagens?
          conditional_keyword = (how_much_messages.eql? :one_message) ? 'if' : 'while'
        
          eval %Q{
            #{conditional_keyword} (received_message = consumer.receive(timeout))
              # Delega o tratamento da mensagem para o bloco recebido
              message_handler.call(received_message)
            end
          }
        
          # Fecha a conexao
          connection.close
        end
    end
  end
end