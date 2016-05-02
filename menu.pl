startPlay :- write('Bem-vindo ao Blind Mazell'), nl,
			 write('Digite o seu nome: '), read(Player), nl,
			 write('Olá '), write(Player), nl,
			 play(Player).
			 
play(Player) :- write('Para onde você deseja ir:'),nl, write('a - Esquerda, d- Direita'),
				read(Option), option(Option), play(Player).

option(a) :- write('Esquerda'), nl.
option(d) :- write('Direita'), nl.
option(_) :- write('Opção inexistente'), nl.

% Creating maze
% Object types: startMaze, noObject, key, door, bear, sword, flashlight, hole, endMaze
% connected : (position, object, left, right)

% Scenario 1
% Left tree
connected(1, startMaze, nil, noObject, noObject).
connected(2, noObject, 1, key10, noObject).
connected(3, key10, 2, noObject, bear).
connected(4, noObject, 2, nil, nil).
connected(5, noObject, 3, flashlight, noObject).
connected(6, hole, 3, nil, nil).
connected(7, flashlight, 5, door10, hole).
connected(8, noObject, 5, nil, nil).
connected(10, door10, 7, sword, bear).
connected(11, sword, 9, bear, noObject).
connected(12, bear, 9, nil, nil).
connected(13, bear, 11, nil, nil).
connected(14, noObject, 11, nil, nil).
connected(15, noObject, 1, hole, bear).
connected(16, hole, 15, nil, nil).
connected(17, bear, 15, endMaze, noObject).
connected(18, endMaze, 17, nil, nil).
connected(19, noObject, 17, noObject, hole).
connected(20, noObject, 19, nil, nil).
connected(21, hole, 19, nil, nil).


isConnected(Position) :- connected(Position, _, Father, Left, Right), nl, 
						 write(Father), nl, write(Left),nl, write(Right).

printMaze :- connected(Position, Object, Father, Left, Right), nl,
			 write(Position), nl, write(Object), nl,
			 write(Father), nl, write(Left),nl, write(Right).