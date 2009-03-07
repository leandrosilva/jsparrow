require 'rubygems'
require 'spec'

require File.dirname(File.expand_path(__FILE__)) + '/../lib/sparrow.rb'

#
# Módulo com métodos uteis para as propertiess.
#
module SparrowHelperMethods

  #
  # Apenas cria, mas não faz o setup do cliente JMS.
  #
  def create_jms_client
    jms_client = Sparrow::JMS::Connection::Client.new do |properties|
      properties.client_jar_file         = '/home/leandro/Desenvolvimento/java/servers/oc4j_extended_101330/j2ee/home/oc4jclient.jar'
      properties.initial_context_factory = 'oracle.j2ee.naming.ApplicationClientInitialContextFactory'
      properties.provider_url            = 'ormi://localhost:23791'
      properties.security_principal      = 'oc4jadmin'
      properties.security_credentials    = 'welcome'
    end
  end
  
  #
  # Cria e faz o setup do cliente JMS, habilitando os connection factories, queues e topics
  # que ele pode usar.
  #
  def create_and_setup_jms_client
    jms_client = create_jms_client

    jms_client.enable_connection_factories(
        :queue_connection_factory => 'jms/PardalQCF',
        :topic_connection_factory => 'jms/PardalTCF'
      )
      
    jms_client.enable_queues(
        :pardal_queue => 'jms/PardalQueue'
      )
      
    jms_client.enable_topics(
        :pardal_topic => 'jms/PardalTopic'
      )
    
    # Pronto para ser usado!
    jms_client
  end
end

#
# Enriquece a classe Spec::Example::ExampleGroup com o helper.
#
class Spec::Example::ExampleGroup
  include SparrowHelperMethods
end
