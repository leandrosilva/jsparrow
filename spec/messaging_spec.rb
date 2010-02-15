require File.dirname(File.expand_path(__FILE__)) + '/spec_helper.rb'

#
# Cenario pos-obtencao de um Sender e um Receiver, quando deve ser possivel enviar e
# receber mensagens de tres tipos (Texto, Objeto e Mapa) de uma queue especifica,
# individualmente ou em lote.
#
describe Sparrow::Messaging, ', quando tem um Sender e um Receiver para uma Queue especifica,' do
  
  before(:all) do
    jms_client = create_and_setup_jms_client
    
    @sender   = jms_client.queue_sender(:pardal_queue)
    @receiver = jms_client.queue_receiver(:pardal_queue)
  end
  
  it 'deveria possibilitar enviar uma mensagem de texto e recebe-la' do
    my_text = 'Mensagem de texto enviada da spec'
    
    @sender.send_text_message(my_text) do |msg|
      msg.set_string_property('recipient', 'sparrow-spec')
    end
    
    received_text = nil
    
    @receiver.receive_message(:selector => "recipient = 'sparrow-spec'") do |msg|
      received_text = msg.text
    end
    
    received_text.should eql my_text
  end
  
  it 'deveria possibilitar enviar um objeto e recebe-lo' do
    my_object = java.util.ArrayList.new
    my_object << 'Obj1 enviado da spec'
    
    @sender.send_object_message(my_object) do |msg|
      msg.set_string_property('recipient', 'sparrow-spec')
    end
    
    received_object = nil
    
    @receiver.receive_message(:selector => "recipient = 'sparrow-spec'") do |msg|
      received_object = msg.object
    end
    
    received_object.should eql my_object
  end
  
  it 'deveria possibilitar enviar uma mensagem mapa e recebe-la' do
    my_id_long = 1234567
    
    @sender.send_map_message do |msg|
      msg.set_string_property('recipient', 'sparrow-spec')
      msg.set_long('id', my_id_long)
    end
    
    received_id_long = nil
    
    @receiver.receive_message(:selector => "recipient = 'sparrow-spec'") do |msg|
      received_id_long = msg.get_long('id')
    end
    
    received_id_long.should eql my_id_long
  end
  
  it 'deveria possibilitar enviar varias mensagens de qualquer tipo e recebe-las' do
    my_text = 'Mensagem de texto enviada da spec'
    
    my_object = java.util.ArrayList.new
    my_object << 'Obj1 enviado da spec'
    
    my_id_long = 1234567
    
    @sender.send_messages do |session, producer|
      #--- TextMessage
      text_message = session.create_text_message(my_text)
      text_message.set_string_property('recipient', 'sparrow-spec')
      producer.send(text_message)
      
      #--- objectMessage
      object_message = session.create_object_message(my_object)
      object_message.set_string_property('recipient', 'sparrow-spec')
      producer.send(object_message)
      
      #--- MapMessage
      map_message = session.create_map_message
      map_message.set_string_property('recipient', 'sparrow-spec')
      map_message.set_long('id', my_id_long)
      producer.send(map_message)
      
      # Commita as tres mensagens enviadas na sessao
      session.commit
    end
    
    received_text    = nil
    received_object  = nil
    received_id_long = nil
    
    @receiver.receive_message(:timeout => 1000, :selector => "recipient = 'sparrow-spec'") do |msg|
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

#
# Cenario pos-configuracao do cliente JMS, quando deve ser possivel escutar mensagens
# atraves de objetos listeners.
#
describe Sparrow::Messaging::Listener,
         ', quando um Listener se registra para escutar uma Queue especifica,' do
  
  before(:all) do
    jms_client = create_and_setup_jms_client
  end
  
  it 'deveria possibilitar escutar mensagens atraves de um listener'
end
