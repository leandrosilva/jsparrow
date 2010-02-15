require 'rubygems'
require 'spec'

require File.dirname(File.expand_path(__FILE__)) + '/../lib/sparrow.rb'

#
# Unica configuracao necessaria para o Sparrow
#
Sparrow::Connection.configure do |conf|
  conf.use_middleware_client '/opt/openjms/lib/openjms-0.7.7-beta-1.jar'
  
  conf.use_jndi_properties :initial_context_factory => 'org.exolab.jms.jndi.InitialContextFactory',
                           :provider_url            => 'tcp://localhost:3035'
                           # :security_principal    => 'user',
                           # :security_credentials  => 'password'
  
  conf.enable_connection_factories :queue_connection_factory => 'ConnectionFactory', 
                                   :topic_connection_factory => 'ConnectionFactory'
  
  conf.enable_queues :pardal_queue => 'PardalQueue'
    
  conf.enable_topics :pardal_topic => 'PardalTopic'
end

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
    Sparrow::Connection.new_client
  end
end

#
# Enriquece a classe Spec::Example::ExampleGroup com o helper.
#
class Spec::Example::ExampleGroup
  include SparrowHelperMethods
end
