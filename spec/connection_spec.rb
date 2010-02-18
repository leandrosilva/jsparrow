require File.dirname(File.expand_path(__FILE__)) + '/spec_helper.rb'

#
# Cenario que testa a configuracao a conexao com o provedor de JMS.
#
describe JSparrow::Connection, ', quando configurado,' do

  before(:all) do
    @config = configure_connection
  end
  
  it 'deveria ter jms_client_jar' do
    @config.jms_client_jar.should_not be nil
  end

  it 'deveria ter jndi_properties' do
    @config.jndi_properties.should_not be nil
  end

  it 'deveria ter enabled_connection_factories' do
    @config.enabled_connection_factories.should_not be nil
  end

  it 'deveria ter enabled_queues' do
    @config.enabled_queues.should_not be nil
  end

  it 'deveria ter enabled_topics' do
    @config.enabled_topics.should_not be nil
  end
  
  it 'deveria permitir criar um novo Client' do
    jms_client = JSparrow::Connection.new_client
    
    jms_client.class.should be JSparrow::Connection::Client
  end
  
  it 'deveria permitir criar um novo Listener' do
    jms_listener = JSparrow::Connection.new_listener
    
    jms_listener.class.should be JSparrow::Connection::Listener
  end
end
