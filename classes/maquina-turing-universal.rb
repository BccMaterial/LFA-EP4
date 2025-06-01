class MTU
  attr_accessor :fita, :estado, :cursor, :fita_string, :transicoes 

  def initialize
    @estado = qi
    @cursor = 0 #Pos na fita
    @movimento_salvo = :D #Anda para a primeira pos
  end
  
  def processar(entrada)
    #if entrada == "cfg_a^n_b^n"
      #entrada = codifica


    @fita = "#" + entrada + " " * entrada.size * 3 # fita semi-infinita, virtual
    estado_leitura = ""
    simbolo_leitura = ""
    estado_destino = ""
    simbolo_escrita = ""
    movimento = :D
    transicoes = {}
    @fita_cadeia = []

    while true      
      case [@estado, @fita[@cursor]]

      # iniciar máquina em qi e ir para primeiro estado
      in [:qi, "#"]
        operar("#", :q0, :D)
      # começa a ler a fita e salva em uma estrutura de memória.
      # neste caso, vamos salvar em uma estrutura do Ruby

      #Lê o estado de origem:
      in [:q0, "f"] #Sempre começa com f
        estado_leitura << "f" 
        operar("f", :q01, :D)
      in [:q01, "a"]
        estado_leitura << "a" #Pode escolher a ou b 
        operar("a", :q02, :D)
      in [:q01, "b"]
        estado_leitura << "b"
        operar("b", :q02, :D)
      in [:q02, "a"] | [:q02, "b"] #Permite ter mais a's ou b's no meio(fa, fab, fabb)
        estado_leitura << @fita[cursor]
        operar(@fita[@cursor], :q02, :D)
      in [:q02, "s"]
        operar("s", :q1, :N)

      ## Leitura de símbolo de leitura
      in [:q1. "s"]
        simbolo_leitura << "s"
        operar("s", :q1, :D)
      in [:q1, "c"]
        simbolo_leitura << "c"
        operar("c", :q3, :D) #Muda para q3 quando encontra um c
      in [:q3, "s"]
        simbolo_leitura << "s"
        operar("c", :q3, :D)
      in [:q3, "c"]
        simbolo_leitura << "c" 
        operar("c", :q4, :D) #Muda para q4 quando encontra um c
      
      # leitura de estado de destino
      in [:q4, "f"] #f indicando que o estado vai começar
        estado_destino << "f"
        operar("f", :q41, :D)
      in [:q41, "a"] | [:q41, "b"] #ESpera a ou b
        estado_destino << @fita[@cursor]
        operar(@fita[@cursor], :q42, :D)
      in [:q42, "a"] | [:q42, "b"] #Opção de continuar escrevendo a's ou b's
        estado_destino << @fita[@cursor]
        operar(@fita[@cursor], :q42, :D)
      in [:q42, "s"]
        operar("s", :q5, :N) #Avança para o estado q5 quando encontrar "s"

      # leitura de símbolo de escrita
      in [:q5, "s"] #Adiciona um s ao simbolo_escrita e continua em q5
        simbolo_escrita << "s" 
        operar("s", :q5, :D) 
      in [:q5, "c"] #Adiciona um c ao simbolo_escrita e vai pra q6
        simbolo_escrita << "c"
        operar("c", :q6, :D) 
      in [:q6, "s"] 
        simbolo_escrita << "s" 
        operar("s", :q6, :D)
      in [:q6, "c"]  #Acumula c's e vai para q7
        simbolo_escrita << "s" 
        operar("C", :q7, :D) 

      # Leitura de movimento
      in [:q7, "d"]
        movimento = :D
        operar("d", :q8, :D)
      in [:q7, "e"]
        movimento = :E
        operar("e", :q8, :D)

      # reinicia a máquina
      in [:q8, "_"] 
        # direta, salva transição
        leitura = [estado_leitura, simbolo_leitura]
        transicoes[leitura] = [simbolo_escrita, estado_destino, movimento]
        puts("Transição lida: (#{estado_leitura},#{simbolo_leitura})->(#{simbolo_escrita},#{estado_destino},#{movimento})")
        
        estado_leitura = ""
        simbolo_leitura = ""
        estado_destino = ""
        simbolo_escrita = ""

        operar("", :q0, :D)

      ######### leitura dos símbolos de w ##########   
      # começa a leitura dos símbolos e processamento de w
      in [:q8, "$"]
        # adiciona o último estado
        leitura = [estado_leitura, simbolo_leitura]
        transicoes[leitura] = [simbolo_escrita, estado_destino, movimento]
        puts("Transição lida: (#{estado_leitura},#{simbolo_leitura})->(#{simbolo_escrita},#{estado_destino},#{movimento})")
        puts("============================\n\n")
        puts("Enter para continuar...")
        puts("============================\n\n")
        gets
        puts("=========== Leitura dos símbolos: ===========")
        operar("$", :q20, :D)
        simbolo_leitura = ""
      in [:q20, 's']
        simbolo_leitura << "s"
        operar("s", :q20, :D)
      in [:q20, 'c']
        simbolo_leitura << "c"
        operar("c", :q21, :D)
      
      in [:q21, 's'] # recomeça a leitura
        @fita_cadeia << simbolo_leitura

        # reinicia a leitura dos símbolos
        simbolo_leitura = "s"
        operar("s", :q20, :D)
        
      in [:q21, '_'] # finaliza leitura
        @fita_cadeia << simbolo_leitura
        
        puts("=========== Fita de símbolos: ===========\n")
        print(@fita_cadeia)
        
        ######## iniciando a leitura de w
        return submaquina(transicoes)
      else #REVER DEPOIS
        puts "(#{estado_leitura},#{simbolo_leitura}) = (#{estado_destino},#{simbolo_escrita},#{movimento})"
        return false
      end
    end
  end

  def submaquina(transicoes)
    # estado inicial da máquina a ser simulada
    estado_mt = "fa"
    @cursor_leitura = 0

    while true
      simbolo_leitura = @fita_cadeia[@cursor_leitura]

      leitura = [estado_mt, simbolo_leitura]
      puts "(#{estado_mt}, #{simbolo_leitura})"
      resultado = transicoes[leitura]
      
      return false unless resultado

      simbolo_escrita, estado_destino, movimento = resultado
      puts "(#{estado_mt}, #{simbolo_leitura} -> (#{estado_destino}, #{simbolo_escrita}, #{movimento}))"

      estado_mt = estado_destino

      @fita_cadeia[@cursor_leitura] = simbolo_escrita

      return true if simbolo_leitura == "scc" && estado_mt.start_with("fb")

      movimento = :D ? @cursor_leitura += 1 : @cursor_leitura -= 1
    end
  end

  def operar(escrever, estado, movimento = :D)
    @fita[@cursor] = escrever
    @estado = estado
    if movimento == :D
      @cursor += 1
    else
      @cursor -= 1
    end
  end

  def encoding_anbn
    "faasscsccfsbsccdscc_" +
    "$sccsccscc_"
  end

  def encoding_anbncn
    "faasscsccfsbsccdscc_" +
    "fbsccscsccfcsccsccdscc_" +
    "$sccsccsccscc_"
  end

  def encoding_multiplicacao
    "faasscsccfsbsccdscc_" +
    "fbsccscsccfcsccsccdscc_" +
    "fccsccsccfdsccsccdscc_" +
    "$sccsccscc_"
  end

end
