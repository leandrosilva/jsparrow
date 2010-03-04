require File.dirname(File.expand_path(__FILE__)) + '/spec_helper.rb'

describe JSparrow::Connection::Listener do

  subject do
    new_jms_listener
  end

  context 'When inherited for listening a queue' do

    it 'should listen to "test_queue" destination' do
      subject.listen_to_destination.should eql :queue => :test_queue
    end
  end

  context 'When inherited and created,' do
  
    it 'should be started and stoped' do
      subject.start_listening
    
      subject.is_listening?.should be true
    
      subject.stop_listening
    
      subject.is_listening?.should be false
    end
  
    it 'should receive a message' do
      send_message_to_listener 'TestQueueListener'
    
      subject.start_listening
    
      sleep 1 # espera um pouquinho pra mensagem ser entregue
    
      subject.received_messages.size.should eql 1

      subject.stop_listening
    end
  end
end