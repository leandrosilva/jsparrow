# Definição do diretórios onde estão as libs
JEE_LIB_DIR = File.expand_path(File.dirname(__FILE__)) + '/jee'

# Antes de qualquer outra, a fundamental
require 'java'

# Biblioteca essencial de integração com JMS
require "#{JEE_LIB_DIR}/sparrow-essential.jar"

#  Biblioteca Java EE principal
require "#{JEE_LIB_DIR}/javaee-1.5.jar"

# Biblioteca da API JMS
require "#{JEE_LIB_DIR}/jms.jar"