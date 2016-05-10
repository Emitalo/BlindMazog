
%------------------------------------------ Database ------------------------------------------------%


% Creating maze
    % Object types: startMaze, noObject, key, door, bear, sword, flashlight, hole, endMaze


/*
 *-------------Connected fact structure
 *
 * 	connected : (position, object, father, left, right)
 *
 *-------------------------------------
 */

:- dynamic connected/5.
:- dynamic bag/1.

% Keys and Doors
key(10).
door(10).

% ----------------- Scenario 1 ------------------------------ %
% Left tree
connected(11, startMaze, nil, 12, 117).
connected(12, noObject, 11, 13, 14).
connected(13, key(10), 12, 15, 16).
connected(14, noObject, 12, nil, nil).
connected(15, noObject, 13, 17, 18).
connected(16, hole, 13, nil, nil).
connected(17, flashlight, 15, 19, 110).
connected(18, noObject, 15, nil, nil).
connected(19, door(10), 17, 111, 112).
connected(110, hole, 17, nil, nil).
connected(111, sword, 19, 113, 114).
connected(112, bear, 19, nil, nil).
connected(113, bear, 111, 115, 116).
connected(114, noObject, 111, nil, nil).
connected(115, endMaze, 113, nil, nil).
connected(116, noObject, 113, nil, nil).

% Right tree
connected(117, noObject, 11, 118, 119).
connected(118, bear, 117, nil, nil).
connected(119, hole, 117, nil, nil).

% ----------------- Scenario 2 ------------------------------ %
% Left tree
connected(21, startMaze, nil, 22, 215).
connected(22, noObject, 21, 23, 24).
connected(23, key(10), 22, 25, 26).
connected(24, noObject, 22, nil, nil).
connected(25, noObject, 23, 27, 28).
connected(26, hole, 23, nil, nil).
connected(27, flashlight, 25, 29, 210).
connected(28, noObject, 25, nil, nil).
connected(29, door(10), 27, 211, 212).
connected(210, hole, 27, nil, nil).
connected(211, sword, 29, 213, 214).
connected(212, bear, 29, nil, nil).
connected(213, bear, 211, nil, nil).
connected(214, noObject, 211, nil, nil).

% Right tree
connected(215, noObject, 21, 216, 217).
connected(216, hole, 215, nil, nil).
connected(217, bear, 215, 218, 219).
connected(218, endMaze, 217, nil, nil).
connected(219, noObject, 217, 220, 221).
connected(220, noObject, 219, nil, nil).
connected(221, hole, 219, nil, nil).

% Bag
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
             write('Qual o labirinto deseja jogar? 1 ou 2?'),
             nl, read(Scenario), scenario(Scenario).

scenario(1)  :- play(11), deleteFromBag(_). % Start play on the first position of scenario 1
scenario(2)  :- play(21), deleteFromBag(_). % Start play on the first position of scenario 2
             
play(Position) :- nl, write('Para onde você deseja ir?'), nl, possibleWays(Position), flashlightIsOption, 
				  read(Option), option(Option, Position).


% ------------------ Option rules ---------------- %

option(a, Position) :- connected(Position, _, _, Left, _), (Left \== nil,
                       connected(Left, Object, _, _, _),nl,
                       showMessage("Você foi para a esquerda"), nl),
                       checkObject(Left, Object); 
                       nl, showMessage("Sem saída. Volte!"), nl, play(Position).

option(d, Position) :- connected(Position, _, _, _, Right), (Right \== nil,
                       connected(Right, Object, _, _, _),nl,
                       showMessage("Você foi para a direita"), nl),
                       checkObject(Right, Object); 
                       nl, showMessage("Sem saída. Volte!"), nl, play(Position).

option(s, Position) :- connected(Position, _, Father, _, _), (Father \== nil,
                       connected(_, Object, Father, _, _), nl, 
                       showMessage("Você voltou"), nl,
                       checkObject(Father, Object)) ; 
                       nl, showMessage("Você está no começo do labirinto, não dá mais pra voltar!"), nl, play(Position).

option(f, Position) :- deleteFromBag(flashlight), subMazes(Position), nl, play(Position).

option(_, Position) :- write("Opção inexistente"), nl, play(Position).

flashlightIsOption :- checkBag(flashlight), nl, write('f-Ligar lanterna'), nl; !.

possibleWays(Position) :- connected(Position, _, Father, Left, Right), 
						  (Left == nil; nl, write("a-Esquerda"), nl),
						  (Right == nil; nl, write("d- Direita"), nl),
						  (Father == nil; nl, write("s-Voltar"), nl), nl.

% -------------------- Object rules ------------------- %

checkObject(Position, noObject) :- play(Position).

checkObject(Position, bear) :- (checkBag(sword), nl, showMessage("Voce encontrou um urso, mas voce tinha uma espada e o matou"), 
                                deleteFromBag(sword),nl, removeObjectFromMaze(Position), play(Position));
                                nl, showMessage("Ghrrr!! Voce encontrou um urso, mas voce não tinha uma espada e morreu. Fim do jogo."), nl.

checkObject(Position, sword) :- nl, showMessage("Voce encontrou uma espada"), nl, addOnBag(sword), removeObjectFromMaze(Position), play(Position).

checkObject(Position, flashlight) :- nl, showMessage("Voce encontrou uma lanterna. Voce pode usar apenas uma vez para enxergar o que tem nos seus possíveis caminhos."), nl, 
									 addOnBag(flashlight), removeObjectFromMaze(Position), play(Position). 

checkObject(Position, key(Value)) :- nl, addOnBag(key(Value)), removeObjectFromMaze(Position), showMessage("Voce pegou a "), inPortuguese(key(Value)), write("."), nl, play(Position).

checkObject(Position, door(Key)) :- nl, checkBag(key(Key)), 
                                    (showMessage("Aqui tinha uma porta, mas você tinha a chave e a abriu."), play(Position));
                                    (
                                        nl, showMessage("Tem uma porta aqui e você não tem a chave. Volte e ache a chave da "), inPortuguese(door(Key)), write("!"), nl,
                                        %%  If the player dont have the key to the door, he/she goes back to the previous maze (Father)
                                        connected(Position, _, Father, _, _),
                                        play(Father)
                                    ).

checkObject(_, hole) :- nl, showMessage("Voce caiu em um buraco! Fim do jogo."), nl.

checkObject(_, endMaze) :- nl, showMessage("Voce encontrou a saída! Fim do jogo."), nl.

ident :- write("\t").
showMessage(Message) :- ident, write(Message).


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