
%------------------------------------------ Database ------------------------------------------------%

% ----------------- Scenario 1 ------------------------------ %

% Creating maze
    % Object types: startMaze, noObject, key, door, bear, sword, flashlight, hole, endMaze

% connected : (position, object, father, left, right)

:- dynamic connected/5.

% Keys and Doors
key(10).
door(10).

% Left tree
connected(1, startMaze, nil, 2, 15).
connected(2, noObject, 1, 3, 4).
connected(3, key(10), 2, 5, 6).
connected(4, noObject, 2, nil, nil).
connected(5, noObject, 3, 7, 8).
connected(6, hole, 3, nil, nil).
connected(7, flashlight, 5, 9, 10).
connected(8, noObject, 5, nil, nil).
connected(9, door(10), 7, 11, 12).
connected(10, hole, 7, nil, nil).
connected(11, sword, 9, 13, 14).
connected(12, bear, 9, nil, nil).
connected(13, bear, 11, nil, nil).
connected(14, noObject, 11, nil, nil).

% Right tree
connected(15, noObject, 1, 16, 17).
connected(16, hole, 15, nil, nil).
connected(17, bear, 15, 18, 19).
connected(18, endMaze, 17, nil, nil).
connected(19, noObject, 17, 20, 21).
connected(20, noObject, 19, nil, nil).
connected(21, hole, 19, nil, nil).

% Bag
:- dynamic bag/1.
bag(nothing).

% Internationalization
portuguese(startMaze, "Inicio").
portuguese(noObject, "Nada").
portuguese(hole, "Buraco").
portuguese(bear, "Urso").
portuguese(flashlight, "Lanterna").
portuguese(sword, "Espada").
portuguese(key(10), "Chave 10").
portuguese(door(10), "Porta 10").
portuguese(endMaze, "Saida").

%----------------------------------------------------- Rules ---------------------------------------------------- %
% -------------- Play --------------- %

startPlay :- write('Bem-vindo ao Blind Mazell'), nl,
             write('Digite o seu nome: '), read(Player), nl,
             write('Olá '), write(Player), write('!'), nl,
             play(1). % Star play on the first position
             
play(Position) :- nl, write('Para onde você deseja ir?'), nl, possibleWays(Position), flashlightIsOption, 
				  read(Option), option(Option, Position).


% ------------------ Option rules ---------------- %

option(a, Position) :- connected(Position, _, _, Left, _), (Left \== nil,
                       connected(Left, Object, _, _, _),nl,
                       ident, write("Você foi para a esquerda"), nl),
                       checkObject(Left, Object); 
                       nl, ident, write("Sem saída. Volte!"), nl, play(Position).

option(d, Position) :- connected(Position, _, _, _, Right), (Right \== nil,
                       connected(Right, Object, _, _, _),nl,
                       ident, write("Você foi para a direita"), nl),
                       checkObject(Right, Object); 
                       nl, ident, write("Sem saída. Volte!"), nl, play(Position).

option(s, Position) :- connected(Position, _, Father, _, _), (Father \== nil,
                       connected(_, Object, Father, _, _), nl, 
                       ident, write("Você voltou"), nl,
                       checkObject(Father, Object)) ; 
                       nl, ident, write("Você está no começo do labirinto, não dá mais pra voltar!"), nl, play(Position).

option(f, Position) :- deleteFromBag(flashlight), subMazes(Position), nl, play(Position).

option(_, Position) :- write("Opção inexistente"), nl, play(Position).

flashlightIsOption :- checkBag(flashlight), nl, write('f-Ligar lanterna'), nl; !.

possibleWays(Position) :- connected(Position, _, Father, Left, Right), 
						  (Left == nil; nl, write("a-Esquerda"), nl),
						  (Right == nil; nl, write("d- Direita"), nl),
						  (Father == nil; nl, write("s-Voltar"), nl).

% -------------------- Object rules ------------------- %

checkObject(Position, noObject) :- play(Position).

checkObject(Position, bear) :- (checkBag(sword), nl, ident, write("Voce encontrou um urso, mas voce tinha uma espada e o matou"), 
                                deleteFromBag(sword),nl, removeObjectFromMaze(Position), play(Position));
                                nl, ident, write("Ghrrr!! Voce encontrou um urso, mas voce não tinha uma espada e morreu. Fim do jogo."), nl.

checkObject(Position, sword) :- nl, ident, write("Voce encontrou uma espada"), nl, addOnBag(sword), removeObjectFromMaze(Position), play(Position).

checkObject(Position, flashlight) :- nl, ident, write("Voce encontrou uma lanterna. Voce pode usar apenas uma vez para enxergar o que tem nos seus possíveis caminhos."), nl, 
									 addOnBag(flashlight), removeObjectFromMaze(Position), play(Position). 

checkObject(Position, key(Value)) :- nl, addOnBag(key(Value)), removeObjectFromMaze(Position), write("Voce pegou a "), inPortuguese(key(Value)), write("."), nl, play(Position).

checkObject(Position, door(Key)) :- nl, checkBag(key(Key)), 
                                    (ident, write("Aqui tinha uma porta, mas você tinha a chave e a abriu."), play(Position));
                                    (
                                        nl, ident, write("Tem uma porta aqui e você não tem a chave. Volte e ache a chave da "), inPortuguese(door(Key)), write("!"), nl,
                                        %%  If the player dont have the key to the door, he/she goes back to the previous maze (Father)
                                        connected(Position, _, Father, _, _),
                                        play(Father)
                                    ).

checkObject(_, hole) :- nl, ident, write("Voce caiu em um buraco! Fim do jogo."), nl.

checkObject(_, endMaze) :- nl, ident, write("Voce encontrou a saída! Fim do jogo."), nl, showMaze(1).

ident :- write("            ").

%--------------- Bag rules ---------------------%

checkBag(Object):- bag(Object), !.
addOnBag(Object) :- asserta(bag(Object)).
deleteFromBag(Object) :- retract(bag(Object)).


% ------------ Show sub mazes ----------- %
subMazes(Position) :- connected(Position, _, _, Left, Right),                        
                       (
                        (Left == nil, nl, write('Não há saída a esquerda'), nl);
                        (connected(Left, LeftObject, _, _, _), 
                        nl, ident, inPortuguese(LeftObject), write(' a esquerda.'), nl)
                       ),                           
                       
                       (
                        (Right == nil, nl, write('Nada há saída a direita'), nl);
                        (connected(Right, RightObject, _, _, _),
                        nl, ident, inPortuguese(RightObject), write(' a direita.'), nl)
                        ).

inPortuguese(Object) :- portuguese(Object, ObjectPT), write(ObjectPT).

% --------------- Remove object from maze -------------- %

removeObjectFromMaze(Position) :- connected(Position, _, Father, Left, Right), 
								  retract(connected(Position, _, _, _, _)),
								  asserta(connected(Position, noObject, Father, Left, Right)).

showMaze(Position) :- Position == nil, write("Nada");  
					  connected(Position, Object, _, Left, Right),
                      nl, ident, inPortuguese(Object), nl, 
                      ident, subMazes(Position).
