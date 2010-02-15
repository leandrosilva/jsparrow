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
    Sparrow::Connection.configure do |config|
      make_connection_configuration! config
    end
    
    Sparrow::Connection.new_client
  end
  
  def create_and_setup_jms_client
    Sparrow::Connection.configure do |config|
      make_complete_configuration! config
    end
    
    Sparrow::Connection.new_client
  end
  
  private
    
    def make_connection_configuration!(config)
      config.use_jms_client_jar '/opt/openjms/lib/openjms-0.7.7-beta-1.jar'

      config.use_jndi_properties :initial_context_factory => 'org.exolab.jms.jndi.InitialContextFactory',
                                 :provider_url            => 'tcp://localhost:3035'
                               # :security_principal      => 'user',
                               # :security_credentials    => 'password'
    end
    
    def make_complete_configuration!(config)
      make_connection_configuration! config

      config.enable_connection_factories :queue_connection_factory => 'ConnectionFactory', 
                                         :topic_connection_factory => 'ConnectionFactory'

      config.enable_queues :pardal_queue => 'PardalQueue'

      config.enable_topics :pardal_topic => 'PardalTopic'
    end
end

#
# Enriquece a classe Spec::Example::ExampleGroup com o helper.
#
class Spec::Example::ExampleGroup
  include SparrowHelperMethods
end
