# Classes java usadas nesse arquivo
import 'javax.jms.Session'
import 'javax.jms.MessageListener'

module Sparrow
  module JMS
    module Messaging

      #
      # Tempo padrão de timeout no recebimento de mensagens = 1 milesegundo.
      #
      DEFAULT_RECEIVER_TIMEOUT = 1000
    
      #
      # Classe base para mensageiros, que enviam ou recebem mensagens, tanto
      # para filas ou tópicos.
      #
      class Base
        def initialize(connection_factory, destination)
          # Fábrica de conexões JMS
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
            
            # Se houver uma bloco para tratamento da mensagem
            if block_given?
              yield(text_message)
            end
            
            text_message
          end          
        end
        
        def send_object_message(object)
          send_message do |session|
            object_message = session.create_object_message(object)
            
            # Se houver uma bloco para tratamento da mensagem
            if block_given?
              yield(object_message)
            end
            
            object_message
          end
        end
        
        def send_map_message
          send_message do |session|
            map_message = session.create_map_message
            
            # Se houver uma bloco para tratamento da mensagem
            if block_given?
              yield(map_message)
            end
            
            map_message
          end
        end
        
        def send_messages(&message_sender)
          # Cria uma conexão, uma sessão e um emissor de qualquer tipo de mensagem
          connection = @connection_factory.create_connection
          session    = connection.create_session(true, Session::AUTO_ACKNOWLEDGE)
          producer   = session.create_producer(@destination)
          
          # Passa o controle que trata a emissão de mensagens
          message_sender.call(session, producer)

          # Fecha a conexão
          connection.close
        end
        
        # --- Private methods --- #
        private
        
        def send_message(&message_creator)
          # Cria uma conexão, uma sessão e um emissor de qualquer tipo de mensagem
          connection = @connection_factory.create_connection
          session    = connection.create_session(true, Session::AUTO_ACKNOWLEDGE)
          producer   = session.create_producer(@destination)
          
          # Obtem uma mensagem (TextMessage, ObjectMessage ou MapMessage) do criador especifico
          message = message_creator.call(session)
          
          # Envia a mensagem
          producer.send(message)
          
          # Commita a sessão e fecha a conexão
          session.commit
          connection.close
        end
      end
      
      #
      # Receptor de mensagens.
      #
      class Receiver < Base    
        def receive_message(criteria_for_receiving = {:timeout => DEFAULT_RECEIVER_TIMEOUT, :selector => ''}, &message_handler)
          # Cria uma conexão, uma sessão e um consumidor de qualquer tipo de mensagem
          connection = @connection_factory.create_connection
          session    = connection.create_session(false, Session::AUTO_ACKNOWLEDGE)
          consumer   = session.create_consumer(@destination, criteria_for_receiving[:selector])
          
          # Prepara a conexão para receber mensagens
          connection.start
          
          # Inicia o recebimento de mensagens
          timeout = criteria_for_receiving[:timeout] || DEFAULT_RECEIVER_TIMEOUT
          
          while (received_message = consumer.receive(timeout))
            # Inclui o modulo de identificação de mensagem, util para o message_handler
            class << received_message
              include MessageType
            end
          
            # Delega o tratamento da mensagem para o bloco recebido
            message_handler.call(received_message)
          end
          
          # Fecha a conexão
          connection.close
        end
      end
      
      #
      # Ouvintes de mensagens.
      #
      # TODO: Completar a implementação. Ainda não está legal.
      #
      class Listener < Base
        include MessageListener
        
        def initialize(connection_factory, destination)
          super(connection_factory, destination)
        end
        
        def criteria_for_receiving(criteria = {:timeout => DEFAULT_RECEIVER_TIMEOUT, :selector => ''})
          # Valor default para timeout, caso não tenha sido informado
          @criteria_for_receiving[:timeout] = criteria[:timeout] || DEFAULT_RECEIVER_TIMEOUT
        end
        
        #
        # Nome pelo qual este listener será conhecido.
        #
        # Invariavelmente deve ser re-implementado nas subclasses.
        #
        def name
          raise Utils::Exception::AbstractMethodError.new('name')
        end
        
        #
        # Destino JMS que será escutado.
        #
        # Invariavelmente deve ser re-implementado nas subclasses.
        #
        def destination_name
          raise Utils::Exception::AbstractMethodError.new('destination_name')
        end
        
        #
        # Inicia a escuta de mensagens.
        #
        def start_listening
          # Cria uma conexão, uma sessão e um consumidor de qualquer tipo de mensagem
          connection = @connection_factory.create_connection
          session    = connection.create_session(false, Session::AUTO_ACKNOWLEDGE)
          consumer   = session.create_consumer(@destination, @criteria_for_receiving[:selector])
          
          # Registra-se como ouvinte
          consumer.message_listener = self
          
          # inicia a escuta de mensagens
          connection.start
        end
        
        #
        # Faz o enriquecimento do objeto mensagem e delega para o método on_receive_message
        # que, implementado pelas subclasses, efetivamente trata a mensagem.
        #
        # Não deve ser re-implementado por subclasses.
        #
        def on_message(received_message)
          class << received_message
            include MessageType
          end
          
          on_receive_message(received_message)
        end
        
        #
        # É executado todas as vezes que chega uma mensagem que atenda aos critérios
        # definido para este listener (na variável de instância @criteria).
        #
        # Invariavelmente deve ser re-implementado nas subclasses.
        #
        def on_receive_message(received_message)
          raise Utils::Exception::AbstractMethodError.new('on_receive_message')
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
end