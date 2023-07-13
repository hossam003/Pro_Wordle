
main:-
	write('Welcome to Pro-Wordle'),
	nl,
	write('---------------------------'),
	nl,
	build_kb,nl,nl,
	play.

build_kb:-
	write('Please enter a word and its category on separate lines:'),nl,
	read(Word),nonvar(Word),
	((Word='done',nl,write('Done building the words database...'),nl,!);
	(read(Category),nonvar(Category),
	assert(word(Word,Category)),nl,build_kb)).

play:-
	categories(Categories_list),
	write('The available categories are: '),write(Categories_list),nl,
	choose_category(Categories_list,Category),
	choose_length(Length,Category),
	Num_guesses is Length+1,
	pick_word(Word,Length,Category),
	write('Game started. You have '),write(Num_guesses),write(' guesses.'),nl,
	game(Length,Num_guesses,Word).

game(Length,Guesses_left,Word):-
	(Guesses_left=0,write('You Lost!'),!);
	(Guesses_left_new is Guesses_left-1,
	write('Enter a word composed of '),write(Length),write(' letters:'),nl,
	read(Input_word),
	((Input_word==Word, write('You Won!'),!);
	(string_length(Input_word,L_temp),Length\==L_temp,write('Word is not composed of '),write(Length),write(' letters. Try again.'),nl,game(Length,Guesses_left,Word));
	(string_chars(Input_word,Input_list),
	string_chars(Word,Word_list),
	correct_letters(Input_list,Word_list,CL1),
	remove_duplicates(CL1,Correct_letters),
	write('Correct Letters are: '),write(Correct_letters),nl,
	correct_positions(Input_list,Word_list,Correct_positions),
	write('Correct letters in correct positions are: '),write(Correct_positions),nl,
	write('Remaining Guesses are '),write(Guesses_left_new),nl,
	game(Length,Guesses_left_new,Word)))).
	
choose_length(Length,Category):-
	write('Choose a length:'),nl,
	read(L_temp),
	((available_length(L_temp,Category),Length=L_temp,!);
	(write('There are no words of this length.'),nl,choose_length(Length,Category))).
	
choose_category(Categories_list,Category):-	
	write('Choose a category:'),nl,
	read(C_temp),
	((is_category(C_temp),Category=C_temp,!);
	(write('This category does not exist'),nl,choose_category(Categories_list,Category))).
	
remove_duplicates([],[]).

remove_duplicates([H | T], List) :-    
	member(H, T),
	remove_duplicates( T, List).

remove_duplicates([H | T], [H|T1]) :- 
	\+member(H, T),
	remove_duplicates( T, T1).

is_category(C):-
	word(_,C).

categories(L):-
	setof(C,is_category(C),L).

correct_letters([],_,[]).
correct_letters(_,[],[]).

correct_letters([H1|T1],[H1|T2],[H1|T]):-
	correct_letters(T1,T2,T).
	
correct_letters([H1|T1],[H2|T2],[H1|T]):-
	H1\==H2,
	member(H1,T2),
	delete(T2,H1,T2d),
	correct_letters(T1,[H2|T2d],T).
	
correct_letters([H1|T1],[H2|T2],T):-
	H1\==H2,
	\+member(H1,T2),
	correct_letters(T1,[H2|T2],T).


correct_positions([],[],[]).

correct_positions([H1|T1],[H1|T2],[H1|T]):-
	correct_positions(T1,T2,T).

correct_positions([H1|T1],[H2|T2],T):-
	H1\==H2,
	correct_positions(T1,T2,T).

available_length(Length):-
	word(Word,_),
	string_length(Word,Length).
	
available_length(Length,Category):-
	word(Word,Category),
	string_length(Word,Length).
	
pick_word(Word,Length,Category):-
	available_length(Length,Category),
	word(Word,Category).
