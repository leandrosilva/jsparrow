# Classes Java usadas nesse arquivo
import 'javax.naming.InitialContext'
import 'javax.jms.MessageListener'

module JSparrow
  #
  # Message listener.
  #
  class Listener
    include MessageListener
    
    #
    # Class methods to configure subclasses.
    #
    class << self
      #
      # Name (configured in connection setup) of JMS destination to listen to.
      #
      # Must be used by subclasses to configure destination.
      #
      # listen_to :queue => :registered_name_of_queue
      # listen_to :topic => :registered_name_of_topic
      #
      def listen_to(destination)
        configure(:listen_to_destination, destination)
      end
    
      #
      # Selector criteria to receive the messages, following the JMS pattern.
      #
      # Should be used by subclasses when want to set criterias to message selection.
      #
      # receive_only_in_criteria :selector => "recipient = 'jsparrow-spec' and to_listener = 'TestQueueListener'"
      #
      def receive_only_in_criteria(criteria = {:selector => ''})
        configure(:criteria_to_receiving, criteria)
      end
      
      private
    
        def configure(attribute, value)
          instance_eval do
            send(:define_method, attribute) do
              value
            end
          end
        end
    end
    
    def initialize(connection)
      @connection = connection
    end

    def is_listening?
      @connection.is_opened?
    end

    def start_listening
      @connection.open
      
      connection_factory, destination = lookup_resources
      
      selector = criteria_to_receiving[:selector] if respond_to? :criteria_to_receiving
      
      @listening_connection = connection_factory.create_connection
      
      session  = @listening_connection.create_session(false, Session::AUTO_ACKNOWLEDGE)
      consumer = session.create_consumer(destination, selector)
      
      consumer.message_listener = self
      
      @listening_connection.start
    end
    
    def stop_listening
      @listening_connection.close
      
      @connection.close
    end
    
    #
    # It's part of JMS Listener interface. Shouldn't be overrided by subclasses.
    #
    def on_message(received_message)
      class << received_message
        include JMS::Message::TypingMethods
      end
      
      on_receive_message(received_message)
    end
    
    #
    # Callback mathod to receive enriched messages.
    #
    # Must be overrided by subclasses.
    #
    def on_receive_message(received_message)
      raise Error::AbstractMethodError.new(self.class.superclass, 'on_receive_message')
    end

    private
    
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