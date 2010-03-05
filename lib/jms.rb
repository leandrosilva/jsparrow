# Libs directory definition
JEE_LIB_DIR = File.expand_path(File.dirname(__FILE__)) + '/jms'

# Befor all, the fundamental require for us
require 'java'

# Lib to JMS integration (contain the META-INF/applicationContext.xml)
require "#{JEE_LIB_DIR}/jsparrow-essential.jar"

#  Java EE
require "#{JEE_LIB_DIR}/javaee-1.5.jar"

# JMS API
require "#{JEE_LIB_DIR}/jms.jar"

module JSparrow
  module JMS
    
    #
    # Sobrescreve metodos do objeto session.
    #
    module OverrideSessionMethods
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
            include JSparrow::Messaging::MessageCriteria
          end
          
          message
        end
        
        def enriches_consumer(consumer)
          class << consumer
            include OverrideConsumerMethods
          end
          
          consumer
        end
    end
    
    #
    # Sobrescreve metodos do objeto consumidor.
    #
    module OverrideConsumerMethods
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
            include JSparrow::Messaging::MessageType
          end
          
          message
        end
    end
  end
end