require File.dirname(File.expand_path(__FILE__)) + '/spec_helper.rb'

#
# Cenario que testa a configuracao a conexao com o provedor de JMS.
#
describe JSparrow::Connection, ', quando configurado,' do

  before(:all) do
    @configuration = configure_connection
  end
  
  it 'deveria ter jms_client_jar' do
    @configuration.jms_client_jar.should_not be nil
  end

  it 'deveria ter jndi_properties' do
    @configuration.jndi_properties.should_not be nil
  end

  it 'deveria ter connection_factories habilitadas para queues e topics' do
    @configuration.enabled_connection_factories[:queue_connection_factory].should_not be nil
    @configuration.enabled_connection_factories[:topic_connection_factory].should_not be nil
  end

  it 'deveria ter queues habilitadas' do
    @configuration.enabled_queues.should_not be nil
  end

  it 'deveria ter topics habilitados' do
    @configuration.enabled_topics.should_not be nil
  end
  
  it 'deveria permitir criar um novo Client' do
    jms_client = create_jms_client
    
    jms_client.class.should be JSparrow::Connection::Client
  end
  
  it 'deveria permitir criar um novo Listener' do
    jms_listener = create_jms_listener
    
    jms_listener.class.superclass.should be JSparrow::Connection::Listener
  end
end
