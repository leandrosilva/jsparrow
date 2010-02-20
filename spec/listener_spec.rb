#
# Cenario pos-configuracao da conexao, quando deve ser possivel escutar mensagens
# atraves de objetos listeners (especializacoes de Listener).
#
describe JSparrow::Connection::Listener, ', quando especializado para escutar uma queue,' do
  
  before(:all) do
    @jms_listener = create_jms_listener
  end
  
  it 'deveria ter listen_to_destination configurado para test_queue' do
    @jms_listener.listen_to_destination.should eql :queue => :test_queue
  end
end

#
# Cenario 
#
describe JSparrow::Connection::Listener, ', quando criado,' do
  
  before(:all) do
    @jms_listener = create_jms_listener
  end
  
  it 'deveria permitir ser iniciado e parado' do
    @jms_listener.start_listening
    
    @jms_listener.is_started?.should be true
    @jms_listener.is_stoped?.should be false
    
    @jms_listener.stop_listening
    
    @jms_listener.is_started?.should be false
    @jms_listener.is_stoped?.should be true
  end
end
