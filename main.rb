require './classes/maquina-turing-universal'
require './classes/mt-codificada'

mt = MTU.new

puts "#{mt.processar("cfg_a^n_b^n")}"


