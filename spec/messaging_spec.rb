require File.dirname(File.expand_path(__FILE__)) + '/spec_helper.rb'

describe JSparrow::Messaging do

  context 'when have a Sender and a Receiver for a Queue' do
  
    before(:all) do
      @jms_client = new_jms_client
      @jms_client.start
    
      @sender   = @jms_client.queue_sender(:test_queue)
      @receiver = @jms_client.queue_receiver(:test_queue)
    end
  
    after(:all) do
      @jms_client.stop
    end
  
    it 'should send a text_message and next receive it' do
      my_text = 'Mensagem de texto enviada da spec'
    
      @sender.send_text_message(my_text) do |msg|
        msg.add_criteria_to_reception('recipient', 'jsparrow-spec')
      end
    
      received_text = nil
    
      @receiver.receive_message(:selector => "recipient = 'jsparrow-spec'") do |msg|
        received_text = msg.text
      end
    
      received_text.should eql my_text
    end
  
    it 'should send a object_message and next receive it' do
      my_object = java.util.ArrayList.new
      my_object << 'Obj1 enviado da spec'
    
      @sender.send_object_message(my_object) do |msg|
        msg.add_criteria_to_reception('recipient', 'jsparrow-spec')
      end
    
      received_object = nil
    
      @receiver.receive_message(:selector => "recipient = 'jsparrow-spec'") do |msg|
        received_object = msg.object
      end
    
      received_object.should eql my_object
    end
  
    it 'should send a map_message and next receive it' do
      my_id_long = 1234567
    
      @sender.send_map_message do |msg|
        msg.add_criteria_to_reception('recipient', 'jsparrow-spec')
        msg.set_long('id', my_id_long)
      end
    
      received_id_long = nil
    
      @receiver.receive_message(:selector => "recipient = 'jsparrow-spec'") do |msg|
        received_id_long = msg.get_long('id')
      end
    
      received_id_long.should eql my_id_long
    end
  
  it 'should send a message and next receive it with criterias' do
    my_text = 'Mensagem de texto enviada da spec'
  
    @sender.send_text_message(my_text) do |msg|
      msg.add_criteria_to_reception('recipient', 'jsparrow-spec')
    end
  
    received_text = nil
  
    @receiver.receive_message(:timeout => 1000, :selector => "recipient = 'jsparrow-spec'") do |msg|
      received_text = msg.text
    end
  
    received_text.should eql my_text
  end

    it 'should send messages a lot and next receive it with criterias' do
      my_text = 'Mensagem de texto enviada da spec'
    
      my_object = java.util.ArrayList.new
      my_object << 'Obj1 enviado da spec'
    
      my_id_long = 1234567
    
      @sender.send_messages do |session, producer|
        #--- TextMessage
        text_message = session.create_text_message(my_text)
        text_message.add_criteria_to_reception('recipient', 'jsparrow-spec')
        producer.send(text_message)
      
        #--- objectMessage
        object_message = session.create_object_message(my_object)
        object_message.add_criteria_to_reception('recipient', 'jsparrow-spec')
        producer.send(object_message)
      
        #--- MapMessage
        map_message = session.create_map_message
        map_message.add_criteria_to_reception('recipient', 'jsparrow-spec')
        map_message.set_long('id', my_id_long)
        producer.send(map_message)
      
        # Commita as tres mensagens enviadas na sessao
        session.commit
      end
    
      received_text    = nil
      received_object  = nil
      received_id_long = nil
    
      @receiver.receive_messages(:timeout => 1000, :selector => "recipient = 'jsparrow-spec'") do |msg|
        if msg.is_text_message?
          received_text = msg.text
        end
      
        if msg.is_object_message?
          received_object = msg.object
        end
      
        if msg.is_map_message?
          received_id_long = msg.get_long('id')
        end
      end
    
      received_text.should    eql my_text
      received_object.should  eql my_object
      received_id_long.should eql my_id_long
    end
  end
end
