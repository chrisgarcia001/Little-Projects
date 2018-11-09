% ------- This is a set of basic propositional logic rules from Copi et al., 14th ed. ----------

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