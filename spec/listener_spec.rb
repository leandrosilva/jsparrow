require File.dirname(File.expand_path(__FILE__)) + '/spec_helper.rb'

describe JSparrow::Listener do

  context 'when inherited and created' do

    subject do
      new_named_jms_listener
    end

    it 'should listen to "test_queue" destination' do
      subject.listen_to_destination.should eql :queue => :test_queue
    end
  
    it 'should be started and stoped' do
      subject.start_listening
    
      subject.is_listening?.should be true
    
      subject.stop_listening
    
      subject.is_listening?.should be false
    end
  
    it 'should receive a message' do
      subject.received_messages.size.should eql 0

      send_message_to_listener 'TestQueueListener'
    
      subject.start_listening
    
      sleep 1 # espera um pouquinho pra mensagem ser entregue
    
      subject.received_messages.size.should eql 1

      subject.stop_listening
    end
  end
  
  context 'when anonymously created' do
   
    subject do
      new_anonymous_jms_listener
    end
    
    it 'should listen to "test_queue" destination' do
      subject.listen_to_destination.should eql :queue => :test_queue
    end
    
    it 'should be started and stoped' do
      subject.start_listening
    
      subject.is_listening?.should be true
    
      subject.stop_listening
    
      subject.is_listening?.should be false
    end
  
    it 'should receive a message' do
      subject.received_messages.size.should eql 0

      send_message_to_listener 'anonymous'
    
      subject.start_listening
    
      sleep 1 # espera um pouquinho pra mensagem ser entregue
      
      # verify if message was received
      subject.received_messages.size.should eql 1

      subject.stop_listening
    end
  end
end