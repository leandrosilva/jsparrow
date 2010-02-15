require 'rubygems'
require 'spec'

require File.dirname(File.expand_path(__FILE__)) + '/../lib/sparrow.rb'

#
# Modulo com metodos uteis para as specs.
#
module SparrowHelperMethods

  #
  # Apenas cria, mas nao faz o setup do cliente JMS.
  #
  def create_jms_client
    configure_connection
    
    Sparrow::Connection.new_client
  end
  
  def create_and_setup_jms_client
    configure_connection
    
    client = Sparrow::Connection.new_client
    client.enable_queues :pardal_queue => 'PardalQueue'
    client.enable_topics :pardal_topic => 'PardalTopic'

    client
  end
  
  # --- Private methods --- #
  private
    
    def configure_connection
      Sparrow::Connection.configure do |config|
        config.use_jms_client_jar '/opt/openjms/lib/openjms-0.7.7-beta-1.jar'

        config.use_jndi_properties :initial_context_factory => 'org.exolab.jms.jndi.InitialContextFactory',
                                   :provider_url            => 'tcp://localhost:3035'
                                 # :security_principal      => 'user',
                                 # :security_credentials    => 'password'

        config.enable_connection_factories :queue_connection_factory => 'ConnectionFactory', 
                                           :topic_connection_factory => 'ConnectionFactory'
      end
    end
end

#
# Enriquece a classe Spec::Example::ExampleGroup com o helper.
#
class Spec::Example::ExampleGroup
  include SparrowHelperMethods
end
