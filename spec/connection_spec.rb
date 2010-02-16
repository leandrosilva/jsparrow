require File.dirname(File.expand_path(__FILE__)) + '/spec_helper.rb'

#
# Cenario que testa o start e stop do cliente JMS.
#
describe Sparrow::Connection::Client, ', quando criado,' do

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
end

#
# Cenario de configuracao do cliente JMS, quando sao informadas as propriedades de ambiente
# para conexao com o servidor de aplicacoes e a inicializacao do contexto JNDI inicial,
# onde estao criadas as connection factories, queues e topics.
#
# Importante: nesse momento o cliente JMS ainda nao sera iniciado, ja que nao deve haver
#             configuracao depois inicia-lo.
#
describe Sparrow::Connection::Client, ', quando esta sendo configurado, mas ainda nao iniciado,' do

  before(:all) do
    @jms_client = create_jms_client
  end
  
  it 'deveria ter uma connection factory especifica para queues' do
    @jms_client.queue_connection_factory_enabled?.should be true
  end
  
  it 'deveria ter uma connection factory especifica para topics' do
    @jms_client.topic_connection_factory_enabled?.should be true
  end
  
  it 'deveria permitir habilitar uma Queue especifica' do
    @jms_client.enable_queues :pardal_queue => 'PardalQueue'

    @jms_client.queue_enabled?(:pardal_queue).should eql true
  end
  
  it 'deveria permitir habilitar um Topic especifico' do
    @jms_client.enable_topics :pardal_topic => 'PardalTopic'

    @jms_client.topic_enabled?(:pardal_topic).should eql true
  end  
end

#
# Cenario de configuracao do cliente JMS apos ter sido iniciado.
#
# Importante: Como o cliente JMS ja esta iniciado, deve lancar erro, nao permitindo
#             qualquer configuracao.
#
describe Sparrow::Connection::Client, ', quando esta sendo configurado,' do

  before(:all) do
    @jms_client = create_jms_client
    @jms_client.start
  end
  
  after(:all) do
    @jms_client.stop
  end
  
  it 'deveria ter uma connection factory especifica para queues' do
    @jms_client.queue_connection_factory.should_not be nil
  end
  
  it 'deveria ter uma connection factory especifica para topics' do
    @jms_client.topic_connection_factory.should_not be nil
  end
  
  it 'deveria permitir habilitar uma Queue especifica' do
    @jms_client.enable_queues :pardal_queue => 'PardalQueue'

    @jms_client.queue_enabled?(:pardal_queue).should eql true
  end
  
  it 'deveria permitir habilitar um Topic especifico' do
    @jms_client.enable_topics :pardal_topic => 'PardalTopic'

    @jms_client.topic_enabled?(:pardal_topic).should eql true
  end  
end

#
# Cenario pos-configuracao do cliente JMS, quando as queues e os topicos ja devem estar
# disponiveis, e entao e possivel obter sender/receiver para elas.
#
describe Sparrow::Connection::Client, ', depois de ter sido configurado,' do

  before(:all) do
    @jms_client = create_and_setup_jms_client
    @jms_client.start
  end
  
  after(:all) do
    @jms_client.stop
  end
  
  it 'deveria possibilitar obter um Sender para uma Queue especifica' do
    @jms_client.queue_sender(:pardal_queue).should_not be nil
  end
  
  it 'deveria possibilitar obter um Receiver para uma Queue especifica' do
    @jms_client.queue_receiver(:pardal_queue).should_not be nil
  end
  
  it 'deveria possibilitar obter um Sender para um Topic especifico' do
    @jms_client.topic_sender(:pardal_topic).should_not be nil
  end
  
  it 'deveria possibilitar obter um Receiver para um Topic especifico' do
    @jms_client.topic_receiver(:pardal_topic).should_not be nil
  end
end
