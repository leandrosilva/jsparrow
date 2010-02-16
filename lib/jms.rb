# Libs directory definition
JEE_LIB_DIR = File.expand_path(File.dirname(__FILE__)) + '/jms'

# Befor all, the fundamental require for us
require 'java'

# Lib to JMS integration (contain the META-INF/applicationContext.xml)
require "#{JEE_LIB_DIR}/jsparrow-essential.jar"

#  Java EE
require "#{JEE_LIB_DIR}/javaee-1.5.jar"

# JMS API
require "#{JEE_LIB_DIR}/jms.jar"