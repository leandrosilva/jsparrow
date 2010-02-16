# Classes Java usadas nesse arquivo
import 'javax.naming.InitialContext'

module JSparrow
  module Connection

    #
    # Cliente JMS que possibilita a conexao com o servidor de aplicacoes Java EE
    # que prove o servico JMS.
    #
    class Client
      def initialize(connection_config, jndi_context_builder)
        @connection_config    = connection_config
        @jndi_context_builder = jndi_context_builder
    
        # Conexoes, filas, topicos, senders e receivers que serao habilitados
        @connection_factories = {}
        @queues               = {}
        @queue_senders        = {}
        @queue_receivers      = {}
        @topics               = {}
        @topic_senders        = {}
        @topic_receivers      = {}

        # Foi iniciado?
        @started = false
      end
  
      def is_started?
        @started
      end
  
      def start
        raise InvalidClientStateError.new('started', 'start') if is_started?
    
        begin
          @jndi_context = @jndi_context_builder.build
        rescue => cause
          raise ClientInitializationError.new(@connection_config, cause)
        end
    
        @connection_factories, @queues, @topics = lookup_resources
    
        @started = true
      end
  
      def is_stoped?
        !@started
      end
  
      def stop
        raise InvalidClientStateError.new('stoped', 'stop') if is_stoped?
    
        @jndi_context.close
    
        @started = false  
      end

      def queue_connection_factory_enabled?
        @connection_config.enabled_connection_factories.include?(:queue_connection_factory)
      end

      def queue_connection_factory
        @connection_factories[:queue_connection_factory]
      end
  
      def queue_enabled?(queue_name)
        @connection_config.enabled_queues.include?(queue_name)
      end
  
      def queue(queue_name)
        raise NameError, "Queue '#{queue_name}' does not exist." unless queue_enabled?(queue_name)
    
        @queues[queue_name]
      end

      def queue_sender(queue_name)
        @queue_senders[queue_name] ||=
            Messaging::Sender.new(queue_connection_factory, queue(queue_name))
      end

      def queue_receiver(queue_name)
        @queue_receivers[queue_name] ||=
            Messaging::Receiver.new(queue_connection_factory, queue(queue_name))
      end

      def topic_connection_factory_enabled?
        @connection_config.enabled_connection_factories.include?(:topic_connection_factory)
      end

      def topic_connection_factory
        @connection_factories[:topic_connection_factory]
      end
  
      def topic_enabled?(topic_name)
        @connection_config.enabled_topics.include?(topic_name)
      end
  
      def topic(topic_name)
        raise NameError, "Topic '#{topic_name}' does not exist." unless topic_enabled?(topic_name)
    
        @topics[topic_name]
      end

      def topic_sender(topic_name)
        @topic_senders[topic_name] ||=
            Messaging::Sender.new(topic_connection_factory, topic(topic_name))
      end

      def topic_receiver(topic_name)
        @topic_receivers[topic_name] ||=
            Messaging::Receiver.new(topic_connection_factory, topic(topic_name))
      end
  
      # -- Private methods -- #
      private

        def lookup_resources
          @lookuped_connection_factories = lookup_resource(@connection_config.enabled_connection_factories)
          @lookuped_queues               = lookup_resource(@connection_config.enabled_queues)
          @lookuped_topic                = lookup_resource(@connection_config.enabled_topics)
          
          return @lookuped_connection_factories, @lookuped_queues, @lookuped_topic
        end
  
        def lookup_resource(jndi_names = {})
          lookuped = {}
      
          return lookuped unless jndi_names
          
          jndi_names.each do |key, jndi_name|
            lookuped[key] = @jndi_context.lookup(jndi_name)
          end
      
          lookuped
        end
    end

    class ClientInitializationError < StandardError
      attr_reader :config, :cause
  
      def initialize(config, cause)
        super("Could not open connection to server. Verify the config's config.")
    
        @config = config
        @cause  = cause
      end
    end

    class InvalidClientStateError < StandardError
      attr_reader :state, :operation
  
      def initialize(state, operation)
        super("Could not did #{operation} because client is #{state}.")
    
        @state     = state
        @operation = operation
      end
    end
  end
end
