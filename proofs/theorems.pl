% Theorems about tests2spec, proved by exhaustion. Run: swipl -g main -t halt proofs/theorems.pl
:- module(theorems, [main/0]).
:- use_module('../prolog/tests2spec').
:- use_module(prove).
:- discontiguous theorem/1.
:- use_module(library(lists)).
:- use_module(library(apply)).
main :- prove_all(theorems).

% Domain: every spec; every list of length 0..3 over 0..2 as an input.
input(L) :- between(0, 3, K), length(L, K), maplist([X]>>between(0, 2, X), L).
all_tests(S, Ts) :- findall(I-O, ( input(I), apply_spec(S, I, O) ), Ts).

% 1. The inferred spec passes every test.
theorem(inferred_spec_passes) :- forall(( spec(S), all_tests(S, Ts), infer(Ts, R) ), ( R \== none, consistent(R, Ts) )).

% 2. It is a smallest one: no smaller spec passes every test.
theorem(inferred_spec_is_smallest) :-
    forall(( spec(S), all_tests(S, Ts), infer(Ts, R), size(R, N) ), \+ ( spec(Q), size(Q, M), M < N, consistent(Q, Ts) )).

% 3. With every input as a test, the inferred spec is the same function as the true one on the whole domain.
theorem(recovers_the_function) :-
    forall(( spec(S), all_tests(S, Ts), infer(Ts, R), input(I) ), ( apply_spec(S, I, A), apply_spec(R, I, B), A == B )).

% 4. none means no spec in the space passes.
theorem(none_means_no_spec) :-
    forall(member(Ts, [[[1]-[2,2]], [[1,2]-7], [[]-[1]], [[2]-[2], [2]-[3]]]), ( infer(Ts, none), \+ ( spec(S), consistent(S, Ts) ) )).

% 5. infer is steadfast.
theorem(infer_is_steadfast) :- forall(( spec(S), all_tests(S, Ts), spec(G), size(G, 1) ), iff(infer(Ts, G), ( infer(Ts, R), R == G ))).

% 6. infer_all lists exactly the smallest passing specs, starting with infer's answer, and with every input as a
%    test, all of them compute the same function as the true one.
theorem(infer_all_is_the_smallest_fits) :-
    forall(( spec(S), all_tests(S, Ts), infer(Ts, R), infer_all(Ts, L) ), ( L = [R|_], size(R, N),
        forall(member(Q, L), ( size(Q, N), consistent(Q, Ts) )), forall(( spec(Q), size(Q, N), consistent(Q, Ts) ), memberchk(Q, L)),
        forall(( member(Q, L), input(I) ), ( apply_spec(S, I, A), apply_spec(Q, I, B), A == B )) )),
    infer_all([[2]-[2]], [prim(identity), prim(reverse), prim(msort), prim(dedupe), prim(evens)]).
