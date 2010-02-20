#
# Cenario pos-configuracao da conexao, quando deve ser possivel escutar mensagens
# atraves de objetos listeners (especializacoes de Listener).
#
describe JSparrow::Connection::Listener,
         ', quando especializado para escutar uma queue,' do
  
  before(:all) do
    @jms_listener = create_jms_listener
  end
  
  it 'deveria ter a queue_connection_factory configurada' do
    @jms_listener.connection_factory_name.should be :queue_connection_factory
  end
  
  it 'deveria ter a destination test_queue configurada' do
    @jms_listener.destination_name.should be :test_queue
  end
end

#---

describe JSparrow::Connection::Listener,
         ', quando um Listener se registra para escutar uma Queue especifica,' do
  
  before(:all) do
    @jms_listener = create_jms_listener
  end
  
  after(:all) do
  end
  
  it 'deveria possibilitar escutar mensagens atraves de um listener'
end
