member(X, [X|Y]).
member(X, [Y|Z]) :- member(X, Z).

append([], X, X).
append([W|X], Y, [W|Z]) :- append(X, Y, Z).

reverse([], []).
reverse([X|Y], Z) :- reverse(Y, A), append(A, [X], Z).

% --- Turn a general list into a set.
as_set([], []).
as_set([X|Y], Z) :- as_set(Y, Z), member(X, Z).
as_set([X|Y],[X|Z]) :- as_set(Y, Z), not(member(X, Z)).

% --- Compute the set difference A - B: set_diff(A, B, A-B).
set_diff([], _, []).
set_diff(X, [], Z) :- as_set(X, Z).
set_diff([W|X], Y, Z) :- member(W, Y), set_diff(X, Y, Z).
set_diff([W|X], Y, Z) :- not(member(W, Y)), set_diff(X, Y, Z), member(W, Z).
set_diff([W|X], Y, [W|Z]) :- set_diff(X, Y, Z), not(member(W, Y)), not(member(W, Z)).


% --- Given a list of unique atoms and operands, and an expresssion [A, Op, B]
%     determine whether the expression is a binary well-formed formula of no more
%     than the specified depth. Each atom corresponds to a depth of 0.
binary_wff(Atoms, Operands, 1, [A, Op, B]) :-
	member(A, Atoms), member(B, Atoms), member(Op, Operands).
binary_wff(Atoms, Operands, Depth, [A, Op, B]) :-
	Depth > 1, E is Depth - 1, member(Op, Operands), 
	binary_wff(Atoms, Operands, E, A),
	binary_wff(Atoms, Operands, E, B).
	
