$LOAD_PATH.unshift(File.dirname(File.expand_path(__FILE__)))

# Bibliotecas necessarias para usar JMS
require 'javaee.rb'

# Bibliotecas do JSparrow
require 'connection.rb'
require 'client.rb'
require 'listener.rb'
require 'messaging.rb'
require 'error.rb'
