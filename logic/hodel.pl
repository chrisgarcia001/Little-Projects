%--------------- Hodel's basic rules for P ---------------

rule([], [[~,A],+,A], axiom). % Base
rule([[A,+,[B,+,C]]], [[A,+,B],+,C], associative). % Base

rule([[[A,+,B],+,C]], [A,+,[B,+,C]], alt_associative). 
rule([[A,+,B]], [B,+,A], comm).

rule([[A,+,A]], A, contraction). % Base
rule([A], [B,+,A], expansion). % Base
rule([A], [A,+,B], alt_exp).

rule([[A,+,B],[[~,A],+,C]], [B,+,C], cut). % Base

rule([A, [A,->,B]], B, mp).
rule([[~,B], [A,->,B]], [~,A], mt).
rule([[A,+,B], [~,A]], B, ds).
rule([[A,->,B]], [[~,B],->,[~,A]], cp).
rule([[A,->,B],[B,->,C]], [A,->,C], hs).

rule([A], [~,[~,A]], dn_1).
rule([~,[~,A]], A, dn_2).
rule([[A,+,B]], [[~,[~,A]],+,B], dn_3).
rule([[[~,[~,A]],+,B]], [A,+,B], dn_4).

rule([A,*,B], A, sep).
rule([A,*,B], B, sep).

rule([A, B], [A,*,B], join).


equiv([P, ->, Q], [[~, P], +, Q], mimp). % Base
equiv([A,*,B], ~[[~,A],+,[~,B]], and_def). % Base