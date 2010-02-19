#
# Cenario pos-configuracao da conexao, quando deve ser possivel escutar mensagens
# atraves de objetos listeners (especializacoes de Listener).
#
describe JSparrow::Connection::Listener,
         ', quando especializado para escutar uma queue,' do
  
  before(:all) do
    @jms_listener = create_jms_listener
  end
  
  it 'deveria ter uma connection_factory especifica para queues' do
    @jms_listener.jndi_name_of_connection_factory.should_not be nil
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
