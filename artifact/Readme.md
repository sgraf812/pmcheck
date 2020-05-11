Artifact
========

Accompanying the ICFP 2020 paper
_Lower Your Guards: A Compositional Pattern-Match Coverage Checker_
by Sebastian Graf, Simon Peyton Jones, and Ryan G. Scott

# Entering the artifact

The artifact is packaged as a Docker image. There are two ways to obtain it:

1. Build the `Dockerfile` from source. This can be done by running `make`
   in the same directory as the `Dockerfile`.
   Be warned: this will require building GHC, OCaml, and Idris from source,
   so this can take a very long time (approximately 30 minutes to an hour,
   depending on how powerful your computer is).
2. TODO RGS: DockerHub

Regardless of which step above you pick, the end result will be that you will
enter a `bash` session in a Docker image in which a developmental version of
GHC is on your `PATH`. This version of GHC implements the Lower Your Guards
(LYG) coverage checking algorithm as described in the accompanying paper.
You can verify this by running:

```
# ghc --version
The Glorious Glasgow Haskell Compilation System, version 8.11.0.20200227
```

You will also an older version of GHC (8.8.3) (at `/opt/ghc/8.8.3/bin/ghc`)
that predates LYG. This version of GHC was used in Section 6 (Evaluation) of
the paper to compare the performance of GHC before and after the implementation
of LYG. Since the two `ghc` binaries have the same name, simply typing `ghc`
will default to the LYG version of GHC. As a result, you will have to type out
`/opt/ghc/8.8.3/bin/ghc` if you want to use 8.8.3 in particular.

# Directory structure

When you enter the Docker image, you will be placed in the `/root` directory,
which contains the parts of the image that are relevant to the artifact. Here
is what `/root` looks like:

```
# pwd
/root
# ls
Readme.md  examples  ghc  head-hackage-eval  head.hackage  idris  ocaml  perf-tests
```

Here is what each of these files and directories are:

* `Readme.md`: The file you are reading now, copied over to the Docker image
  for the sake of convenience.
* `examples`: These contain code fragments from the paper in standalone Haskell
  files. These are primarily used to illustrate concepts from the paper and to
  demonstrate code that should (or should not) emit warnings.
* `ghc`: This is a checkout of GHC's source code at this commit:
  https://gitlab.haskell.org/ghc/ghc/-/commit/59c023ba5ccb10fff62810591f20608bd73c97af
  This is a snapshot of GHC that implements LYG as presented in the paper.
  There is not much of interest in this directory for the sake of the artifact,
  since building this Docker image will install this version of GHC automatically.
  Still, you can look at the corresponding source code in this directory if you
  so wish.
* `head-hackage-eval`: This contains the source code of the seven libraries
  mentioned in Section 6 (Evaluation).
* `head.hackage`: This is a checkout of the `head.hackage` repository at commit
  https://gitlab.haskell.org/ghc/head.hackage/-/commit/30a310fd8033629e1cbb5a9696250b22db5f7045
  As mentioned in Section 6, `head.hackage` contains `.patch` files needed to
  make libraries from Hackage (an online collection of Haskell libraries)
  compile with developmental versions of GHC, such as the one in this artifact.
  Building this Docker image will automatically apply the patches from this
  repo to the necessary libraries in the `head-hackage-eval`, so the
  `head.hackage` directory is kept around in case you wish to view the
  patches yourself.
* `idris`: This contains an Idris file containing a program mentioned in
  Section 7.4 (Strict fields in inhabitation testing).
* `ocaml`: This contains an OCaml file containing a program mentioned in
  Section 7.4 (Strict fields in inhabitation testing).
* `perf-tests`: These contain the ten performance tests mentioned in Figure 10
  of Section 6.1 (Performance tests).

The following sections will describe these directories in more detail.

# `examples`

```
# cd /root/examples/
# ls
Ex1.hs    Ex2_2_1.hs  Ex2_3.hs  Ex3_3.hs  Ex4_1.hs  Ex4_4.hs  Ex5_3.hs
Ex2_1.hs  Ex2_2_2.hs  Ex3_1.hs  Ex3_7.hs  Ex4_2.hs  Ex5_2.hs  Ex5_4.hs
```

The `examples` directory contains code fragments from the paper, condensed into
standalone Haskell files. These are primarily used to illustrate concepts from
the paper and to demonstrate code that should (or should not) emit warnings.
Accordingly, each file enables `{-# OPTIONS_GHC -Wall #-}` at the top to
ensure that all pattern-match coverage checking warnings are enabled.

The naming conventions reflect which sections of the paper the code can be
found in. For instance, `Ex2_1.hs` contains the code from Section 2.1,
`Ex2_2_1.hs` contains the code from Section 2.2.1, etc. You can compile them
yourself by running `ghc <filename>.hs`.

Here are some assorted notes on each of the programs in this directory:

* `Ex1.hs`: A basic example of a function `f` that emits both a non-exhaustive
  patterns warning and an overlapping patterns warning:

  ```
  # ghc Ex1.hs
  [1 of 1] Compiling Ex1              ( Ex1.hs, Ex1.o )

  Ex1.hs:5:1: warning: [-Wincomplete-patterns]
      Pattern match(es) are non-exhaustive
      In an equation for `f':
          Patterns not matched: p where p is not one of {0}
    |
  5 | f 0 = True
    | ^^^^^^^^^^...

  Ex1.hs:6:1: warning: [-Woverlapping-patterns]
      Pattern match is redundant
      In an equation for `f': f 0 = ...
    |
  6 | f 0 = False
    | ^^^^^^^^^^^
  ```
* `Ex2_1.hs`:
  * The `guardDemo` function exists purely to illustrate different forms of
    guards in Haskell. It will not emit any warnings.
  * The `signum` function is an example of a function that is intuitively
    exhaustive, but LYG is unable to check its exhaustivity automatically
    since doing so would require knowledge about the properties of `Int`
    inequalities. Accordingly, LYG will generate a warning for `signum`:

    ```
    # ghc Ex2_1.hs
    [1 of 1] Compiling Ex2_1            ( Ex2_1.hs, Ex2_1.o )

    Ex2_1.hs:12:1: warning: [-Wincomplete-patterns]
        Pattern match(es) are non-exhaustive
        In an equation for `signum': Patterns not matched: _ :: Int
       |
    12 | signum x | x > 0  = 1
       | ^^^^^^^^^^^^^^^^^^^^^...
    ```
  * The `not`, `not2`, and `not3` functions all implement boolean negation
    using various combinations of direct pattern matching and guards. LYG
    is able to conclude that all of these are exhaustive, so none of them
    will emit any warnings.
* `Ex2_2_1.hs`: This contains two functions, `last` and `safeLast`, that
  demonstrate examples of view patterns. The `length` function uses view
  patterns that are too sophisticated for LYG to reason about, so it will
  emit a warning:

  ```
  # ghc Ex2_2_1.hs
  [1 of 1] Compiling Ex2_2_1          ( Ex2_2_1.hs, Ex2_2_1.o )

  Ex2_2_1.hs:10:1: warning: [-Wincomplete-patterns]
      Pattern match(es) are non-exhaustive
      In an equation for `length':
          Patterns not matched: Data.Text.Internal.Text _ _ _
     |
  10 | length (Text.null   -> True)         = 0
     | ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^...
  ```

  The view patterns in `safeLast`, however, are deemed exhaustive, so
  `safeLast` will not emit any warnings.
* `Ex2_2_2.hs`: This contains examples of pattern synonyms, `Nil` and `Cons`,
  as well as a modified version of `length` from `Ex2_2_1.hs` that is defined
  using these pattern synonyms. Note that `Nil` and `Cons` are declared to be
  a `COMPLETE` set, so that combination of patterns is deemed to be exhaustive
  by the coverage checker. Accordingly, since `length` matches on both `Nil`
  and `Cons`, no warnings are emitted for `length`.
* `Ex2_3.hs`: This contains code examples from Sections 2.3 and its
  subsections:
  * The `v` function provides an example of matching on `SMaybe`, a data type
    whose constructor `SJust` is strict in its field. Since the right-hand side
    of the `v (SJust _) = 1` equation can never be reached, it will emit a
    warning:

    ```
    # ghc Ex2_3.hs
    [1 of 1] Compiling Ex2_3            ( Ex2_3.hs, Ex2_3.o )

    Ex2_3.hs:13:1: warning: [-Woverlapping-patterns]
        Pattern match is redundant
        In an equation for `v': v (SJust _) = ...
       |
    13 | v (SJust _) = 1
       | ^^^^^^^^^^^^^^^

    <elided>
    ```
  * The `u` and `u'` functions demonstrate the difference between redundant
    and inaccessible cases. `u` contains two redundant matches:

    ```
    # ghc Ex2_3.hs
    [1 of 1] Compiling Ex2_3            ( Ex2_3.hs, Ex2_3.o )

    <elided>

    Ex2_3.hs:18:8: warning: [-Woverlapping-patterns]
        Pattern match is redundant
        In an equation for `u': u () | False = ...
       |
    18 | u () | False = 1
       |        ^^^^^

    Ex2_3.hs:20:1: warning: [-Woverlapping-patterns]
        Pattern match is redundant
        In an equation for `u': u _ = ...
       |
    20 | u _          = 3
       | ^^^^^^^^^^^^^^^^
    ```

    While `u'` contains two inaccessible matches:

    ```
    # ghc Ex2_3.hs
    [1 of 1] Compiling Ex2_3            ( Ex2_3.hs, Ex2_3.o )

    <elided>

    Ex2_3.hs:23:9: warning: [-Woverlapping-patterns]
        Pattern match has inaccessible right hand side
        In an equation for u': u' () | False = ...
       |
    23 | u' () | False = 1
       |         ^^^^^

    Ex2_3.hs:24:9: warning: [-Woverlapping-patterns]
        Pattern match has inaccessible right hand side
        In an equation for u': u' () | False = ...
       |
    24 |       | False = 2
       |         ^^^^^
    ```

    To see why the matches in `u'` are labeled inaccessible, not redundant, you
    evaluate `u'` on a bottoming (`⊥`) value. To do so, load this file into
    GHCi and run the following:

    ```
    # ghci Ex2_3.hs

    <elided>

    *Ex2_3> u' undefined
    *** Exception: Prelude.undefined
    CallStack (from HasCallStack):
      error, called at libraries/base/GHC/Err.hs:79:14 in base:GHC.Err
      undefined, called at <interactive>:1:4 in interactive:Ghci1
    *Ex2_3> :quit
    Leaving GHCi.
    ```

    We can see that `u' undefined` throws an `undefined` exception—that is
    to say, it returns `⊥`. Now, we can see what happens when we run a
    modified version of `u'` that has the inaccessible first and second cases
    removed:

    ```
    # ghci Ex2_3.hs

    <elided>

    *Ex2_3> u'_modified undefined
    3
    *Ex2_3> :quit
    Leaving GHCi.
    ```

    Rather than throwing an exception, it returns `3`. In contrast to `u'`,
    running `u undefined` will always throw an exception, regardless of whether
    or not its redundant matches are removed:

    ```
    # ghci Ex2_3.hs

    <elided>

    *Ex2_3> u undefined
    *** Exception: Prelude.undefined
    CallStack (from HasCallStack):
      error, called at libraries/base/GHC/Err.hs:79:14 in base:GHC.Err
      undefined, called at <interactive>:1:3 in interactive:Ghci1
    *Ex2_3> u_modified undefined
    *** Exception: Prelude.undefined
    CallStack (from HasCallStack):
      error, called at libraries/base/GHC/Err.hs:79:14 in base:GHC.Err
      undefined, called at <interactive>:2:12 in interactive:Ghci1
    *Ex2_3> :quit
    Leaving GHCi.
    ```
  * The `v'` function is a modified version of `v` that matches on `Maybe`,
    which is the lazy version of `SMaybe`. The bang pattern on the argument
    of `Just` makes the right-hand side of the `v' (Just !_) = 1` equation
    inaccessible:

    ```
    # ghc Ex2_3.hs
    [1 of 1] Compiling Ex2_3            ( Ex2_3.hs, Ex2_3.o )

    <elided>

    Ex2_3.hs:39:1: warning: [-Woverlapping-patterns]
        Pattern match has inaccessible right hand side
        In an equation for v': v' (Just !_) = ...
       |
    39 | v' (Just !_) = 1
       | ^^^^^^^^^^^^^^^^
    ```
  * The `g1` and `g2` functions provide examples of how matching on `T`, a
    GADT, might work. Due to the way `T` is defined, both `g1` and `g2` are
    exhaustive (and thus will emit no warnings), even though there are various
    combinations of `T1` and `T2` that they do not match on.
* `Ex3_1.hs`: This contains the `f` and `liftEq` functions, which are primarily
  intended to illustrate how patterns desugar to guard trees. We can see that
  neither `f` nor `liftEq` is exhaustive:

  ```
  # ghc Ex3_1.hs
  [1 of 1] Compiling Ex3_1            ( Ex3_1.hs, Ex3_1.o )

  Ex3_1.hs:7:1: warning: [-Wincomplete-patterns]
      Pattern match(es) are non-exhaustive
      In an equation for `f':
          Patterns not matched:
              (Just (_, _)) (Just _)
              Nothing Nothing
              Nothing (Just _)
    |
  7 | f (Just (!xs, _)) ys@Nothing  = 1
    | ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^...

  <non-coverage-related warnings elided>

  Ex3_1.hs:11:1: warning: [-Wincomplete-patterns]
      Pattern match(es) are non-exhaustive
      In an equation for `liftEq': Patterns not matched: (Just _) Nothing
     |
  11 | liftEq Nothing Nothing  = True
     | ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^...
  ```
* `Ex3_3.hs`: This contains `f`, an example of a non-nexhaustive function for
  which we would prefer a coverage warning that produces one or more concrete
  inhabitants that aren't matched on. We can verify that LYG produces
  essentially the same warning from Section 3.3, albeit with slightly more
  words:

  ```
  # ghc Ex3_3.hs
  [1 of 1] Compiling Ex3_3            ( Ex3_3.hs, Ex3_3.o )

  Ex3_3.hs:7:1: warning: [-Wincomplete-patterns]
      Pattern match(es) are non-exhaustive
      In an equation for `f':
          Patterns not matched:
              Nothing
              Just B
              Just C
    |
  7 | f (Just A) = True
    | ^^^^^^^^^^^^^^^^^
  ```
* `Ex3_7.hs`: This contains a function `f` which is actually exhaustive, but
  LYG is unable to deem it exhaustive due to its conservative, fuel-based
  inhabitation testing:

  ```
  # ghc Ex3_7.hs
  [1 of 1] Compiling Ex3_7            ( Ex3_7.hs, Ex3_7.o )

  Ex3_7.hs:9:1: warning: [-Wincomplete-patterns]
      Pattern match(es) are non-exhaustive
      In an equation for `f': Patterns not matched: SJust _
    |
  9 | f SNothing = ()
    | ^^^^^^^^^^^^^^^
  ```
* `Ex4_1.hs`: This contains a function `f` that matches on `True` twice: once
  in the first equation, and once again (redundantly) in the `case` expression.
  LYG is able to use long-distance information to conclude that the second
  match is, in fact, redundant:

  ```
  # ghc Ex4_1.hs
  [1 of 1] Compiling Ex4_1            ( Ex4_1.hs, Ex4_1.o )

  Ex4_1.hs:6:37: warning: [-Woverlapping-patterns]
      Pattern match is redundant
      In a case alternative: True -> ...
    |
  6 | f x    = g (case x of { False -> 2; True -> 3 }) ()
    |                                     ^^^^^^^^^
  ```
* `Ex4_2.hs`: This contains three ways of defining a function of type
  `Void -> a`, where `Void` is a data type with no constructors. As the paper
  claims, LYG will report that the right-hand side of `absurd2` is
  inaccessible, but will produce no warnings for `absurd1` (which ignores its
  argument) or `absurd3` (which uses `EmptyCase`):

  ```
  # ghc Ex4_2.hs
  [1 of 1] Compiling Ex4_2            ( Ex4_2.hs, Ex4_2.o )

  Ex4_2.hs:10:1: warning: [-Woverlapping-patterns]
      Pattern match has inaccessible right hand side
      In an equation for `absurd2': absurd2 !_ = ...
     |
  10 | absurd2 !_ = undefined
     | ^^^^^^^^^^^^^^^^^^^^^^
  ```
* `Ex4_4.hs`: This contains examples of pattern synonyms `P` and `Q` that are
  _not_ associated with `COMPLETE` sets. Per Section 2.2.2, we do not wish to
  equip LYG with any special reasoning about non-`COMPLETE` pattern synonyms.
  In GHC's implementation of LYG, it will be conservative and produce a warning
  for `n`, which matches on `P` and `Q`:

  ```
  # ghc Ex4_4.hs
  [1 of 1] Compiling Ex4_4            ( Ex4_4.hs, Ex4_4.o )

  Ex4_4.hs:12:5: warning: [-Wincomplete-patterns]
      Pattern match(es) are non-exhaustive
      In a case alternative: Patterns not matched: ()
     |
  12 | n = case P of Q -> 1; P -> 2
     |     ^^^^^^^^^^^^^^^^^^^^^^^^
  ```
* `Ex5_2.hs`: This contains `g`, a function with an enormous number of pattern
  guards. A naïve approach to coverage checking pattern guards would result in
  exponential compile times, but LYG is careful to implement throttling so that
  it bails out early and produces a conservative warning instead. As a result,
  you can can safely compile this file wihout blowing up your computer:

  ```
  # ghc Ex5_2.hs
  [1 of 1] Compiling Ex5_2            ( Ex5_2.hs, Ex5_2.o )

  Ex5_2.hs:7:1: warning:
      Pattern match checker ran into -fmax-pmcheck-models=30 limit, so
        * Redundant clauses might not be reported at all
        * Redundant clauses might be reported as inaccessible
        * Patterns reported as unmatched might actually be matched
      Increase the limit or resolve the warnings to suppress this message.
    |
  7 | g _
    | ^^^...

  Ex5_2.hs:7:1: warning: [-Wincomplete-patterns]
      Pattern match(es) are non-exhaustive
      In an equation for `g':
          Patterns not matched:
              _ :: a
              _ :: a
              _ :: a
              _ :: a
              ...
    |
  7 | g _
    | ^^^...
  ```
* `Ex5_3.hs`: This contains `f`, an exhaustive function that matches on all
  1000 constructors (`A1` through `A1000`) of a data type `T`. Moreover, `A1`
  and a pattern synonym `P` are put into a `COMPLETE` set. A naïve attempt at
  coverage checking `f` would result in quadratic compile times, but LYG
  instead caches residual `COMPLETE` sets, resulting in amortised linear times.
  As a result, you can safely compile this file without blowing up your
  computer.
* `Ex5_4.hs`: This contains `f`, a non-exhaustive function. A naïve encoding
  of an uncovered set for `f` would not contain any positive information, which
  could easily lead to a poor error message that does not indicate the specific
  patterns that weren't covered. As a result, LYG tracks positive information
  alongside negative information in its uncovered sets, which allows it to
  specifically report that `False` is not covered in `f`:

  ```
  # ghc Ex5_4.hs
  [1 of 1] Compiling Ex5_4            ( Ex5_4.hs, Ex5_4.o )

  Ex5_4.hs:5:1: warning: [-Wincomplete-patterns]
      Pattern match(es) are non-exhaustive
      In an equation for `f': Patterns not matched: False
    |
  5 | f True = ()
    | ^^^^^^^^^^^
  ```

Note that this directory only contains examples of Haskell code. Section 7.4,
which covers examples of OCaml and Idris code, are handled separately in the
`ocaml` and `idris` sections of this `Readme`, respectively.

# `head-hackage-eval`

TODO RGS

# `idris`

TODO RGS

# `ocaml`

TODO RGS

# `perf-tets`

TODO RGS
