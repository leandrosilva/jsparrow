require File.dirname(File.expand_path(__FILE__)) + '/spec_helper.rb'

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
  
    it 'should allow create a new Client' do
      jms_client = new_jms_client
    
      jms_client.class.should be JSparrow::Client
    end
  
    it 'should allow create a new named Listener' do
      jms_listener = new_named_jms_listener
    
      jms_listener.class.superclass.should be JSparrow::Connection::Listener
    end
    
    it 'should allow create a new anonymous Listener' do
      jms_listener = new_anonymous_jms_listener
      
      jms_listener.class.should be JSparrow::Connection::Listener
      jms_listener.respond_to?(:on_receive_message).should be true
    end
  end
end