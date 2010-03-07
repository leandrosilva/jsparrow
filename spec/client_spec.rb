require File.dirname(File.expand_path(__FILE__)) + '/spec_helper.rb'

describe JSparrow::Interactors::Client do

  subject do
    new_jms_client
  end
  
  context 'when created' do
  
    it 'should be started and stoped' do
      subject.start
    
      subject.is_started?.should be true
      subject.is_stoped?.should be false
    
      subject.stop
    
      subject.is_started?.should be false
      subject.is_stoped?.should be true
    end
  
    it 'should not be started if already is' do
      subject.start
    
      lambda {
          subject.start
        }.should raise_error JSparrow::Connection::InvalidStateError
    
      subject.stop
    end
  
    it 'should not be stoped if already is' do
      subject.start
      subject.stop
    
      lambda {
          subject.stop
        }.should raise_error JSparrow::Connection::InvalidStateError
    end
  end
  
  context 'when started' do

    before(:all) do
      subject.start
    end

    after(:all) do
      subject.stop
    end

    it 'should allow get a Sender for a Queue' do
      subject.queue_sender(:test_queue).should_not be nil
    end

    it 'should allow get a Receiver for a Queue' do
      subject.queue_receiver(:test_queue).should_not be nil
    end

    it 'should allow get a Sender for a Topic' do
      subject.topic_sender(:test_topic).should_not be nil
    end

    it 'should allow get a Receiver for a Topic' do
      subject.topic_receiver(:test_topic).should_not be nil
    end
  end
end