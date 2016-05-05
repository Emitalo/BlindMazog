startPlay :- write('Bem-vindo ao Blind Mazell'), nl,
			 write('Digite o seu nome: '), read(Player), nl,
			 write('Olá '), write(Player), nl,
			 play(Player).
			 
play(Player) :- write('Para onde você deseja ir:'),nl, write('a - Esquerda, d- Direita'),
				read(Option), option(Option), play(Player).

option(a) :- write('Esquerda'), nl.
option(d) :- write('Direita'), nl.
option(_) :- write('Opção inexistente'), nl.

isConnected(Position) :- connected(Position, _, Father, Left, Right), nl, 
						 write(Father), nl, printPosition(Left),nl, printPosition(Right).

printPosition(Position) :- 
						% If position is nil, cut
						Position == nil, !;
						connected(Position, Object, Father, Left, Right),
						write(Object), nl, write(Father), nl, write(Left),nl, write(Right).

printMaze(Position) :- connected(Position, Object, Father, Left, Right), nl,
				write('{'), nl, 
				write('	Posição => '), write(Position), nl,
				write('	Objeto => '), write(Object), nl,
				write('	Pai => '), write(Father), nl,
				printSons(Left, Right),
				write('}'), nl.

printSons(Left, Right) :- 
				
				%If the left is nil, cut
				Left == nil, 
				write('Esquerda => '), write(Left), 
				nl, !; 
				
				%If the right is nil, cut
				Right == nil, 
				write('Direita => '), write(Right), 
				nl, !; 

				%Else write the left and right
				write('	Esquerda => '), printMaze(Left), nl,
				write('	Direita => '), printMaze(Right), nl.

% ----------------- Scenario 1 ------------------------------ %

% Creating maze
	% Object types: startMaze, noObject, key, door, bear, sword, flashlight, hole, endMaze

% connected : (position, object, father, left, right)

% Left tree
connected(1, startMaze, nil, 2, 15).
connected(2, noObject, 1, 3, 4).
connected(3, key10, 2, 5, 6).
connected(4, noObject, 2, nil, nil).
connected(5, noObject, 3, 7, 8).
connected(6, hole, 3, nil, nil).
connected(7, flashlight, 5, 9, 10).
connected(8, noObject, 5, nil, nil).
connected(9, door10, 7, 11, 12).
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
