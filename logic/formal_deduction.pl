

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

