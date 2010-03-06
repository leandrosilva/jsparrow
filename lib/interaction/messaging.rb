import 'javax.jms.Session'

module JSparrow
  module Messaging

    #
    # Default timeout to receive messages = 1 millisecond.
    #
    DEFAULT_RECEIVER_TIMEOUT = 1000
  
    #
    # Base class to define messangers (for queues and topics).
    #
    class Base
      def initialize(connection_factory, destination)
        @connection_factory = connection_factory
        @destination        = destination
      end
    end
    
    #
    # Message sender.
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
        connection = @connection_factory.create_connection
        session    = connection.create_session(true, Session::AUTO_ACKNOWLEDGE)
        producer   = session.create_producer(@destination)
        
        class << session
          include JMS::Session::OverrideMethods
        end
        
        message_sender.call(session, producer)

        connection.close
      end
      
      private
      
        def send_message(&message_creator)
          connection = @connection_factory.create_connection
          session    = connection.create_session(true, Session::AUTO_ACKNOWLEDGE)
          producer   = session.create_producer(@destination)
        
          class << session
            include JMS::Session::OverrideMethods
          end
        
          message = message_creator.call(session)
        
          producer.send(message)
        
          session.commit
          connection.close
        end
    end
    
    #
    # Message receiver.
    #
    class Receiver < Base
      def receive_message(criteria_for_receiving = {:timeout => DEFAULT_RECEIVER_TIMEOUT, :selector => ''}, &message_handler)
        receive(:one_message, criteria_for_receiving, &message_handler)
      end

      def receive_messages(criteria_for_receiving = {:timeout => DEFAULT_RECEIVER_TIMEOUT, :selector => ''}, &message_handler)
        receive(:many_messages, criteria_for_receiving, &message_handler)
      end
      
      private
      
        def receive(how_much_messages, criteria_for_receiving, &message_handler)
          connection = @connection_factory.create_connection
          session    = connection.create_session(false, Session::AUTO_ACKNOWLEDGE)
      
          class << session
            include JMS::Session::OverrideMethods
          end

          consumer = session.create_consumer(@destination, criteria_for_receiving[:selector])
        
          connection.start
        
          timeout = criteria_for_receiving[:timeout] || DEFAULT_RECEIVER_TIMEOUT
          
          # One message (if) or many masseges (while)
          conditional_keyword = (how_much_messages.eql? :one_message) ? 'if' : 'while'
        
          eval %Q{
            #{conditional_keyword} (received_message = consumer.receive(timeout))
              message_handler.call(received_message)
            end
          }
        
          connection.close
        end
    end
  end
end