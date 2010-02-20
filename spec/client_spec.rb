require File.dirname(File.expand_path(__FILE__)) + '/spec_helper.rb'

#
# Cenario que testa o start e stop do cliente JMS.
#
describe JSparrow::Connection::Client, ', quando criado,' do

  before(:all) do
    @jms_client = create_jms_client
  end
  
  it 'deveria permitir ser iniciado e parado' do
    @jms_client.start
    
    @jms_client.is_started?.should be true
    @jms_client.is_stoped?.should be false
    
    @jms_client.stop
    
    @jms_client.is_started?.should be false
    @jms_client.is_stoped?.should be true
  end
  
  it 'nao deveria permitir ser iniciado se ja houver sido' do
    @jms_client.start
    
    lambda {
        @jms_client.start
      }.should raise_error JSparrow::Connection::InvalidStateError
    
    @jms_client.stop
  end
  
  it 'nao deveria permitir ser parado se ja houver sido' do
    @jms_client.start
    @jms_client.stop
    
    lambda {
        @jms_client.stop
      }.should raise_error JSparrow::Connection::InvalidStateError
  end
end

#
# Cenario pos-configuracao do cliente JMS, quando as queues e os topicos ja devem estar
# disponiveis, e entao e possivel obter sender/receiver para elas.
#
describe JSparrow::Connection::Client, ', depois de ter sido configurado,' do

  before(:all) do
    @jms_client = create_jms_client
    @jms_client.start
  end
  
  after(:all) do
    @jms_client.stop
  end
  
  it 'deveria possibilitar obter um Sender para uma Queue especifica' do
    @jms_client.queue_sender(:test_queue).should_not be nil
  end
  
  it 'deveria possibilitar obter um Receiver para uma Queue especifica' do
    @jms_client.queue_receiver(:test_queue).should_not be nil
  end
  
  it 'deveria possibilitar obter um Sender para um Topic especifico' do
    @jms_client.topic_sender(:test_topic).should_not be nil
  end
  
  it 'deveria possibilitar obter um Receiver para um Topic especifico' do
    @jms_client.topic_receiver(:test_topic).should_not be nil
  end
end
