consult(copi_basic).
%consult(util).
consult(formal_deduction).


deduce([[[r,+,s],->,[t,*,u]], [[~,r],->,[v,->,[~,v]]], [~,t]], [[~,r],*,[~,s]], X, 5, 0).

deduce([[[r,+,s],->,[t,*,u]], [[~,r],->,[v,->,[~,v]]], [~,t]], [~,r], X, 6, 0).

