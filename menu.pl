startPlay :- write('Bem-vindo ao Blind Mazell'), nl,
			 write('Digite o seu nome: '), read(Player), nl,
			 write('Olá '), write(Player), nl,
			 play(Player).
			 
play(Player) :- write('Para onde você deseja ir:'),nl, write('a - Esquerda, d- Direita'),
				read(Option), option(Option), play(Player).

option(a) :- write('Esquerda'), nl.
option(d) :- write('Direita'), nl.
option(_) :- write('Opção inexistente'), nl.