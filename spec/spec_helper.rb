require 'rubygems'
require 'spec'

require File.dirname(File.expand_path(__FILE__)) + '/../lib/sparrow.rb'

#
# Modulo com metodos uteis para as propertiess.
#
module SparrowHelperMethods

  #
  # Apenas cria, mas nao faz o setup do cliente JMS.
  #
  # WARNING: OpenJMS will be used as JMS middleware, but any other could
  # be used with no problems.
  #
  def create_jms_client
    jms_client = Sparrow::JMS::Connection::Client.new do |properties|
      properties.client_jar_file         = '/opt/openjms/lib/openjms-0.7.7-beta-1.jar'
      properties.initial_context_factory = 'org.exolab.jms.jndi.InitialContextFactory'
      properties.provider_url            = 'tcp://localhost:3035'
      # properties.security_principal    = ''
      # properties.security_credentials  = ''
    end
  end
  
  #
  # Cria e faz o setup do cliente JMS, habilitando os connection factories, queues e topics
  # que ele pode usar.
  #
  def create_and_setup_jms_client
    jms_client = create_jms_client

    jms_client.enable_connection_factories(
        :queue_connection_factory => 'ConnectionFactory',
        :topic_connection_factory => 'ConnectionFactory'
      )
      
    jms_client.enable_queues(
        :pardal_queue => 'PardalQueue'
      )
      
    jms_client.enable_topics(
        :pardal_topic => 'PardalTopic'
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
