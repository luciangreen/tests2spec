:- module(cases, [title/1, case/3]).
:- use_module('../prolog/tests2spec').
:- use_module(engine).
title('tests2spec').
list_g(L) :- rnd_int(0, 5, N), length(L, N), maplist([X]>>rnd_int(0, 6, X), L).
spec_g(S) :- findall(X, spec(X), Ss), rnd_pick(Ss, S).
case(infer, [Ts], infer) :- spec_g(S), rnd_int(1, 4, K), length(Is, K), maplist(list_g, Is), maplist([I, I-O]>>apply_spec(S, I, O), Is, Ts).
case(infer_noisy, [Ts], infer) :- rnd_int(1, 3, K), length(Ts, K), maplist([I-O]>>( list_g(I), list_g(O) ), Ts).
case(apply_spec, [S, I], apply_spec) :- spec_g(S), list_g(I).
