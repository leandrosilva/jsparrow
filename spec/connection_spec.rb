require File.dirname(File.expand_path(__FILE__)) + '/spec_helper.rb'

#
# Cenario que testa a configuracao a conexao com o provedor de JMS.
#
describe JSparrow::Connection do

  subject do
    configure_connection
  end
  
  context 'When configured' do
  
    it 'should known a jms_client_jar' do
      subject.jms_client_jar.should_not be nil
    end

    it 'should known a jndi_properties' do
      subject.jndi_properties.should_not be nil
    end

    it 'should have the queue_connection_factory enabled' do
      subject.enabled_connection_factories[:queue_connection_factory].should_not be nil
    end

    it 'should have the topic_connection_factory enabled' do
      subject.enabled_connection_factories[:topic_connection_factory].should_not be nil
    end

    it 'should have the test_queue enabled' do
      subject.enabled_queues[:test_queue].should_not be nil
    end

    it 'should have the test_topic enabled' do
      subject.enabled_topics[:test_topic].should_not be nil
    end
  
    it 'should let create a new Client' do
      jms_client = create_jms_client
    
      jms_client.class.should be JSparrow::Connection::Client
    end
  
    it 'should let create a new Listener' do
      jms_listener = create_jms_listener
    
      jms_listener.class.superclass.should be JSparrow::Connection::Listener
    end
  end
end