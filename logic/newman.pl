equiv([A,[B,+,C]], [[A,B],+,[A,C]], a1).
equiv([[A,+,B],C], [[A,C],+,[B,C]], a2).
equiv([A,[~,[~,A]]], 0, a3).
equiv([A,+,[~,A]], 1, a4).
equiv([A,+,0],A,a5).
equiv([0,+,A],A,a6).
equiv([A,1], A, a7).

rewrite(X, Y, Z) :- equiv(X, Y, Z).
rewrite(X, Y, Z) :- equiv(Y, X, Z).

