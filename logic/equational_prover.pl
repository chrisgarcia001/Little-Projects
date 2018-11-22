% -------------- SWI Prolog -------------------------
% https://swish.swi-prolog.org/

% -------------- Rewrite Rules ----------------------
rewrite([A, +, [B, +, C]],  [[A, +, B], +, C], assoc).
rewrite([[A, +, B], +, C], [A, +, [B, +, C]],  assoc).
rewrite([A, *, [B, *, C]],  [[A, *, B], *, C], assoc).
rewrite([[A, *, B], *, C], [A, *, [B, *, C]],  assoc).
rewrite([A, +, B], [B, +, A], comm).
rewrite([A, *, B], [B, *, A], comm).
rewrite([A, +, A], [2, *, A], double).


% -------------- Core Theorem Prover ----------------
:- table subexp/2, subexp_replace/3, prove/5.

subexp([X|_], X). %:- not(atomic(X)).
subexp([_|Y], Z) :- subexp(Y, Z).
subexp(X, Y) :- member(Z, X), subexp(Z, Y).

subexp_replace(X, Y, [X|Z], [Y|Z]).
subexp_replace(X, Y, [P|Q], [P|R]) :- subexp_replace(X, Y, Q, R).
subexp_replace(X, Y, [P|Q], [R|Q]) :- not(atomic(P)), subexp_replace(X, Y, P, R).

prove(X, X, [X], _, N) :- N >= 0.
prove(X, Y, [X, T|R], S, N) :-
    M is N - 1, M >= 0,
    rewrite(X, Z, T), not(member(Z, S)),
    prove(Z, Y, R, [Z|S], M).
prove(X, Y, [X, T|R], S, N) :-
    M is N - 1, M >= 0,
    subexp(X, P), rewrite(P, Q, T), 
    subexp_replace(P, Q, X, Z), not(member(Z, S)),
    prove(Z, Y, R, [Z|S], M).
prove(X, Y, Z, N) :- prove(X, Y, Z, [X], N).