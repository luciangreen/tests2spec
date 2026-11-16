# tests2spec

infer a spec from test cases. Given Input-Output tests, it finds the simplest function (one primitive, or one applied after another) that passes all of them, so S2A2 can regenerate the code from the spec and keep the shortest version that still passes.

## Use

```prolog
?- use_module(prolog/tests2spec).
?- infer([[3,1,2]-[1,2,3], [2,2]-[2,2]], S).      % S = prim(msort)
?- infer([[1,2]-[3,2], [5]-[6]], S).              % S = comp(reverse, inc): reverse after adding 1
?- infer([[1,2]-7], S).                           % S = none
?- apply_spec(comp(sum, double), [1,2,3], O).    % O = 12
```

## Proofs

`proofs/theorems.pl` proves 5 theorems by exhaustion: each one is checked for every case in a finite domain that covers every branch of the definitions. every spec; every list of length 0..3 over 0..2 as an input.

1. The inferred spec passes every test.
2. It is a smallest one: no smaller spec passes every test.
3. With every input as a test, the inferred spec is the same function as the true one on the whole domain.
4. none means no spec in the space passes.
5. infer is steadfast.

```sh
swipl -g main -t halt proofs/theorems.pl
```

## 200 inputs and outputs

`io/ios.txt` lists 200 inputs and outputs from real runs, and `io/ios.pl` has the same as Prolog facts. The inputs come from a fixed seed (`io/cases.pl`). `swipl -g check -t halt io/run.pl` runs them again. It fails if any output changes, or if a predicate doesn't confirm its own recorded output, which checks steadfastness. GitHub Actions runs the proofs and the examples on every push, and records the examples on the first push.

Licence: BSD-3-Clause.
