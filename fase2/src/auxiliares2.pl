:- consult('baseConhecimento.pl').

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).

:- style_check(-singleton).

%--------------------------------------Auxiliares Para o Caminho--------------------------------------

% Devolve o destino da encomenda, ou seja, a freguesia onde a mesma é entregue
destinoEncomenda(IdEnc,Destino) :-
    estafetaFezEncomenda(IdEstaf,IdEnc),
    estafeta(IdEstaf,Lista),
    membro((IdEnc,A,B,Destino),Lista).


% Devolve a velocidade a que uma encomenda foi entregue
% # Bicicleta - 10 km/h
% # Moto - 35 km/h
% # Carro - 25 km/h
velocidadeEntrega(IdEnc,Velocidade) :-
    encomenda(IdEnc,_,Peso,_,_,_,_),
    transporteEncomenda(IdEnc,Transporte),
    ((Transporte == 'Bicicleta' -> Velocidade is 10 - Peso * 0.7);
     (Transporte == 'Moto' -> Velocidade is 35 - Peso * 0.5);
     (Transporte == 'Carro' -> Velocidade is 25 - Peso * 0.1)).


% Devolve o tempo de entrega de uma encomenda, consoante o tipo de pesquisa adotado:
% # 1 - DFS
% # 2 - BFS
% # 3 - DFS Limitada
% # 4 - Gulosa
% # 5 - A*
tempoEntrega(IdEnc,TempoTotal,1) :-
    destinoEncomenda(IdEnc,Destino),
    resolveDFS(Destino,[Destino|Caminho],Distancia),
    velocidadeEntrega(IdEnc,Velocidade),
    DistanciaTotal is Distancia*2,
    TempoTotal is DistanciaTotal / Velocidade.

tempoEntrega(IdEnc,TempoTotal,2) :-
    destinoEncomenda(IdEnc,Destino),
    resolveBFS(Destino,Caminho,Distancia),
    velocidadeEntrega(IdEnc,Velocidade),
    DistanciaTotal is Distancia*2,
    TempoTotal is DistanciaTotal / Velocidade.

tempoEntrega(IdEnc,TempoTotal,3) :-
    destinoEncomenda(IdEnc,Destino),
    resolveLimitada(Destino,Caminho,Distancia,5),
    velocidadeEntrega(IdEnc,Velocidade),
    DistanciaTotal is Distancia*2,
    TempoTotal is DistanciaTotal / Velocidade.

tempoEntrega(IdEnc,TempoTotal,4) :-
    destinoEncomenda(IdEnc,Destino),
    resolveGulosa(Destino,Caminho/Distancia),
    velocidadeEntrega(IdEnc,Velocidade),
    DistanciaTotal is Distancia*2,
    TempoTotal is DistanciaTotal / Velocidade.

tempoEntrega(IdEnc,TempoTotal,5) :-
    destinoEncomenda(IdEnc,Destino),
    resolveAEstrela(Nodo,Caminho/Distancia),
    velocidadeEntrega(IdEnc,Velocidade),
    DistanciaTotal is Distancia*2,
    TempoTotal is DistanciaTotal / Velocidade.

%---------------------------------------------------Anexos---------------------------------------------------

adjacente(Nodo,ProxNodo,C) :- aresta(Nodo,ProxNodo,C).
adjacente(Nodo,ProxNodo,C) :- aresta(ProxNodo,Nodo,C).

% adjacente(X,Y,D,grafo(Es1,Es2)) :- member(aresta(X,Y,D),Es2).
% adjacente(X,Y,D,grafo(Es1,Es2)) :- member(aresta(Y,X,D),Es2).

adjacenteV2([Nodo|Caminho]/Custo1/_,[ProxNodo,Nodo|Caminho]/Custo2/Estima) :-
    adjacente(Nodo,ProxNodo,PassoCusto),
	\+member(ProxNodo,Caminho),
	Custo2 is Custo1 + PassoCusto,
	estima(ProxNodo,Estima).

obter_melhor([Caminho],Caminho) :- !.
obter_melhor([Caminho1/Custo1/Estima1,_/Custo2/Estima2|Caminhos],MelhorCaminho) :-
    Estima1 =< Estima2, !,
    obter_melhor([Caminho1/Custo1/Estima1|Caminhos],MelhorCaminho).
obter_melhor([_|Caminhos],MelhorCaminho) :-
    obter_melhor(Caminhos,MelhorCaminho).

inverso(Xs,Ys) :- inverso(Xs,[],Ys).

inverso([],Xs,Xs).
inverso([X|Xs],Ys,Zs) :- inverso(Xs,[X|Ys],Zs).

seleciona(E,[E|Xs],Xs).
seleciona(E,[X|Xs],[X|Ys]) :- seleciona(E,Xs,Ys).