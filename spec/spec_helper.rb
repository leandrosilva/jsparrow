require 'rubygems'
require 'spec'

require File.dirname(File.expand_path(__FILE__)) + '/../lib/jsparrow.rb'

#
# Modulo com metodos uteis para as specs.
#
module JSparrowHelperMethods

  def configure_connection
    JSparrow::Connection.configure do
      use_jms_client_jar '/opt/openjms/lib/openjms-0.7.7-beta-1.jar'

      use_jndi_properties :initial_context_factory => 'org.exolab.jms.jndi.InitialContextFactory',
                          :provider_url            => 'tcp://localhost:3035'
                        # :security_principal      => 'user',
                        # :security_credentials    => 'password'
      
      enable_connection_factories :queue_connection_factory => 'ConnectionFactory', 
                                  :topic_connection_factory => 'ConnectionFactory'
      
      enable_queues :test_queue => 'TestQueue'
      
      enable_topics :test_topic => 'TestTopic'
    end
  end

  def new_jms_client
    configure_connection
    
    JSparrow::Connection.new_client
  end
  
  def new_jms_listener
    configure_connection
    
    JSparrow::Connection.new_listener :as => JSparrowHelperClasses::TestQueueListener
  end
  
  def create_jms_listener
    listener = JSparrow::Connection.create_listener(:topic => :test_topic) do |received_message|
      # do some thing
    end
    
    listener
  end
  
  def send_message_to_listener(listener_name)
    @jms_client = new_jms_client
    @jms_client.start
    
    my_text = 'Mensagem de texto enviada da spec para o listener TestQueueListener'
    
    @jms_client.queue_sender(:test_queue).send_text_message(my_text) do |msg|
      msg.set_string_property('recipient',   'jsparrow-spec')
      msg.set_string_property('to_listener', listener_name)
    end

    @jms_client.stop
  end
end

module JSparrowHelperClasses
  
  #
  # Listener da queue TestQueue
  #
  class TestQueueListener < JSparrow::Connection::Listener
    listen_to :queue => :test_queue
  
    receive_only_in_criteria :selector => "recipient = 'jsparrow-spec' and to_listener = 'TestQueueListener'"
  
    attr_reader :received_messages
  
    def initialize(connection)
      super(connection)
    
      @received_messages = []
    end
  
    def on_receive_message(received_message)
      @received_messages << received_messages
    end
  end
end
#
# Enriquece a classe Spec::Example::ExampleGroup com o helper.
#
class Spec::Example::ExampleGroup
  include JSparrowHelperMethods
end
