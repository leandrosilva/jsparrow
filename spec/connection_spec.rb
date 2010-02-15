require File.dirname(File.expand_path(__FILE__)) + '/spec_helper.rb'

#
# Cenario de configuracao do cliente JMS, quando sao informadas as propriedades de ambiente
# para conexao com o servidor de aplicacoes e a inicializacao do contexto JNDI inicial,
# onde estao criadas as connection factories, queues e topics.
#
describe Sparrow::Connection::Client, ', quando esta sendo configurado,' do

  before(:all) do
    @jms_client = create_jms_client
  end
  
  it 'deveria permitir habilitar uma connection factory especifica para queues' do
    @jms_client.enable_connection_factories(
        :queue_connection_factory => 'ConnectionFactory'
      )

    @jms_client.queue_connection_factory.should_not be nil
  end
  
  it 'deveria permitir habilitar uma connection factory especifica para topics' do
    @jms_client.enable_connection_factories(
        :topic_connection_factory => 'ConnectionFactory'
      )

    @jms_client.topic_connection_factory.should_not be nil
  end
  
  it 'deveria permitir habilitar uma Queue especifica' do
    @jms_client.enable_queues(
        :pardal_queue => 'PardalQueue'
      )

    @jms_client.queue_enabled?(:pardal_queue).should eql true
  end
  
  it 'deveria permitir habilitar um Topic especifico' do
    @jms_client.enable_topics(
        :pardal_topic => 'PardalTopic'
      )

    @jms_client.topic_enabled?(:pardal_topic).should eql true
  end  
end

#
# Cenario pos-configuracao do cliente JMS, quando as queues e os topicos ja devem estar
# disponiveis, e entao e possivel obter sender/receiver para elas.
#
describe Sparrow::Connection::Client, ', depois de ter sido configurado,' do

  before(:all) do
    @jms_client = create_jms_client
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
