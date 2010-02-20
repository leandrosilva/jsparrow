#
# Cenario pos-configuracao da conexao, quando deve ser possivel escutar mensagens
# atraves de objetos listeners (especializacoes de Listener).
#
describe JSparrow::Connection::Listener, ', quando especializado para escutar uma queue,' do
  
  before(:all) do
    @jms_listener = create_jms_listener
  end
  
  it 'deveria ter listen_to configurado para a queue test_queue' do
    @jms_listener.listen_to_destination.should eql :queue => :test_queue
  end
end

#
# Cenario para testar star e stop de um listener concreto (especializado de Listener),
# bem como o recebimento de uma mensagem.
#
describe JSparrow::Connection::Listener, ', quando especializado e criado,' do
  
  before(:all) do
    @jms_listener = create_jms_listener
  end
  
  it 'deveria permitir ser iniciado e parado' do
    @jms_listener.start_listening
    
    @jms_listener.is_listening?.should be true
    
    @jms_listener.stop_listening
    
    @jms_listener.is_listening?.should be false
  end
  
  it 'deveria receber uma mensagem' do
    send_message_to_listener TestQueueListener
    
    @jms_listener.start_listening
    
    @jms_listener.received_messages.size eql 1
    
    @jms_listener.stop_listening
  end
end