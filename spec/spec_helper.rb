require 'rubygems'
require 'spec'

require File.dirname(File.expand_path(__FILE__)) + '/../lib/jsparrow.rb'

#
# Modulo com metodos uteis para as specs.
#
module JSparrowHelperMethods

  def create_jms_client
    configure_connection
    
    JSparrow::Connection.new_client
  end
  
  def create_jms_listener
    configure_connection
    
    JSparrow::Connection.new_listener :as => TestQueueListener
  end

  def configure_connection
    JSparrow::Connection.configure do |connection|
      connection.use_jms_client_jar '/opt/openjms/lib/openjms-0.7.7-beta-1.jar'

      connection.use_jndi_properties :initial_context_factory => 'org.exolab.jms.jndi.InitialContextFactory',
                                     :provider_url            => 'tcp://localhost:3035'
                                   # :security_principal      => 'user',
                                   # :security_credentials    => 'password'
      
      connection.enable_connection_factories :queue_connection_factory => 'ConnectionFactory', 
                                             :topic_connection_factory => 'ConnectionFactory'
      
      connection.enable_queues :test_queue => 'TestQueue'
      
      connection.enable_topics :test_topic => 'TestTopic'
    end
  end

  #
  # Listener da queue TestQueue
  #
  class TestQueueListener < JSparrow::Connection::Listener
    use_connection_factory :queue_connection_factory
    
    listen_to_destination :test_queue
  end
end

#
# Enriquece a classe Spec::Example::ExampleGroup com o helper.
#
class Spec::Example::ExampleGroup
  include JSparrowHelperMethods
end
