import 'javax.naming.InitialContext'

module JSparrow
  
  #
  # Client to send and receive messages to/from the JMS provider.
  #
  class Client
    def initialize(connection)
      @connection = connection

      @connection_factories = {}
      @queues               = {}
      @queue_senders        = {}
      @queue_receivers      = {}
      @topics               = {}
      @topic_senders        = {}
      @topic_receivers      = {}
    end

    def is_started?
      @connection.is_opened?
    end

    def start
      @connection.open

      @connection_factories, @queues, @topics = lookup_resources
    end

    def is_stoped?
      @connection.is_closed?
    end

    def stop
      @connection.close
    end

    def queue_enabled?(queue_name)
      @connection.configuration.enabled_queues.include?(queue_name)
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

    def topic_enabled?(topic_name)
      @connection.configuration.enabled_topics.include?(topic_name)
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

    private

      def queue_connection_factory
        @connection_factories[:queue_connection_factory]
      end

      def topic_connection_factory
        @connection_factories[:topic_connection_factory]
      end

      def lookup_resources
        lookuped_connection_factories = @connection.lookup_resources(@connection.configuration.enabled_connection_factories)
        lookuped_queues               = @connection.lookup_resources(@connection.configuration.enabled_queues)
        lookuped_topic                = @connection.lookup_resources(@connection.configuration.enabled_topics)
      
        return lookuped_connection_factories, lookuped_queues, lookuped_topic
      end
  end
end
