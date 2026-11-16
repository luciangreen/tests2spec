% tests2spec: infer a spec from test cases. Given Input-Output tests, it finds the simplest
% function (one primitive, or one applied after another) that passes all of them, so S2A2 can
% regenerate the code from the spec and keep the shortest version that still passes.
%?- infer([[3,1,2]-[1,2,3], [2,2]-[2,2]], S).      % S = prim(msort)
%?- infer([[1,2]-[3,2], [5]-[6]], S).              % S = comp(reverse, inc): reverse after adding 1
%?- infer([[1,2]-7], S).                           % S = none
%?- apply_spec(comp(sum, double), [1,2,3], O).    % O = 12
:- module(tests2spec, [prim/3, apply_spec/3, spec/1, size/2, infer/2, consistent/2]).
:- use_module(library(lists)).
:- use_module(library(apply)).

% prim(Name, Type, Goal): list -> list or list -> value primitives, simplest first.
prim(identity, ll, [L, L]>>true).
prim(reverse, ll, [L, R]>>reverse(L, R)).
prim(msort, ll, [L, R]>>msort(L, R)).
prim(dedupe, ll, [L, R]>>sort(L, R)).
prim(tail, ll, [L, R]>>(L = [_|R] -> true ; R = [])).
prim(double, ll, [L, R]>>maplist([X, Y]>>(Y is 2 * X), L, R)).
prim(inc, ll, [L, R]>>maplist([X, Y]>>(Y is X + 1), L, R)).
prim(evens, ll, [L, R]>>include([X]>>(X mod 2 =:= 0), L, R)).
prim(length, lv, [L, N]>>length(L, N)).
prim(sum, lv, [L, S]>>sum_list(L, S)).
prim(max, lv, [L, M]>>(L == [] -> M = none ; max_list(L, M))).
prim(min, lv, [L, M]>>(L == [] -> M = none ; min_list(L, M))).
prim(first, lv, [L, X]>>(L = [X0|_] -> X = X0 ; X = none)).
prim(last, lv, [L, X]>>(last(L, X0) -> X = X0 ; X = none)).

% spec(S): every spec, smallest first: prim(F), then comp(F, G) = F after G, with G list -> list.
spec(prim(F)) :- prim(F, _, _).
spec(comp(F, G)) :- prim(G, ll, _), G \== identity, prim(F, _, _), F \== identity.
size(prim(_), 1).
size(comp(_, _), 2).

apply_spec(prim(F), I, O) :- prim(F, _, G), call(G, I, O0), O = O0.
apply_spec(comp(F, G), I, O) :- apply_spec(prim(G), I, M), apply_spec(prim(F), M, O0), O = O0.

consistent(S, Tests) :- forall(member(I-O, Tests), apply_spec(S, I, O)).

% infer(+Tests, -Spec): the first (smallest) spec that passes every test, or none.
infer(Tests, S) :- ( spec(S0), consistent(S0, Tests) -> S = S0 ; S = none ).
