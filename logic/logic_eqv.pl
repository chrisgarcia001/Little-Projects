% -------------------------- Logic Equivalences -----------------------------------------

depth(X, 0) :- not(is_list(X)).
depth([], 1).
depth([X|Y], Z) :- is_list(X), depth(X, A),  depth(Y, B), Z is max(A + 1,B).
depth([X|Y], Z) :- not(is_list(X)), depth(Y, Z).

identical(A, A).

equiv([A,->,B], [[~,A],+,B], mimp).
equiv([A,=,B], [[A,->,B],*,[B,->,A]], be).
equiv([A,*,B], [~[[~,A],+,[~,B]]], def_and).
equiv([~,[A,*,B]], [[~,A],+,[~,B]], dem).
equiv([~,[A,+,B]], [[~,A],*,[~,B]], dem).


equiv(A, [~,[~,A]], dn) :- depth(A, D), D =< 2.

equiv([A,X,[B,X,C]], [[A,X,B],X,C], assoc) :- member(X, [+,*]).
equiv([A,X,B], [B,X,A], comm) :- member(X, [+,*]).
equiv([A,X,A], A, idem) :- member(X, [+,*]).

equiv([A,X,[B,Y,C]], [[A,X,B],Y,[A,X,C]], dist) :- 
	member(X, [+,*]), member(Y, [+,*]), not(identical(X, Y)).
equiv([A,X,[B,Y,[~,B]]], A, simp) :- 
	member(X, [+,*]), member(Y, [+,*]), not(identical(X, Y)).

rewrite([A,X,[A,Y,B]], A, abs) :- 
	member(X, [+,*]), member(Y, [+,*]), not(identical(X, Y)).
	
rewrite(X, Y, Z) :- equiv(X, Y, Z).
rewrite(X, Y, Z) :- equiv(Y, X, Z).




