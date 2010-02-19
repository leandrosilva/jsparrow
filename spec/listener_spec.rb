#
# Cenario pos-configuracao do cliente JMS, quando deve ser possivel escutar mensagens
# atraves de objetos listeners.
#
describe JSparrow::Connection::Listener,
         ', quando um Listener se registra para escutar uma Queue especifica,' do
  
  before(:all) do
    @jms_listener = create_jms_listener
  end
  
  after(:all) do
  end
  
  it 'deveria possibilitar escutar mensagens atraves de um listener'
end
