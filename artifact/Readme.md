Artifact
========

Accompanying the ICFP 2020 paper
_Lower Your Guards: A Compositional Pattern-Match Coverage Checker_
by Sebastian Graf, Simon Peyton Jones, and Ryan G. Scott

# Entering the artifact

The artifact is packaged as a Docker image. There are two ways to obtain it:

1. (Recommended) Download a pre-built image from DockerHub.
   This can be obtained by running:

   ```
   $ docker run -it --rm ryanglscott/icfp2020-lyg-artifact:0.5
   ```
2. Build the `Dockerfile` from source. This can be done by running `make`
   in the same directory as the source tarball's `Dockerfile`.
   Be warned: this will require building GHC, OCaml, and Idris from source,
   so this can take a very long time (approximately 30 minutes to an hour,
   depending on how powerful your computer is).

Regardless of which step above you pick, the end result will be that you will
enter a `bash` session in a Docker image in which a developmental version of
GHC (`/opt/ghc/lyg/bin/ghc`) is on your `PATH`. This version of GHC implements
the Lower Your Guards (LYG) coverage checking algorithm as described in the
accompanying paper. You can verify this by running:

```
# type ghc
ghc is /opt/ghc/lyg/bin/ghc
# ghc --version
The Glorious Glasgow Haskell Compilation System, version 8.11.0.20200227
```

You will also have access to two older versions of GHC:
version 8.6.5 (at `/opt/ghc/8.6.5/bin/ghc`) and
version 8.8.3 (at `/opt/ghc/8.8.3/bin/ghc`).
Both of these versions predate LYG, although 8.8.3 implements an _ad hoc_ form
of inhabitation testing for data types with strict fields (Section 2.3).
Version 8.8.3 is used in Section 6 (Evaluation) of the paper to compare the
performance of GHC before and after the implementation
of LYG, and 8.6.5 is used as a point of comparison later in the artifact
(see `Ex7_1_1.hs` in the `examples` section).

Since these `ghc` binaries all have the same name, simply typing `ghc`
will default to the LYG version of GHC. As a result, you will have to type out
`/opt/ghc/8.8.3/bin/ghc` if you want to use version 8.8.3 in particular
(and similarly for version 8.6.5).

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
  (Note that building this Docker image will install this version of GHC
  automatically.)
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
Ex1.hs    Ex2_2_1.hs  Ex2_3.hs  Ex3_3.hs  Ex4_1.hs  Ex4_4.hs  Ex5_3.hs  Ex7_1_1.hs  Ex7_3.hs
Ex2_1.hs  Ex2_2_2.hs  Ex3_1.hs  Ex3_7.hs  Ex4_2.hs  Ex5_2.hs  Ex5_4.hs  Ex7_1_2.hs
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
* `Ex5_4.hs`: This contains `f`, a non-exhaustive function. A naïve expansion
  function (see Section 3.5 and 5.4) that only acts on positive information
  would only report `_` as the missing pattern for `f`. Hence our
  implementation splits the uncovered set into (possibly multiple) subsets
  which have positive information (e.g. `x = True` rather than `x /= False`),
  approximating the representation of GMTM for error reporting. As a result,
  LYG (as GMTM) reports that `False` is not covered in `f`:

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
* `Ex7_1_1.hs`: This contains a variant of `v` (from `Ex2_3.hs`) that has its
  redundant `v (SJust _) = 1` equation removed. Compiling this file with the
  LYG version of GHC will produce no warnings, as expected, but compiling it
  with GHC 8.6.5 (which implements GMTM) will erroneously produce a warning:

  ```
  # /opt/ghc/8.6.5/bin/ghc Ex7_1_1.hs
  [1 of 1] Compiling Ex7_1_1          ( Ex7_1_1.hs, Ex7_1_1.o )

  Ex7_1_1.hs:8:1: warning: [-Wincomplete-patterns]
      Pattern match(es) are non-exhaustive
      In an equation for `v': Patterns not matched: (SJust _)
    |
  8 | v SNothing  = 0
    | ^^^^^^^^^^^^^^^
  ```

  Note that you need to use GHC 8.6.5 (not 8.8.3) here, since 8.8.3 implements
  an ad hoc form of inhabitation testing for data types with strict fields, so
  8.8.3 will not produce any warnings either.
* `Ex7_1_2.hs`: This contains `safeLast2`, a variant of `safeLast` (from
  `Ex2_2_1.hs`). Because both pattern guards in `safeLast2` scrutinise the same
  expression (`reverse xs`), the LYG version of GHC is able to conclude that
  `safeLast2` is exhaustive, so it will produce no warnings. On the other hand,
  compiling this file with 8.6.5 or 8.8.3 (which implement GMTM) will
  erroneously produce a warning:

  ```
  # /opt/ghc/8.8.3/bin/ghc Ex7_1_2.hs
  [1 of 1] Compiling Ex7_1_2          ( Ex7_1_2.hs, Ex7_1_2.o )

  Ex7_1_2.hs:5:1: warning: [-Wincomplete-patterns]
      Pattern match(es) are non-exhaustive
      In an equation for `safeLast2': Patterns not matched: _
    |
  5 | safeLast2 xs
    | ^^^^^^^^^^^^...
  ```
* `Ex7_3.hs`: This contains two examples from Section 7.3:
  * The `f` function matches on `False`, `True'`, and `True`. Here, `False`
    and `True` are ordindary data constructors, while `True'` is a pattern
    synonym. Moreover, `True'` and `False` are in the same `COMPLETE` set. The
    `f` function matches on both `True'` and `False`, so LYG is able to recognise
    that the third equation (`f True = 3`) is redundant:

    ```
    # ghc Ex7_3.hs
    [1 of 1] Compiling Ex7_3            ( Ex7_3.hs, Ex7_3.o )

    Ex7_3.hs:12:1: warning: [-Woverlapping-patterns]
        Pattern match is redundant
        In an equation for `f': f True = ...
       |
    12 | f True  = 3
       | ^^^^^^^^^^^

    <elided>
    ```

    GHC 8.6.5 and 8.8.3, on the other hand, implement GMTM, commit to the set
    `{True, False}` as soon as they match on `False`, which causes them to
    incorrectly report that the second equation (`f True' = 2`) is redundant:

    ```
    # /opt/ghc/8.8.3/bin/ghc Ex7_3.hs
    [1 of 1] Compiling Ex7_3            ( Ex7_3.hs, Ex7_3.o )

    Ex7_3.hs:11:1: warning: [-Woverlapping-patterns]
        Pattern match is redundant
        In an equation for `f': f True' = ...
       |
    11 | f True' = 2
       | ^^^^^^^^^^^

    <elided>
    ```
  * The `h` function demonstrates a crucial application of negative constraints
    in efficient coverage checking. Because of LYG's use of negative
    constraints, it is able to quickly recognize that `h` is non-exhaustive:

    ```
    # ghc Ex7_3.hs
    [1 of 1] Compiling Ex7_3            ( Ex7_3.hs, Ex7_3.o )

    <elided>

    Ex7_3.hs:15:1: warning: [-Wincomplete-patterns]
        Pattern match(es) are non-exhaustive
        In an equation for `h':
            Patterns not matched:
                A2 A2
                A2 A3
                A2 A4
                A2 A5
                ...
       |
    15 | h A1 _ = 1
       | ^^^^^^^^^^...
    ```

    GHC 8.6.5 and 8.8.3, on the other hand, implement GMTM, which only tracks
    positive information. As a result, using 8.6.5 or 8.8.3 to compile this
    file will do a lot of computation before eventually giving up trying to
    determine if `h` is exhaustive:

    ```
    # /opt/ghc/8.8.3/bin/ghc Ex7_3.hs
    [1 of 1] Compiling Ex7_3            ( Ex7_3.hs, Ex7_3.o )

    <elided>

    Ex7_3.hs:15:1: warning:
        Pattern match checker exceeded (2000000) iterations in
        an equation for `h'. (Use -fmax-pmcheck-iterations=n
        to set the maximum number of iterations to n)
       |
    15 | h A1 _ = 1
       | ^^^^^^^^^^...
    ```

Note that this directory only contains examples of Haskell code. Section 7.4,
which covers examples of OCaml and Idris code, are handled separately in the
`ocaml` and `idris` sections of this `Readme`, respectively.

# `ghc`

```
# cd /root/ghc/
# ls
CODEOWNERS   aclocal.m4      config.sub                                hadrian          mk
HACKING.md   appveyor.yml    configure                                 hie.yaml         nofib
INSTALL.md   autom4te.cache  configure.ac                              includes         packages
LICENSE      bindisttest     distrib                                   install-sh       rts
MAKEHELP.md  boot            docs                                      libffi           rules
Makefile     compiler        driver                                    libffi-tarballs  testsuite
README.md    config.guess    ghc                                       libraries        utils
Vagrantfile  config.log      ghc-8.11.0.20200227-x86_64-unknown-linux  llvm-passes      validate
_build       config.status   ghc.mk                                    llvm-targets
```

This is a checkout of GHC's source code at this commit:
https://gitlab.haskell.org/ghc/ghc/-/commit/59c023ba5ccb10fff62810591f20608bd73c97af
This is a snapshot of GHC that implements LYG as presented in the paper.

Note that the work that went into implementing LYG spans many commits, so
the best way to examine the code that powers LYG is to look at specific
modules. In particular, the `GHC.HsToCore.PmCheck` module (located at
`/root/ghc/compiler/GHC/HsToCore/PmCheck.hs`) in the entrypoint to GHC's
pattern-match coverage checker, and supporting modules can be found in
the `/root/ghc/compiler/GHC/HsToCore/PmCheck/` directory.

Here are some notable highlights of `GHC.HsToCore.PmCheck`:

* The `PmGrd` data type corresponds to Grd (defined in Figure 3) from the
  paper.
* The `GrdTree` and `AnnotatedTree` data types correspond to Gdt and Ant
  (defined in Figure 3), respectively, from the paper, which is what the
  graphical syntax in the paper describes.
* The `checkGrdTree` function corresponds to UA (defined in Figure 9) from
  the paper, which is the heart of the coverage-checking algorithm.

# `head-hackage-eval`

```
# cd /root/head-hackage-eval/
# ls
Cabal-2.4.1.0   gen-contents.sh       geniplate-mirror-0.7.6  pandoc-2.9.2       patched-deps
HsYAML-0.2.1.0  generic-data-0.8.1.0  network-3.1.1.1         pandoc-types-1.20
```

The `head-hackage-eval` directory contains the evaluation from the first part
of Section 6. It includes checkouts of the seven libraries from `head.hackage`
(`Cabal`, `HsYAML`, `generic-data`, `geniplate-mirror`, `network`, `pandoc`,
and `pandoc-types`) that we found to emit new warnings under the LYG version of
GHC that were not warned about in GHC 8.8.3.

This directory also contains the following build scripts and artifacts, neither
of which are of particular interest for the evaluation itself, but they are
included in case you wish to look at them:

* `gen-contents.sh` (a script used to download everything from Hackage and
  apply the relevant `head.hackage` patches)
* `patched-deps` (a directory containing library dependencies for the seven
  libraries above that also need `head.hackage` patches)

To reproduce the results from Section 6, enter one of the seven libraries'
checkout directories and run `cabal build`. This command is set up so that it
will build the library using the LYG version of GHC, and moreover, it will
throw an error when it encounters a new coverage checking related warning. For
example, you can reproduce the `HsYAML` warnings under LYG by doing the
following:

```
# cd /root/head-hackage-eval/HsYAML-0.2.1.0/
# cabal build
Build profile: -w ghc-8.11.0.20200227 -O1
In order, the following will be built (use -v for more details):
 - HsYAML-0.2.1.0 (lib) (first run)
Preprocessing library for HsYAML-0.2.1.0..
Building library for HsYAML-0.2.1.0..
<build output elided>
[ 8 of 14] Compiling Data.YAML.Event  ( src/Data/YAML/Event.hs, /root/head-hackage-eval/HsYAML-0.2.1.0/dist-newstyle/build/x86_64-linux/ghc-8.11.0.20200227/HsYAML-0.2.1.0/build/Data/YAML/Event.o, /root/head-hackage-eval/HsYAML-0.2.1.0/dist-newstyle/build/x86_64-linux/ghc-8.11.0.20200227/HsYAML-0.2.1.0/build/Data/YAML/Event.dyn_o )

src/Data/YAML/Event.hs:412:24: error: [-Woverlapping-patterns, -Werror=overlapping-patterns]
    Pattern match is redundant
    In an equation for go': go' _ _ _ xs | False = ...
    |
412 |         go' _ _ _ xs | False = error (show xs)
    |                        ^^^^^
```

You can also verify that this library does not emit this warning under GHC 8.8.3
by doing the following:

```
# cabal build --with-compiler /opt/ghc/8.8.3/bin/ghc
Resolving dependencies...
Build profile: -w ghc-8.8.3 -O1
In order, the following will be built (use -v for more details):
 - HsYAML-0.2.1.0 (lib) (first run)
Configuring library for HsYAML-0.2.1.0..
Preprocessing library for HsYAML-0.2.1.0..
Building library for HsYAML-0.2.1.0..
<build output elided, but this will ultimately succeed>
```

The same process can be repeated for the other six libraries in the
`head-hackage-eval` directory. Beware that `pandoc-2.9.2` in particular can
take a very long time to build. It can take about 20 minutes to build
everything including dependencies.

# `idris`

```
# cd /root/idris/
# ls
Ex7_4.idr
```

The `idris` directory contains `Ex7_4.idr`, which contains the Idris code from
Section 7.4:

* The `v` function is equivalent to its Haskell counterpart from Section 2.3.
* The `v'` function is a modified form of `v` that defines an equation for
  `Just`.
* The `f` function is equivalent to its Haskell counterpart from Section 3.7.

Note that because Idris has call-by-value runtime semantics, there is no need
to define a separate strict `SMaybe` data type, since the standard `Maybe` type
is already strict. Similarly, the `MkT` constructor in `Ex7_4.idr` will be
strict in its argument without the need to add a bang.

You can load `Ex7_4.idr` into the Idris REPL and check each function for
pattern-matching coverage by doing the following:

```
# idris --version
1.3.2
# idris Ex7_4.idr
     ____    __     _
    /  _/___/ /____(_)____
    / // __  / ___/ / ___/     Version 1.3.2
  _/ // /_/ / /  / (__  )      http://www.idris-lang.org/
 /___/\__,_/_/  /_/____/       Type :? for help

Idris is free software with ABSOLUTELY NO WARRANTY.
For details type :warranty.
Type checking ./Ex7_4.idr
Ex7_4.idr:22:1-13:
   |
22 | f Nothing = 0
   | ~~~~~~~~~~~~~
Ex7_4.f is not total as there are missing cases

*Ex7_4> :quit
```

Notes:

* The `v` function is exhaustive, since it does not include a redundant match
  on `Just`. Idris 1.3.2 behaves correctly by not producing a warning for `v`.
* The `v'` function includes a redundant match on `Just`, but Idris will not
  produce a warning for `v'`.
* The `f` function is exhaustive, since it does not include a redundant match
  on `Just`. Idris will nevertheless warn that `f` is not total
  (implying non-exhaustivity).

# `ocaml`

```
# cd /root/ocaml/
# ls
Ex7_4.ml
```

The `ocaml` directory contains `Ex7_4.ml`, which contains the OCaml code from
Section 7.4:

* The `v` function is equivalent to its Haskell counterpart from Section 2.3.
* The `v'` function is a modified form of `v` that defines an equation for
  `Some`.
* The `f` function is equivalent to its Haskell counterpart from Section 3.7.

Note that OCaml's `option` type is isomorphic to Haskell's `Maybe` type. Note
that because OCaml has call-by-value semantics, there is no need to define a
separate strict `soption` data type, since the standard `option` type is
already strict. Similarly, the `MkT` constructor in `Ex7_4.ml` will be
strict in its argument without the need to add a bang.

You can compile `Ex7_4.ml` and check each function for pattern-matching
coverage by doing the following:

```
# ocaml -version
The OCaml toplevel, version 4.10.0
# ocaml Ex7_4.ml
File "./Ex7_4.ml", line 8, characters 8-14:
8 |       | Some _  -> 1;;
            ^^^^^^
Warning 56: this match case is unreachable.
Consider replacing it with a refutation case '<pat> -> .'
File "./Ex7_4.ml", line 12, characters 6-33:
12 | let f (None : t option) : int = 0;;
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^
Warning 8: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched:
Some (MkT (MkT (MkT (MkT (MkT _)))))
```

Notes:

* The `v` function is exhaustive, since it does not include a redundant match
  on `Some`. OCaml 4.10.0 behaves correctly by not producing a warning for `v`.
* The `v'` function includes a redundant match on `Some`. OCaml will observe
  this and emit a warning stating that this case is unreachable.
* The `f` function is exhaustive, since it does not include a redundant match
  on `Just`. OCaml will nevertheless warn that `f` is not exhaustive.

# `perf-tets`

```
# cd /root/perf-tests/
# ls -alh
total 28K
drwxr-xr-x 1 root root 4.0K May 11 12:14 .
drwx------ 1 root root 4.0K May 11 15:20 ..
-rw-r--r-- 1 root root  646 May 10 02:54 PmSeriesS.hs
-rw-r--r-- 1 root root  610 May 10 02:54 PmSeriesT.hs
-rw-r--r-- 1 root root  481 May 10 02:54 PmSeriesV.hs
lrwxrwxrwx 1 root root   58 May 10 02:54 T11195.hs -> /root/ghc/testsuite/tests/pmcheck/should_compile/T11195.hs
lrwxrwxrwx 1 root root   58 May 10 02:54 T11276.hs -> /root/ghc/testsuite/tests/pmcheck/should_compile/T11276.hs
lrwxrwxrwx 1 root root   58 May 10 02:54 T11303.hs -> /root/ghc/testsuite/tests/pmcheck/should_compile/T11303.hs
lrwxrwxrwx 1 root root   59 May 10 02:54 T11303b.hs -> /root/ghc/testsuite/tests/pmcheck/should_compile/T11303b.hs
lrwxrwxrwx 1 root root   58 May 10 02:54 T11374.hs -> /root/ghc/testsuite/tests/pmcheck/should_compile/T11374.hs
lrwxrwxrwx 1 root root   58 May 10 02:54 T11822.hs -> /root/ghc/testsuite/tests/pmcheck/should_compile/T11822.hs
lrwxrwxrwx 1 root root   58 May 10 02:54 T17096.hs -> /root/ghc/testsuite/tests/pmcheck/should_compile/T17096.hs
-rwxrwxr-x 1 root root  190 May  9 21:01 bench-all.sh
-rwxrwxr-x 1 root root  377 May  9 20:58 bench.sh
```

The `perf-tests` directory contains each of the performance tests mentioned in
Figure 10 of Section 6.1. Each of the test cases beginning with `T-` are taken
directly from GHC's regression test suite, so we simply use symlinks to the
relevant parts of the GHC source code (in `/root/ghc`). The other three tests
(that begin with `PmSeries-`) are also taken from GHC's test suite by running
scripts that generate the files themselves. You can see how this was done by
inspecting the Dockerfile:

```
# Prepare /root/perf-tests directory
ENV GHC_PMCHECK_TESTDIR /root/ghc/testsuite/tests/pmcheck/should_compile
RUN mkdir /root/perf-tests
WORKDIR /root/perf-tests
RUN <elided> && \
    python3 ${GHC_PMCHECK_TESTDIR}/genS.py 10 && mv S.hs PmSeriesS.hs && \
    python3 ${GHC_PMCHECK_TESTDIR}/genT.py 10 && mv T.hs PmSeriesT.hs && \
    python3 ${GHC_PMCHECK_TESTDIR}/genV.py 6  && mv V.hs PmSeriesV.hs
```

Each of these performance tests were compiled with GHC 8.8.3 (which implements
GMTM) and the developmental version of GHC that implements LYG, comparing the
times it took to compile each file and the megabytes of allocation used during
compilation. To run an individual test, use the `bench.sh` script:

```
# ./bench.sh T11303
~~~~~ GHC 8.8.3 results ~~~~~
*** Chasing dependencies:
*** Parser [Main]:
*** Renamer/typechecker [Main]:
*** Desugar [Main]:
Desugar [Main]: alloc=60188712 time=31.412
*** Simplifier [Main]:
*** CoreTidy [Main]:
*** CorePrep [Main]:
*** CodeGen [Main]:
~~~~~ GHC-LYG results ~~~~~
*** initializing package database:
*** initializing package database:
*** Chasing dependencies:
*** Parser [Main]:
*** Renamer/typechecker [Main]:
*** Desugar [Main]:
Desugar [Main]: alloc=39875832 time=16.922
*** Simplifier [Main]:
*** CoreTidy [Main]:
*** CorePrep [Main]:
*** CodeGen [Main]:
*** systool:as:
*** systool:cc:
*** systool:cc:
*** systool:linker:
```

The relevant parts of this output are the two
`Desugar [Main]: alloc=<bytes> time=<milliseconds>` lines. (Note that the
Desugar pass is where pattern-match coverage checking occurs in GHC.)
The first occurrence of this line corresponds to GHC 8.8.3's results, and the
second occurrence corresponds to the LYG version of GHC's results. The numbers
in Figure 10 were taken from this script, albeit with some minor changes for
presentation purposes:

* GHC reports the number of bytes allocated, but Figure 10 presents megabytes
  instead.
* We round each of the numbers to three significant figures.

You can run all of the performance tests back to back by running
`./bench-all.sh`. Note that compared to Figure 10, minor variations in
allocation numbers (in the range of a few megabytes) are expected due to
differences in installed package databases. Also note that the difference in
compile times between 8.8.3 and LYG can vary, especially for quick-to-compile
test cases like `T11276`, where a difference of 1 millisecond can account for
a ~100% difference in total compile time.
