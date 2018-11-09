depth(X, 0) :- not(is_list(X)).
depth([], 1).
depth([X|Y], Z) :- is_list(X), depth(X, A),  depth(Y, B), Z is max(A + 1,B).
depth([X|Y], Z) :- not(is_list(X)), depth(Y, Z).

identical(X, X).
unary_op_start_depth(U, E, 0) :- not(is_list(E)).
unary_op_start_depth(U, [], 0). 
unary_op_start_depth(U, [X,Y|Z], 0) :- not(identical(U, X)).
unary_op_start_depth(U, [U,Y|Z], D) :- unary_op_start_depth(U, Y, E), D is E + 1.


rule([[P, ->, Q], P], Q, mp).
rule([[P, ->, Q], [~, Q]], [~, P], mt).
rule([[P, ->, Q], [Q, ->, R]], [P, ->, R], hs).
rule([[P, +, Q], [~, P]], Q, ds).
rule([[[P, ->, Q], *, [R, ->, S]], [P, +, R]], [Q, +, S], cd).
rule([[P, ->, Q]], [P, ->, [P, *, Q]], abs).
rule([[P, *, Q]], P, simp).
rule([P, Q], [P, *, Q], conj).
rule([P], [P, +, Q], add).
%rule([], [P, +, [~, P]], ex_middle).
%rule([], [~ [P, *, [~, P]]], non_contradict).

equiv([P, +, Q], [Q, +, P], comm).
equiv([P, *, Q], [Q, *, P], comm).
equiv([P, +, [Q, +, R]], [[P, +, Q], +, R], assoc).
equiv([P, *, [Q, *, R]], [[P, *, Q], *, R], assoc).
equiv([~, [P, *, Q]], [[~, P], +, [~, Q]], demorgan).
equiv([~, [P, +, Q]], [[~, P], *, [~, Q]], demorgan).
equiv([P, *, [Q, +, R]], [[P, *, Q], +, [P, *, R]], dist).
equiv([P, +, [Q, *, R]], [[P, +, Q], *, [P, +, R]], dist).
equiv([P, ->, Q], [[~, Q], ->, [~, P]], transp).
equiv([P, ->, Q], [[~, P], +, Q], mimp).
equiv([[P, *, Q], ->, R], [P, ->, [Q, ->, R]], export).
equiv([P, =, Q], [[P, ->, Q], *, [Q, ->, P]], mequiv).

% --------- Qualified Equivalences - for performance -----  
%equiv(P, [P, *, P], tautology) :- depth(P, D), D = 0.
equiv(P, [P, +, P], tautology) :- depth(P, D), D = 0.
equiv([~, P], [[~, P], +, [~, P]], tautology) :- depth(P, D), D = 0.
equiv([~, [~, P]], P, dn) :- unary_op_start_depth(~, P, D), D = 0.

% ----------------- Core Theorem Prover ------------------
rewrite(X, Y, Z) :- equiv(X, Y, Z).
rewrite(X, Y, Z) :- equiv(Y, X, Z).

has_vars(X) :- var(X).
has_vars([X|Y]) :- has_vars(X).
has_vars([X|Y]) :- has_vars(Y).

subexp(X, _) :- var(X), !, fail.
subexp([X|_], X) :- is_list(X).
subexp([_|Y], Z) :- subexp(Y, Z).
subexp(X, Y) :- member(Z, X), subexp(Z, Y).

subexp_replace(X, Y, [X|Z], [Y|Z]).
subexp_replace(X, Y, [P|Q], [P|R]) :- subexp_replace(X, Y, Q, R).
subexp_replace(X, Y, [P|Q], [R|Q]) :- is_list(P), subexp_replace(X, Y, P, R).

replace(X, Y, R) :- rewrite(X, Y, R).
replace(X, Y, R) :- subexp(X, A), rewrite(A, B, R), subexp_replace(A, B, X, Y).

%deduce(Premises, Conclusion, Proof, MaxTotalDepth, MaxEquivalenceDepth, Seen).
deduce(Prem, Conc, Proof, Depth, Eqv) :- deduce(Prem, Conc, Proof, Depth, Eqv, []).
deduce([], C, [[C, R]], D, E, _) :- D >= 0, E >= 0, rule([], C, R).
deduce(Prems, C, [[C, premise]], Depth, Eqv, _) :- 
	Depth >= 0, Eqv >= 0, member(C, Prems).
deduce(Prems, Conc, [[Conc, Rule]|Rproofs], Depth, Eqv, Seen) :-
	Depth > 0, Eqv >= 0, E is Depth - 1, 
	not(member(Conc, Seen)),
	rule(P, Conc, Rule),
	deduce_all(Prems, P, Rproofs, E, Eqv, Seen).
deduce(Prems, Conc, [[Conc, Rule]|Rproof], Depth, Eqv, Seen) :-
	Depth > 0, Eqv > 0, E is Depth - 1, F is Eqv - 1,
    not(has_vars(Conc)),
	replace(Conc, X, Rule),
	deduce(Prems, X, Rproof, E, F, [Conc|Seen]).

deduce_all(Prems, [], [], Depth, Eqv, _) :- Depth >= 0, Eqv >= 0.
deduce_all(Prems, [C|Cs], [Pf|Pfs], Depth, Eqv, Seen) :-
	Depth > 0, Eqv >= 0,
	deduce(Prems, C, Pf, Depth, Eqv, Seen),
	deduce_all(Prems, Cs, Pfs, Depth, Eqv, Seen).

