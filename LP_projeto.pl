% 109264 - Francisco Mendonca
 :- use_module(library(clpfd)). % para poder usar transpose/2
 :- set_prolog_flag(answer_write_options,[maL_depth(0)]). % ver listas completas
 :- ['puzzlesAcampar.pl']. % Ficheiro de puzzles.

% 4.1 - Consultas

% Predicado que gera a vizinhanca(lateral) de uma celula dada sua posicao (L, C)
vizinhanca((L, C), Vizinhanca) :-
    findall((L1, C1), vizinho(L, C, L1, C1), Vizinhanca).

% Predicado que gera a vizinhanca alargada(lateral e diagonal) de uma celula dada sua posicao (L, C)
vizinhancaAlargada((L, C), VizinhancaAlargada) :-
    findall((L1, C1), (vizinhoDiagonal(L, C, L1, C1);vizinho(L, C, L1, C1)), VizinhancaAlargadaDesordenada),
    sort(VizinhancaAlargadaDesordenada, VizinhancaAlargada).

vizinho(L, C, L1, C1) :- L1 is L - 1, C1 = C.
vizinho(L, C, L1, C1) :- L1 = L, C1 is C - 1.
vizinho(L, C, L1, C1) :- L1 = L, C1 is C + 1.
vizinho(L, C, L1, C1) :- L1 is L + 1, C1 = C.
vizinhoDiagonal(L, C, L1, C1) :- L1 is L - 1, C1 is C - 1.
vizinhoDiagonal(L, C, L1, C1) :- L1 is L - 1, C1 is C + 1.
vizinhoDiagonal(L, C, L1, C1) :- L1 is L + 1, C1 is C - 1.
vizinhoDiagonal(L, C, L1, C1) :- L1 is L + 1, C1 is C + 1.



% Predicado para obter todas as celulas do tabuleiro
todasCelulas(Tabuleiro, TodasCelulas) :-
    findall((L, C), (nth1(L, Tabuleiro, Linha), nth1(C, Linha, _)), TodasCelulas).

% Predicado para obter todas as celulas de um determinado objecto do tabuleiro 
todasCelulas(Tabuleiro, TodasCelulas, Objecto) :-
    (
        var(Objecto), 
        findall((L, C), (nth1(L, Tabuleiro, Linha), nth1(C, Linha, ObjectoTabuleiro),
        var(ObjectoTabuleiro)), TodasCelulas)
    ;
        nonvar(Objecto),
        findall((L, C), (nth1(L, Tabuleiro, Linha), nth1(C, Linha, ObjectoTabuleiro),
        ObjectoTabuleiro == Objecto), TodasCelulas)
    ).
    /*
    - Se o objeto for uma variavel nao preenchida, a primeira condicao e verificada para todos os objectos 
      no tabuleiro. Se o ObjectoTabuleiro tambem for uma variavel nao preenchida, ele e adicionado a lista.
    - Se o objeto nao for uma variavel nao preenchida, a segunda condicao e avaliada para todos os objectos 
      no tabuleiro. Se o ObjectoTabuleiro for igual ao Objecto, ele e adicionado a lista.
    */



% Predicado para calcular o numero de objetos numa linha do tabuleiro
calculaNumeroObjetosLinha(Tabuleiro, NumeroLinha, ContagemLinha, Objecto) :-
    nth1(NumeroLinha, Tabuleiro, Linha),
    (
        nonvar(Objecto),
        findall(Objecto, (nth1(_, Linha, Elemento), Elemento == Objecto), Contagem)
    ;
        var(Objecto),
        findall(Objecto, (nth1(_, Linha, Elemento), var(Elemento)), Contagem)
    ),
    length(Contagem, ContagemLinha).
    /*
    - Se o objeto nao for uma variavel nao preenchida, a primeira condicao e avaliada para todos os objectos 
      na Linha. Se o Elemento for igual ao Objecto, ele e adicionado a lista Contagem.
    - Se o objeto for uma variavel nao preenchida, a segunda condicao e verificada para todos os objectos na
      Linha. Se o Elemento tambem for uma variavel nao preenchida, ele e adicionado a lista Contagem.
    */

% Predicado para calcular o numero de objetos em todas as linhas e colunas do tabuleiro
calculaObjectosTabuleiro(Tabuleiro, ContagemLinhas, ContagemColunas, Objecto) :-
    length(Tabuleiro, NumeroDeLinhas),
    transpose(Tabuleiro, TabuleiroTransposto),
    findall(ContagemLinha, (between(1, NumeroDeLinhas, L), 
    calculaNumeroObjetosLinha(Tabuleiro, L, ContagemLinha, Objecto)), ContagemLinhas),
    findall(ContagemLinha, (between(1, NumeroDeLinhas, L), 
    calculaNumeroObjetosLinha(TabuleiroTransposto, L, ContagemLinha, Objecto)), ContagemColunas).



% Predicado para verificar se uma celula esta vazia
celulaVazia(Tabuleiro, (L, C)) :-
    todasCelulas(Tabuleiro, TodasCelulas, _),
    member((L, C), TodasCelulas).



% 4.2 - Insercao de tendas e relva

% Predicado para inserir um determinado objeto numa celula do tabuleiro
insereObjectoCelula(Tabuleiro, TendaOuRelva, (L, C)) :-
    (
        celulaVazia(Tabuleiro, (L, C)),
        nth1(L, Tabuleiro, Linha),
        substitui(Linha, C, TendaOuRelva, NovaLinha),
        substitui(Tabuleiro, L, NovaLinha, Tabuleiro)
    ;
        not(celulaVazia(Tabuleiro, (L, C))),
        Tabuleiro=Tabuleiro
    ).
    /*
    - Se a Celula estiver vazia o objeto e inserido
    - Se a Celula estiver preenchida o objeto nao e inserido
    */

% Predicado para substituir um elemento de uma lista
substitui(Lista, Indice, ElementoNovo, NovaLista) :-
    nth1(Indice, Lista, _, Resto),
    nth1(Indice, NovaLista, ElementoNovo, Resto).
    /*
    - nth1(Indice, Lista, _, Resto) seleciona o elemento no indice especificado da Lista e substitui por um 
      caractere anonimo (_) e o restante da lista e armazenado no Resto.
    - nth1(Indice, NovaLista, ElementoNovo, Resto) insere o ElementoNovo na mesma posicao do indice na NovaLista 
      e o Resto e mantido para preservar os elementos apos o indice.
    */

% Predicado para inserir um objeto entre duas Coordenadas com a mesma abcissa do tabuleiro
insereObjectoEntrePosicoes(Tabuleiro, TendaOuRelva, (L, C1), (L, C2)) :-
    findall((L, C), between(C1, C2, C), Coordenadas),
    maplist(insereObjectoCelula(Tabuleiro, TendaOuRelva), Coordenadas).



% 4.3 Estrategias

% Predicado para preencher com relva Linhas e Colunas que ja tenham o numero de tendas correto
relva(Puzzle) :- 
    Puzzle = (Tabuleiro, CLinhas, CColunas),
    calculaObjectosTabuleiro(Tabuleiro, CL, CC, t),
    length(CL, NumeroDeLinhas),
    length(CC, NumeroDeColunas),
    coordenadasInicialFinal(CLinhas, CL, NumeroDeColunas, CoordenadasInicialLinhas, CoordenadasFinalLinhas),
    coordenadasInicialFinal(CColunas, CC, NumeroDeLinhas, CoordenadasInicialColunas, CoordenadasFinalColunas),
    maplist(insereObjectoEntrePosicoes(Tabuleiro, r), CoordenadasInicialLinhas, CoordenadasFinalLinhas),
    transpose(Tabuleiro, TabuleiroTransposto),
    maplist(insereObjectoEntrePosicoes(TabuleiroTransposto, r), CoordenadasInicialColunas, CoordenadasFinalColunas),
    transpose(TabuleiroTransposto, NovoTabuleiro),
    Tabuleiro=NovoTabuleiro.

% Predicado para calcular coordenadas iniciais e finais de Linhas/Colunas que ja tenham o numero de tendas correto
coordenadasInicialFinal(CLinhas, CL, UltimaOrdenada, CoordenadasInicial, CoordenadasFinal) :-
    findall((N, 1), (nth1(N, CLinhas, NumDeTendasObjetivo), nth1(N, CL, NumDeTendasColocadas), 
    NumDeTendasObjetivo==NumDeTendasColocadas), CoordenadasInicial),
    findall((N, UltimaOrdenada), (nth1(N, CLinhas, NumDeTendasObjetivo), nth1(N, CL, NumDeTendasColocadas), 
    NumDeTendasObjetivo==NumDeTendasColocadas), CoordenadasFinal).



% Predicado para preencher com relva em celulas inacessiveis (celulas que nao tem arvores vizinhas)
inacessiveis(Tabuleiro) :-
    todasCelulas(Tabuleiro, TodasCelulas),
    todasCelulas(Tabuleiro, TodasCelulasArvores, a),
    findall(Vizinho, (nth1(_, TodasCelulasArvores, Arvore), vizinhanca(Arvore, Vizinhanca), 
    nth1(_, Vizinhanca, Vizinho)), Vizinhancas),
    sort(Vizinhancas, Vizinhancas1),
    subtract(TodasCelulas, Vizinhancas1, TodasCelulasRelva),
    maplist(insereObjectoCelula(Tabuleiro, r), TodasCelulasRelva).



% Predicado para colocar tendas em Linhas/Colunas em que o numero de espacos vazios e igual ao numero de tendas por colocar
aproveita(Puzzle) :-
    Puzzle = (Tabuleiro, CLinhas, CColunas),
    calculaObjectosTabuleiro(Tabuleiro, CL, CC, _),
    calculaObjectosTabuleiro(Tabuleiro, CL1, CC1, t),
    length(CL, NumeroDeLinhas),
    length(CC, NumeroDeColunas),
    coordenadasInicialFinal(CLinhas, CL, CL1, NumeroDeColunas, CoordenadasInicialLinhas, CoordenadasFinalLinhas),
    coordenadasInicialFinal(CColunas, CC, CC1, NumeroDeLinhas, CoordenadasInicialColunas, CoordenadasFinalColunas),
    maplist(insereObjectoEntrePosicoes(Tabuleiro, t), CoordenadasInicialLinhas, CoordenadasFinalLinhas),
    transpose(Tabuleiro, TabuleiroTransposto),
    maplist(insereObjectoEntrePosicoes(TabuleiroTransposto, t), CoordenadasInicialColunas, CoordenadasFinalColunas),
    transpose(TabuleiroTransposto, NovoTabuleiro),
    Tabuleiro=NovoTabuleiro.

% Predicado para calcular coordenadas iniciais e finais de Linhas/Colunas em que o numero de espacos vazios e igual ao numero de tendas por colocar
coordenadasInicialFinal(CObjetivo, CLivres, CTendas, UltimaOrdenada, CoordenadasInicial, CoordenadasFinal) :-
    findall((N, 1), (nth1(N, CObjetivo, Objetivo), nth1(N, CLivres, EspacosLivres), nth1(N, CTendas, TendasColocadas), 
    TendasPorColocar is Objetivo - TendasColocadas, TendasPorColocar==EspacosLivres), 
    CoordenadasInicial),
    findall((N, UltimaOrdenada), (nth1(N, CObjetivo, Objetivo), nth1(N, CLivres, EspacosLivres), 
    nth1(N, CTendas, TendasColocadas), TendasPorColocar is Objetivo - TendasColocadas,
    TendasPorColocar==EspacosLivres), CoordenadasFinal).



% Predicado para colocar relva nas celulas da vizinhanca alargada das tendas
limpaVizinhancas(Puzzle) :-
    Puzzle = (Tabuleiro, _, _),
    todasCelulas(Tabuleiro, TodasCelulasTendas, t),
    findall(Vizinho, (nth1(_, TodasCelulasTendas, Tenda), vizinhancaAlargada(Tenda, Vizinhanca), 
    nth1(_, Vizinhanca, Vizinho)), Vizinhancas),
    sort(Vizinhancas, Vizinhancas1),
    maplist(insereObjectoCelula(Tabuleiro, r), Vizinhancas1).



% Predicado para preencher tendas em celulas vizinhas a arvores que tinham apenas uma posicao livre na sua vizinhanca
unicaHipotese(Puzzle) :-
    Puzzle = (Tabuleiro, _, _),
    todasCelulas(Tabuleiro, TodasCelulasArvores, a),
    todasCelulas(Tabuleiro, TodasCelulasTendas, t),
    findall(Vizinho, (nth1(_, TodasCelulasArvores, Arvore), vizinhanca(Arvore, Vizinhanca), 
    forall(member(X, Vizinhanca), not(member(X, TodasCelulasTendas))), 
    numeroDeCelulasVazias(Tabuleiro, Vizinhanca, NumCelVazias), NumCelVazias==1, 
    nth1(_, Vizinhanca, Vizinho)), Vizinhos),
    maplist(insereObjectoCelula(Tabuleiro, t), Vizinhos).

% Predicado para contar o numero de celulas vazias numa Lista de Celulas de um Tabuleiro
numeroDeCelulasVazias(Tabuleiro, Lista, N) :-
    findall(Celula, (nth1(_, Lista, Celula), celulaVazia(Tabuleiro, Celula)), ListaCelulasVazias),
    length(ListaCelulasVazias, N).



% 4.4 Tentativa e Erro

% Predicado para verificar a validez da colocacao de tendas e arvores com o uso da abordagem Tentativa e Erro
valida(_, []).
valida(LArv, LTen) :-
    nth1(1, LArv, Arvore),
    findall(Vizinho, (vizinhanca(Arvore, Vizinhanca), nth1(_, Vizinhanca, Vizinho), 
    member(Vizinho, LTen)), TendasVizinhas),
    member(Tenda, TendasVizinhas),
    subtract(LTen, [Tenda], LTen1),
    subtract(LArv, [Arvore], LArv1),
    valida(LArv1, LTen1).
    /*
    - Primeiro e escolhida uma arvore e depois e criada uma lista das tendas vizinhas a essa arvore
    - Depois e escolhida uma das tendas vizinhas
    - No fim e retirada a tenda a lista de tendas e a arvore a lista de arvores e o predicado e chamado 
      novamente com as novas listas de arvores e tendas
    - Quando a Lista de tendas esta vazia quer dizer que todas as tendas foram associadas a uma arvore
      e o predicado devolve true
    - Caso nao haja nenhuma conbinacao Arvore-Tenda que satisfaca a condicao o predicado devolve false
    */



% Predicado para resolver o puzzle com o uso da abordagem Tentativa e Erro
resolve(Puzzle) :-
    Puzzle = (Tabuleiro, CLinhas, CColunas),
    estrategias(Puzzle),
    todasCelulas(Tabuleiro, TodasCelulasVazias, _),
    TodasCelulasVazias==[],
    calculaObjectosTabuleiro(Tabuleiro, CL, CC, t),
    CL==CLinhas,
    CC==CColunas.
    /*
    - Primeiro aplica as estrategias ja definidas
    - Se apos a aplicacao das mesmas nao haja celulas vazias e o numero de tendas por linha e coluna 
      seja o correto, o predicado termina
    */

resolve(Puzzle) :-
    Puzzle = (Tabuleiro, CLinhas, CColunas),
    estrategias(Puzzle),
    todasCelulas(Tabuleiro, TodasCelulasVazias, _),
    member(Celula, TodasCelulasVazias),
    insereObjectoCelula(Tabuleiro, t, Celula),
    todasCelulas(Tabuleiro, TodasCelulasArvores, a),
    todasCelulas(Tabuleiro, TodasCelulasTendas, t),
    valida(TodasCelulasArvores, TodasCelulasTendas),
    relva(Puzzle),
    todasCelulas(Tabuleiro, TodasCelulasVazias1, _),
    (
        TodasCelulasVazias1 == [],
        calculaObjectosTabuleiro(Tabuleiro, CL, CC, t),
        CL==CLinhas,
        CC==CColunas
    ; 
        resolve(Puzzle)
    ).
    /*
    - Primeiro aplica as estrategias ja definidas
    - Em seguida coloca uma tenda numa das Celulas Vazias e verifica a sua validade
    - Se for valido continua, se nao tenta outra posicao
    - Depois aplica a estrategia relva
    - Se apos todos os passos nao haja celulas vazias e o numero de tendas por linha e coluna 
      seja o correto, o predicado termina, caso contrario volta a chamar o predicado resolve.
    */

% Predicado para executar as estrategias de resolucao do puzzle
estrategias(Puzzle) :-
    Puzzle = (Tabuleiro, _, _),
    copy_term(Tabuleiro, TabuleiroAntes),
    relva(Puzzle),
    inacessiveis(Tabuleiro),
    aproveita(Puzzle),
    limpaVizinhancas(Puzzle),
    unicaHipotese(Puzzle),
    todasCelulas(Tabuleiro, TodasCelulasVazias, _),
    todasCelulas(TabuleiroAntes, TodasCelulasVaziasAntes, _),
    (dif(TodasCelulasVazias, TodasCelulasVaziasAntes), estrategias(Puzzle));
    true.
    /*
    - Primeiro cria uma copia profunda do Tabuleiro inicial
    - Em seguinda implementa os predicados do 4.3 Estrategias
    - Caso TodasCelulasVazias seja igual a TodasCelulasVaziasAntes, quer dizer que a implementacao das 
      estrategias nao preencheu novos espacos e assim da true e para de modificar a tabuleiro
    - Caso contrario, quer dizer que o tabuleiro foi alterado e assim ira aplicar outra vez o predicado 
      estrategias ate que o tabuleiro nao se altere
    */
