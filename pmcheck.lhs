% -*- mode: LaTeX -*-
%% For double-blind review submission, w/o CCS and ACM Reference (max submission space)
%\documentclass[acmsmall,review,anonymous,natbib=false]{acmart}\settopmatter{printfolios=true,printccs=false,printacmref=false}
%% For double-blind review submission, w/ CCS and ACM Reference
%\documentclass[acmsmall,review,anonymous]{acmart}\settopmatter{printfolios=true}
%% For single-blind review submission, w/o CCS and ACM Reference (max submission space)
%\documentclass[acmsmall,review]{acmart}\settopmatter{printfolios=true,printccs=false,printacmref=false}
%% For single-blind review submission, w/ CCS and ACM Reference
%\documentclass[acmsmall,review]{acmart}\settopmatter{printfolios=true}
%% For final camera-ready submission, w/ required CCS and ACM Reference
%\documentclass[acmsmall]{acmart}\settopmatter{}

\documentclass[acmsmall,review]{acmart}

%include custom.fmt

%% Journal information
%% Supplied to authors by publisher for camera-ready submission;
%% use defaults for review submission.
\acmJournal{PACMPL}
\acmVolume{1}
\acmNumber{ICFP} % CONF = POPL or ICFP or OOPSLA
\acmArticle{1}
\acmYear{2020}
\acmMonth{1}
\acmDOI{} % \acmDOI{10.1145/nnnnnnn.nnnnnnn}
\startPage{1}

%% Copyright information
%% Supplied to authors (based on authors' rights management selection;
%% see authors.acm.org) by publisher for camera-ready submission;
%% use 'none' for review submission.
\setcopyright{none}
%\setcopyright{acmcopyright}
%\setcopyright{acmlicensed}
%\setcopyright{rightsretained}
%\copyrightyear{2018}           %% If different from \acmYear

%% Bibliography style
\bibliographystyle{ACM-Reference-Format}
%% Citation style
%% Note: author/year citations are required for papers published as an
%% issue of PACMPL.
\citestyle{acmauthoryear}   %% For author/year citations

%%%%%%%
\usepackage{todonotes}
\usepackage{verbatim}  % for multiline comments
\usepackage{wasysym}   % for \checked
\usepackage{amssymb}   % for beautiful empty set

\usepackage{prooftree} % For derivation trees
\usepackage{stackengine} % For linebraks in derivation tree premises
\stackMath
\usepackage[edges]{forest} % For guard trees
\usepackage{tikz}
\usetikzlibrary{arrows,decorations.pathmorphing,shapes}

\PassOptionsToPackage{table}{xcolor} % for highlight
\usepackage{pgf}
\usepackage[T1]{fontenc}   % for textsc in headings

% For strange matrices
\usepackage{array}
\usepackage{multirow}
\usepackage{multicol}

\usepackage{xspace}

\usepackage{float}
\floatstyle{boxed}
\restylefloat{figure}

\usepackage{hyperref}
\usepackage{cleveref}

\input{macros}

\usepackage[labelfont=bf]{caption}

\clubpenalty = 10000
\widowpenalty = 10000
\displaywidowpenalty = 10000

% Tables should have the caption above
\floatstyle{plaintop}
\restylefloat{table}

\begin{document}

\special{papersize=8.5in,11in}
\setlength{\pdfpageheight}{\paperheight}
\setlength{\pdfpagewidth}{\paperwidth}

\title{Lower Your Guards}
\subtitle{A Compositional Pattern-Match Coverage Checker}

\author{Sebastian Graf}
\affiliation{%
  \institution{Karlsruhe Institute of Technology}
  \city{Karlsruhe}
  \country{Germany}
}
\email{sebastian.graf@@kit.edu}

\author{Simon Peyton Jones}
\affiliation{%
  \institution{Microsoft Research}
  \city{Cambridge}
  \country{UK}
}
\email{simonpj@@microsoft.com}

\author{Ryan G. Scott}
\affiliation{%
  \institution{Indiana University}
  \city{Bloomington, Indiana}
  \country{USA}
}
\email{rgscott@@indiana.edu}

\begin{abstract}
One of a compiler's roles is to warn if a function defined by pattern matching
does not cover its inputs---that is, if there are missing or redundant
patterns. Generating such warnings accurately is difficult
for modern languages due to the myriad interaction of language features
when pattern matching. This is especially true in Haskell, a language with
a complicated pattern language that is made even more complicated by extensions
offered by the Glasgow Haskell Compiler (GHC). Although GHC has spent a
significant amount of effort towards improving its
pattern-match coverage warnings, there are still several cases where
it reports inaccurate warnings.

We introduce a coverage checking algorithm called Lower Your Guards,
which boils down the complexities of pattern matching into \emph{guard trees}.
While the source language may have many exotic forms of patterns, guard
trees only have three different constructs, which vastly simplifies the
coverage checking process. Our algorithm is modular, allowing for new forms
of source-language patterns to be handled with little changes to the overall
structure of the algorithm. We have implemented the algorithm in GHC and
demonstrate places where it performs better than GHC's current coverage
checker, both in accuracy and performance.
\end{abstract}

\maketitle

%% 2012 ACM Computing Classification System (CSS) concepts
%% Generate at 'http://dl.acm.org/ccs/ccs.cfm'.
\begin{CCSXML}
<ccs2012>
<concept>
<concept_id>10011007.10011006.10011041</concept_id>
<concept_desc>Software and its engineering~Compilers</concept_desc>
<concept_significance>500</concept_significance>
</concept>
<concept>
<concept_id>10011007.10011006.10011008.10011009.10011012</concept_id>
<concept_desc>Software and its engineering~Functional languages</concept_desc>
<concept_significance>300</concept_significance>
</concept>
<concept>
<concept_id>10011007.10011006.10011008.10011024.10011035</concept_id>
<concept_desc>Software and its engineering~Procedures, functions and subroutines</concept_desc>
<concept_significance>300</concept_significance>
</concept>
</ccs2012>
\end{CCSXML}

\ccsdesc[500]{Software and its engineering~Compilers}
\ccsdesc[300]{Software and its engineering~Functional languages}
\ccsdesc[300]{Software and its engineering~Procedures, functions and subroutines}
%% End of generated code


%% Keywords
%% comma separated list
\keywords{Haskell, pattern matching, Generalized Algebraic Data Types, \OutsideIn{X}}  %% \keywords are mandatory in final camera-ready submission

\section{Introduction}

Pattern matching is a tremendously useful feature in Haskell and many other
programming languages, but it must be wielded with care. Consider the following
example of pattern matching gone wrong:

\begin{code}
f :: Int -> Bool
f 0 = True
f 0 = False
\end{code}

The |f| function exhibits two serious flaws. One obvious issue is that there
are two clauses that match on |0|, and due to the top-to-bottom semantics of
pattern matching, this makes the |f 0 = False| clause completely unreachable.
Even worse is that |f| never matches on any patterns besides |0|, making it not fully
defined. Attempting to invoke |f 1|, for instance, will fail.

To avoid these mishaps, compilers for languages with pattern matching often
emit warnings whenever a programmer misuses patterns. Such warnings indicate
if a function is missing clauses (i.e., if it is \emph{non-exhaustive}), if
a function has completely overlapping clauses (i.e., if it is \emph{redundant}),
or if a function has a right-hand side that cannot be reached (i.e., if it is
\emph{inaccessible}).
We refer
to the combination of checking for exhaustivity, redundancy, and accessibility as
\emph{pattern-match coverage checking}. Coverage checking is the first line
of defence in catching programmer mistakes when defining code that uses
pattern matching.

Coverage checking for a set of equations matching on algebraic data
types is a well studied (although still surprisingly tricky) problem---see
\Cref{sec:related} for this related work.
But the coverage-checking problem becomes \emph{much} harder when one includes the
raft of innovations that have become part of a modern programming language
like Haskell, including: view patterns, pattern guards, pattern synonyms,
overloaded literals, bang patterns, lazy patterns, as-patterns, strict data contructors,
empty case expressions, and long-distance effects (\Cref{ssec:ldi}).
Particularly tricky are GADTs \cite{recdatac}, where the \emph{type} of a match can determine
what \emph{values} can possibly appear; and local type-equality constraints brought into
scope by pattern matching \cite{outsideinx}.

% If coverage checking catches mistakes in pattern matches, then who checks for
% mistakes in the coverage checker itself? It is a surprisingly frequent
% occurrence for coverage checkers to contain bugs that impact correctness.
% This is especially true in Haskell, which has a rich pattern language, and the
% Glasgow Haskell Compiler (GHC) complicates the story further by adding
% pattern-related language extensions. Designing a coverage checker that can cope
% with all of these features is no small task.

The current state of the art for coverage checking in a richer language of this sort
is GADTs Meet Their Match \cite{gadtpm}, or \gmtm{} for short.
It presents an algorithm that handles the intricacies of
checking GADTs, lazy patterns, and pattern guards. We argue that this
algorithm is insufficient in a number of key ways. It does not account for a number of
important language features and even gives incorrect results in certain cases.
Moreover, the implementation of this algorithm in GHC is inefficient and has
proved to be difficult to maintain due to its complexity.

In this paper we propose a new, compositional coverage-checking algorithm, called Lower Your Guards (\sysname), that
is much simpler, more modular, \emph{and} more powerful than \gmtm.
We make the
following contributions:

\begin{itemize}
\item
  We characterise the nuances of coverage checking that not even the
  algorithm in \citet{gadtpm} handles (\Cref{sec:problem}). We also identify issues in GHC's
  implementation of this algorithm.

\item
  We give an overview of our new algorithm \sysname{} in \Cref{sec:overview}.
  The key insight is to abandon the notion of structural pattern
  matching altogether, and instead desugar all
  the complexities of pattern matching into a very simple language
  of \emph{guard trees}, with just three constructs (\Cref{sec:desugar}).
  Coverage checking on these guard trees becomes remarkably simple,
  returning an \emph{annotated tree} (\Cref{sec:check}) decorated with
  \emph{refinement types}.
  Finally, provided we have access to a suitable way to find inhabitants
  of a refinement type, we can report accurate coverage errors (\Cref{sec:inhabitants}).

\item
  We shore up the intuitions of \Cref{sec:overview} with a formal treatment in
  \Cref{sec:formalism}.

\item
  We demonstrate the compositionality of \sysname in \Cref{sec:impl} by augmenting it with
  several language extensions. Although these extensions can change the source
  language in significant ways, the effort needed to incorporate them into the
  algorithm is comparatively small.

\item
  We discuss how to optimize the performance of \sysname (\Cref{sec:impl}) and
  implement a proof of concept in GHC (\Cref{sec:eval}).
\end{itemize}

We discuss the wealth of related work in \Cref{sec:related}.

% Contributions from our call:
% \begin{itemize}
% \item Things we do that weren't done in GADTs meet their match
%   \begin{itemize}
%     \item Strictness, including bang patterns, data structures with strict fields.
% \item 	COMPLETE pragmas
% \item	Newtype pattern matching
% \item	..anything else?
% \item	Less syntactic; robust to mixing pattern guards and syntax pattern matching and view patterns
% \end{itemize}
%
%   \item
% Much simpler and more modular formalism (evidence: compare the Figures; separation of desugaring and clause-tree processing, so that it's easy to add new source-language forms)
% \item 	Leading to a simpler, more correct, and much more performant implementation.  (Evidence: GHC's bug tracker, perf numbers)
% \item 	Maybe the first to handle both strict and lazy languages.
%
% \end{itemize}


\section{The problem we want to solve} \label{sec:problem}

What makes coverage checking so difficult in a language like Haskell? At first
glance, implementing a coverage checking algorithm might appear simple: just
check that every function matches on every possible combination of data
constructors exactly once. A function must match on every possible combination
of constructors in order to be exhaustive, and it must must on them exactly
once to avoid redundant matches.

This algorithm, while concise, leaves out many nuances. What constitutes a
``match''? Haskell has multiple matching constructs, including function definitions,
|case| expressions, and guards. How does one count the
number of possible combinations of data constructors? This is not a simple exercise
since term and type constraints can make some combinations of constructors
unreachable if matched on. Moreover, what constitutes a ``data constructor''?
In addition to traditional data constructors, GHC features \emph{pattern synonyms}
~\cite{patsyns},
which provide an abstract way to embed arbitrary computation into patterns.
Matching on a pattern synonym is syntactically identical to matching on a data
constructor, which makes coverage checking in the presence of pattern synonyms
challenging.

Prior work on coverage checking (which we will expound upon further in
\Cref{sec:related}) accounts for some of these nuances, but
not all of them. In this section we identify all of the language features that
complicate coverage checking. While these features may seem disparate at first,
we will later show in \Cref{sec:formalism} that these ideas can all fit
into a unified framework.

\subsection{Guards}

Guards are a flexible form of control flow in Haskell. Here is a function that
demonstrates various capabilities of guards:

\begin{code}
guardDemo :: Char -> Char -> Int
guardDemo c1 c2
  | c1 == 'a'                            = 0
  | 'b' <- c1                            = 1
  | let c1' = c1, 'c' <- c1', c2 == 'd'  = 2
  | otherwise                            = 3
\end{code}

The first guard is a \emph{boolean guard} that succeeds
(i.e., evaluates its right-hand side) if
the expression in the guard returns |True|. The second guard is a \emph{pattern
guard} that succeeds if the pattern in the guard
successfully matches.
Moreover, a guard can have |let| bindings or even
multiple checks, as the third guard demonstrates. The fourth guard
uses |otherwise|, which is simply defined as |True|.

Guards can be thought of as a generalization of patterns, and we would like to
include them as part of coverage checking. Checking guards is significantly more
complicated than checking ordinary pattern matches, however, since guards can
contain arbitrary expressions. Consider this implementation of the |signum|
function:

\begin{code}
signum :: Int -> Int
signum x  | x > 0   = 1
          | x == 0  = 0
          | x < 0   = -1
\end{code}

Intuitively, |signum| is exhaustive since the combination of |(>)|, |(==)|, and
|(<)| covers all possible |Int|s. This is much harder for a machine to check,
however, since that would require knowledge about the properties of |Int|
inequalities. In fact, coverage checking for guards in the general case is an
undecidable problem. While we cannot accurately check \emph{all} uses of guards,
we can at least give decent warnings for some common use cases for guards.
For instance, take the following functions:
\begin{minipage}{\textwidth}
\begin{minipage}{0.33\textwidth}
\centering
\begin{code}
not :: Bool -> Bool
not b  | False <- b  = True
       | True <- b   = False
\end{code}
\end{minipage}
\begin{minipage}{0.33\textwidth}
\centering
\begin{code}
not2 :: Bool -> Bool
not2 False = True
not2 True = False
\end{code}
\end{minipage}
\begin{minipage}{0.33\textwidth}
\centering
\begin{code}
not3 :: Bool -> Bool
not3 x | x <- False  = True
not3 True            = False
\end{code}
\end{minipage}
\end{minipage}

Clearly all are equivalent.  Our coverage checking algorithm should find that all three
are exhaustive, and indeed, \sysname does so. We explore the subset of guards that
\sysname can check in more detail in \ryan{Cite relevant section}.

\subsection{Programmable patterns}

Expressions in guards are far from the only source of undecidability that the
coverage checker must cope with. GHC extends the pattern language in ways
that are also impossible to check in the general case.
We consider two such extensions here: view patterns and pattern synonyms.

% \subsubsection{Overloaded literals}
%
% Numeric literals in Haskell can be used at multiple types by virtue of being
% overloaded. For example, the literal |0|, when used as an expression, has
% |Num a => a| as its most general type. The |Num| class, in turn, has instances
% for |Int|, |Double|, and many other numeric data types, allowing |0|
% to inhabit those types with little fuss.
%
% In addition to their role as expressions, overloaded literals can also be used
% as patterns. The |isZero| function below, for instance, can check whether any
% numeric value is equal to zero:
%
% \begin{code}
% isZero :: (Eq a, Num a) => a -> Bool
% isZero 0 = True
% isZero n = False
% \end{code}
%
% Why does |isZero| require an |Eq| constraint on top of a |Num| constraint? This
% is because when compiled, overloaded literal patterns essentially desugar to
% guards. As one example, |isZero| can be rewritten to use guards like so:
%
% \begin{code}
% isZero :: (Eq a, Num a) => a -> Bool
% isZero n | n == 0 = True
% isZero n = False
% \end{code}
%
% Desugaring overloaded literal patterns to guards directly like this is perhaps
% not always desirable, however, since that can make the coverage checker's job
% more difficult.
% \sg{Fun fact: I think this desugaring + GVN from \cref{ssec:extviewpat} would
% be enough to handle this desugaring of overloaded literals. I think it's still
% worthwhile to handle them similarly to PatSyns for efficiency and similarity
% reasons. But it renders the point we are trying to make here somewhat moot.}
% For instance, if the |isZero n = False| clause were omitted,
% concluding that |isZero| is non-exhaustive would require reasoning about
% properties of the |Eq| and |Num| classes. For this reason, it can be worthwhile
% to have special checking treatment for common numeric types such as |Int| or
% |Double|. In general, however, coverage checking patterns with overloaded
% literals is undecidable.

\subsubsection{View patterns}
\label{sssec:viewpat}

View patterns allow arbitrary computation to be performed while pattern
matching. When a value |v| is matched against a view pattern |f -> p|, the
match is successful when |f v| successfully matches against the pattern |p|.
For example, one can use view patterns to succintly define a function that
computes the length of Haskell's opaque |Text| data type:

\begin{code}
Text.null :: Text -> Bool
  -- Checks if a Text is empty
Text.uncons :: Text -> Maybe (Char, Text)
  -- If a Text is non-empty, return Just (x, xs),
  -- where x is the first character and xs is the rest of the Text

length :: Text -> Int
length (Text.null -> True)            = 0
length (Text.uncons -> Just (_, xs))  = 1 + length xs
\end{code}

% View patterns can be thought of as a generalization of overloaded literals. For
% example, the |isZero| function in \ryan{cite section} can be rewritten to
% use view patterns like so:
%
% \begin{code}
% isZero :: (Eq a, Num a) => a -> Bool
% isZero ((==) 0 -> True) = True
% isZero n = False
% \end{code}

When compiled, a view pattern desugars into a pattern guard. The desugared version
of |length|, for instance, would look like this:

\begin{code}
length' :: Text -> Int
length' t  | True <- Text.null t            = True
           | Just (_, xs) <- Text.uncons t  = False
\end{code}

As a result, any coverage-checking algorithm that can handle guards can also
handle view patterns, provided that the view patterns desugar to guards that
are not too complex. For instance, \sysname would not be
able to conclude that |length| is exhaustive, but it would be able to conclude
that the |safeLast| function below is exhaustive:

\begin{code}
safeLast :: [a] -> Maybe a
safeLast (reverse -> [])       = Nothing
safeLast (reverse -> (x : _))  = Just x
\end{code}

\subsubsection{Pattern synonyms}
\label{ssec:patsyn}

Pattern synonyms~\cite{patsyns} allow abstraction over patterns themselves.
Pattern synonyms and view patterns can be useful in tandem, as the pattern
synonym can present an abstract interface to a view pattern that does
complicated things under the hood. For example, one can define
|length| with pattern synonyms like so:

\begin{minipage}{\textwidth}
\begin{minipage}[t]{0.55\textwidth}
\begin{code}
pattern Nil :: Text
pattern Nil <- (Text.null -> True)
pattern Cons :: Char -> Text -> Text
pattern Cons x xs <- (Text.uncons -> Just (x, xs))
\end{code}
\end{minipage}%
\begin{minipage}[t]{0.3\textwidth}
\begin{code}
length :: Text -> Int
length Nil = 0
length (Cons x xs) = 1 + length xs
\end{code}
\end{minipage}
\end{minipage}

How should a coverage checker handle pattern synonyms? One idea is to simply look
through the definitions of each pattern synonym and verify whether the underlying
patterns are exhaustive. This would be undesirable, however, because (1) we would
like to avoid leaking the implementation details of abstract pattern synonyms, and
(2) even if we \emph{did} look at the underlying implementation, it would be
challenging to automatically check that the combination of |Text.null| and
|Text.uncons| is exhaustive.

Intuitively, |Text.null| and |Text.uncons| together are exhaustive. GHC allows
programmers to communicate this sort of intuition to the coverage checker in the
form of \extension{COMPLETE} sets
\footnote{\url{https://downloads.haskell.org/~ghc/8.8.3/docs/html/users\_guide/glasgow\_exts.html\#pragma-COMPLETE}}
.
A \extension{COMPLETE} set is a combination of data constructors
and pattern synonyms that should be regarded as exhaustive when a function matches
on all of them.
For example, declaring \texttt{\{-\# COMPLETE Nil, Cons \#-\}} is sufficient to make
the definition of |length| above compile without any exhaustivity warnings.
Since GHC does not (and cannot, in general) check that all of the members of
a \extension{COMPLETE} set actually comprise a complete set of patterns, the burden is on
the programmer to ensure that this invariant is upheld.

\subsection{Strictness}
\label{ssec:strictness}

The evaluation order of pattern matching can impact whether a pattern is
reachable or not. While Haskell is a lazy language, programmers can opt
into extra strict evaluation by giving the fields of a data type strict fields,
such as in this example:

\begin{code}
data Void -- No data constructors
data SMaybe a = SJust !!a | SNothing

v :: SMaybe Void -> Int
v SNothing = 0
\end{code}

The |SJust| constructor is strict in its field, and as a consequence,
evaluating |SJust| $\bot$ to weak-head normal form (WHNF) will diverge.
This has consequences when coverage checking functions that match on
|SMaybe| values, such as |v|. The definition of |v| is curious, since it appears
to omit a case for |SJust|. We could imagine adding one:

\begin{code}
v (SJust _) = 1
\end{code}

It turns out, however, that the RHS of this case can never be
reached. The only way to use |SJust| is to construct a value of type |SMaybe Void|
is |SJust| $\bot$, since |Void| has no data constructors. Because |SJust| is
strict in its field, matching on |SJust| will cause |SJust| $\bot$ to diverge,
since matching on a data constructor evaluates it to WHNF. As a result, there
is no argument one could pass to |v| to make it return |1|, which makes the
|SJust| case unreachable.

% Although \citet{gadtpm} incorporates strictness constraints into their algorithm,
% it does not consider constraints that arise from strict fields.

\subsubsection{Bang patterns}

Strict fields are the primary mechanism for adding extra strictness in ordinary Haskell, but
GHC adds another mechanism in the form of \emph{bang patterns}. A bang pattern
such as |!pat| indicates that matching against |pat| always evaluates it to
WHNF. While data constructor matches are normally the only patterns that match
strictly, bang patterns extend this treatment to other patterns. For example,
one can rewrite the earlier |v| example to use the standard, lazy |Maybe| data
type:

\begin{code}
v' :: Maybe Void -> Int
v' Nothing = 0
v' (Just !_) = 1
\end{code}

The |Just| case in |v'| is unreachable for the same reasons that the |SJust| case in
|v| is unreachable. Due to the presence of bang patterns, a strictness-aware coverage-checking
algorithm must be consider the effects of strictness on any possible pattern,
not just those arising from matching on data constructors with strict fields.

\subsection{Type-equality constraints}

Besides strictness, another way for pattern matches to be rendered unreachable
is by way of \emph{equality constraints}. A popular method for introducing
equalities between types is matching on GADTs \cite{recdatac}. The following examples
demonstrate the interaction between GADTs and coverage checking:

\begin{minipage}{\textwidth}
\begin{minipage}[t]{0.3\textwidth}
\begin{code}
data T a b where
  T1 :: T Int  Bool
  T2 :: T Char Bool
\end{code}
\end{minipage}%
\begin{minipage}[t]{0.3\textwidth}
\begin{code}
g1 :: T Int b -> b -> Int
g1 T1 False = 0
g1 T1 True  = 1
\end{code}
\end{minipage}%
\begin{minipage}[t]{0.3\textwidth}
\begin{code}
g2 :: T a b -> T a b -> Int
g2 T1 T1 = 0
g2 T2 T2 = 1
\end{code}
\end{minipage}
\end{minipage}

When |g1| matches against |T1|, the |b| in the type |T Int b| is known to be a |Bool|,
which is why matching the second argument against |False| or |True| will typecheck.
Phrased differently, matching against
|T1| brings into scope an \emph{equality constraint} between the types
|b| and |Bool|. GHC has a powerful type inference engine that is equipped to
reason about type equalities of this sort \cite{outsideinx}.

Just as important as the code used in the |g1| function is the code that is
\emph{not} used in |g1|. One might wonder if |g1| not matching its first argument against
|T2| is an oversight. In fact, the exact opposite is true: matching
on |T2| would be rejected by the typechecker. This is because |T2|
is of type |T Char Bool|, but the first argument to |g1| must be of type |T Int b|.
Matching against |T2| would be tantamount to saying that |Int| and |Char|
are the same type, which is not the case. As a result, |g1| is exhaustive
even though it does not match on all of |T|'s data constructors.

The presence of type equalities is not always as clear-cut as it is in |g1|.
Consider the more complex |g2| function, which matches on two arguments of
the type |T a b|. While matching the arguments against |T1 T1| or |T2 T2| is possible,
it is not possible to match against |T1 T2| or |T2 T1|. To see why, suppose the first argument
is matched against |T1|, giving rise to an equality between |a| and |Int|. If the second
argument were then matched against |T2|, we would have that |a| equals |Char|.
By the transitivity of type equality, we would have that |Int| equals |Char|.
This cannot be true, so matching against |T1 T2| is impossible (and similarly
for |T2 T1|).

Concluding that |g2| is exhaustive requires some non-trivial reasoning about
equality constraints. In GHC, the same engine that typechecks GADT pattern matches is
also used to rule out cases made unreachable by type equalities.
Besides GHC's current coverage checker \cite{gadtpm}, there are a variety of
other coverage checking algorithms that account for GADTs,
including those for OCaml \cite{ocamlgadts},
Dependent ML \cite{deadcodexi,xithesis,dependentxi}, and
Stardust \cite{dunfieldthesis}.
\sysname continues this tradition---see
\ryan{What section?} for \sysname's take on GADTs.

\begin{figure}
\centering
\begin{verbatim}
\end{verbatim}
\[
\begin{array}{cc}
\textbf{Meta variables} & \textbf{Pattern Syntax} \\
\begin{array}{rl}
  x,y,z,f,g,h &\text{Term variables} \\
  a,b,c       &\text{Type variables} \\
  K           &\text{Data constructors} \\
  P           &\text{Pattern synonyms} \\
  T           &\text{Type constructors} \\
  l           &\text{Literal} \\
  expr        &\text{Expressions} \\
\end{array} &
\begin{array}{rcl}
  \mathit{defn}   &\Coloneqq& \overline{clause} \\
  clause &\Coloneqq&  f \; \overline{pat} \; \overline{match} \\
  pat    &\Coloneqq& x \mid |_| \mid K \; \overline{pat} \mid x|@|pat \mid |!|pat \mid expr \rightarrow pat \\
  match  &\Coloneqq& \mathtt{=} \; expr \mid \overline{grhs} \\
  grhs   &\Coloneqq& \mathtt{\mid} \; \overline{guard} \; \mathtt{=} \; expr \\
  guard  &\Coloneqq& pat \leftarrow expr \mid expr \mid \mathtt{let} \; x \; \mathtt{=} \; expr \\
\end{array}
\end{array}
\]

\caption{Source syntax}
\label{fig:srcsyn}
\end{figure}


\section{Overview of our solution}
\label{sec:overview}

\begin{figure}
\includegraphics{pipeline.pdf}
\caption{Bird's eye view of pattern match checking}
\label{fig:pipeline}
\end{figure}

\begin{figure}
\centering
\[ \textbf{Guard Syntax} \]
\[
\begin{array}{cc}
\begin{array}{rlcl}
  k,n,m       \in &\mathbb{N}&    & \\
  K           \in &\Con &         & \\
  x,y,a,b     \in &\Var &         & \\
  \tau,\sigma \in &\Type&         & \\
  e \in           &\Expr&\Coloneqq& x \\
                  &     &\mid     & \expconapp{K}{\tau}{\sigma}{\gamma}{e} \\
                  &     &\mid     & ... \\
\end{array} &
\begin{array}{rlcl}
  \gamma \in      &\TyCt&\Coloneqq& \tau_1 \typeeq \tau_2 \mid ... \\

  p \in           &\Pat &\Coloneqq& \_ \\
                  &     &\mid     & K \; \overline{p} \\
                  &     &\mid     & ... \\

  g \in           &\Grd &\Coloneqq& \grdlet{x:\tau}{e} \\
                  &     &\mid     & \grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x} \\
                  &     &\mid     & \grdbang{x} \\
\end{array}
\end{array}
\]
\[ \textbf{Constraint Formula Syntax} \]
\[
\begin{array}{rcll}
  \Gamma &\Coloneqq& \varnothing \mid \Gamma, x:\tau \mid \Gamma, a & \text{Context} \\
  \varphi &\Coloneqq& \true \mid \false \mid \ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x} \mid x \ntermeq K \mid x \termeq \bot \mid x \ntermeq \bot \mid \ctlet{x}{e} & \text{Literals} \\
  \Phi &\Coloneqq& \varphi \mid \Phi \wedge \Phi \mid \Phi \vee \Phi & \text{Formula} \\
  \Theta &\Coloneqq& \reft{\Gamma}{\Phi} & \text{Refinement Type} \\
  \delta &\Coloneqq& \gamma \mid x \termeq \deltaconapp{K}{a}{y} \mid x \ntermeq K \mid x \termeq \bot \mid x \ntermeq \bot \mid x \termeq y & \text{Constraints} \\
  \Delta &\Coloneqq& \varnothing \mid \Delta,\delta & \text{Set of constraints} \\
  \nabla &\Coloneqq& \false \mid \ctxt{\Gamma}{\Delta} & \text{Inert Set} \\
\end{array}
\]

\[ \textbf{Clause Tree Syntax} \]
\[
\begin{array}{rcll}
  t_G,u_G \in \Gdt &\Coloneqq& \gdtrhs{n} \mid \gdtseq{t_G}{u_G} \mid \gdtguard{g}{t_G}         \\
  t_A,u_A \in \Ant &\Coloneqq& \antrhs{n} \mid \antred{n} \mid \antseq{t_A}{u_A} \mid \antdiv{t_A} \\
\end{array}
\]

\caption{IR Syntax}
\label{fig:syn}
\end{figure}

In this section, we aim to provide an intuitive understanding of \sysname
by way of deriving the intermediate representations
of the pipeline step by step from motivating examples.

\Cref{fig:pipeline} depicts a high-level overview over this pipeline.
Desugaring the complex source Haskell syntax to the very elementary language of
guard trees $\Gdt$ via $\ds$ is an incredible simplification for the checking
process. At the same time, $\ds$ is the only transformation that is specific to
Haskell, implying easy applicability to other languages. The resulting guard
tree is then processed by two different functions, $\ann$ and $\unc$, which
compute redundancy information and uncovered patterns, respectively. $\ann$
boils down this information into an annotated tree $\Ant$, for which the set of
redundant and inaccessible right-hand sides can be computed in a final pass of
$\red$. $\unc$, on the other hand, returns a \emph{refinement type}
\cite{rushby1998subtypes,boundschecking}
representing
the set of \emph{uncovered values}, for which $\generate$ can generate the
inhabiting patterns to show to the user.

\subsection{Desugaring to guard trees} \label{sec:desugar}

\begin{figure}
\[
%TODO: Guard and MayDiverge should probably have an incoming edge (-|), but
%      then we have an overfull hbox.
\begin{array}{cc}
  \begin{array}{rcll}
    \vcenter{\hbox{\begin{forest}
      grdtree,
      for tree={delay={edge={-}}},
      [ [{$t_G$}] [{$u_G$}] ]
    \end{forest}}} & \Coloneqq & \gdtseq{t_G}{u_G} \\
    \vcenter{\hbox{\begin{forest}
      grdtree,
      for tree={delay={edge={-}}},
      [ {$g_1, ...\;, g_n$} [{$t_G$}] ]
    \end{forest}}} & \Coloneqq & \gdtguard{g_1}{...\; (\gdtguard{g_n}{t_G})} \\
    \vcenter{\hbox{\begin{forest}
      grdtree,
      [ [{$n$}] ]
    \end{forest}}} & \Coloneqq & \gdtrhs{n} \\
  \end{array}&
  \begin{array}{rcll}
    \vcenter{\hbox{\begin{forest}
      anttree,
      for tree={delay={edge={-}}},
      [ [{$t_A$}] [{$u_A$}] ]
    \end{forest}}} & \Coloneqq & \antseq{t_A}{u_A} \\
    \vcenter{\hbox{\begin{forest}
      anttree,
      for tree={delay={edge={-}}},
      [{\lightning} [{$t_A$}] ]
    \end{forest}}} & \Coloneqq & \antdiv{t_A} \\
    \vcenter{\hbox{\begin{forest}
      anttree,
      [ [{$n$},acc] ]
    \end{forest}}} & \Coloneqq & \antrhs{n} \\
    \vcenter{\hbox{\begin{forest}
      anttree,
      [ [{$n$},inacc] ]
    \end{forest}}} & \Coloneqq & \antred{n} \\
  \end{array}
\end{array}
\]

\caption{Graphical notation}
\label{fig:grphnot}
\end{figure}


To understand what language we should desugar to, consider the following 3am
attempt at lifting equality over \hs{Maybe}:

\begin{code}
liftEq Nothing  Nothing  = True
liftEq (Just x) (Just y)
  | x == y          = True
  | otherwise       = False
\end{code}
\noindent
Function definitions in Haskell allow one or more \emph{guarded right-hand
sides} (GRHS) per syntactic \emph{clause} (see \cref{fig:srcsyn}). For example,
|liftEq| has two clauses, the second of which defines two GRHSs. Semantically,
neither of them will match the call site |liftEq (Just 1) Nothing|, leading to
a crash.

To see that, we can follow Haskell's top-to-bottom, left-to-right pattern match
semantics. The first clause fails to match |Just 1| against |Nothing|, while
the second clause successfully matches |1| with |x| but then fails trying to
match |Nothing| against |Just y|. There is no third clause, and the
\emph{uncovered} tuple of values |(Just 1) Nothing| that falls out at the
bottom of this process will lead to a crash.

Compare that to matching on |(Just 1) (Just 2)|: While matching against the first
clause fails, the second matches |x| to |1| and |y| to |2|. Since there are
multiple GRHSs, each of them in turn has to be tried in a top-to-bottom
fashion. The first GRHS consists of a single boolean guard (in general we have
to consider each of them in a left-to-right fashion!) that will fail because |1
/= 2|. The second GRHS is tried next, and because |otherwise| is a
boolean guard that never fails, this successfully matches.

Note how both the pattern matching per clause and the guard checking within a
syntactic $match$ share top-to-bottom and left-to-right semantics. Having to
make sense of both pattern and guard semantics seems like a waste of energy.
Perhpas we can express all pattern matching by (nested) pattern guards, thus:
\begin{code}
liftEq mx my
  | Nothing <- mx, Nothing <- my              = True
  | Just x <- mx,  Just y <- my  | x == y     = True
                                 | otherwise  = False
\end{code}
Transforming the first clause with its single GRHS is easy. But the second
clause already has two GRHSs, so we need to use \emph{nested} pattern guards.
This is not a feature that Haskell offers (yet), but it allows a very
convenient uniformity for our purposes: after the successful match on the first
two guards left-to-right, we try to match each of the GRHSs in turn,
top-to-bottom (and their individual guards left-to-right).

Hence \sysname desugars the source syntax to the following \emph{guard
tree} (see \cref{fig:syn} for the full syntax and \cref{fig:grphnot} the
corresponding graphical notation):

\begin{forest}
  grdtree
  [
    [{$\grdbang{mx}, \grdcon{\mathtt{Nothing}}{mx}, \grdbang{my}, \grdcon{\mathtt{Nothing}}{my}$} [1]]
    [{$\grdbang{mx}, \grdcon{\mathtt{Just}\;x}{mx}, \grdbang{my}, \grdcon{\mathtt{Just}\;y}{my}$}
      [{$\grdlet{t}{|x == y|}, \grdbang{t}, \grdcon{\mathtt{True}}{t}$} [2]]
      [{$\grdbang{otherwise}, \grdcon{\mathtt{True}}{otherwise}$} [3]]]]
\end{forest}

This representation is quite a bit more explicit than the original program. For
one thing, every source-level pattern guard is strict in its scrutinee, whereas
the pattern guards in our tree language are not, so we had to insert \emph{bang
guards}. By analogy with bang patterns, |!x| evaluates $x$ to WHNF, which will
either succeed or diverge. Moreover, the pattern guards in $\Grd$ only
scrutinise variables (and only one level deep), so the comparison in the
boolean guard's scrutinee had to be bound to an auxiliary variable in a let
binding.

% \ryan{|otherwise| was introduced earlier, so commenting this out.}
% Note that |otherwise| is an external identifier which we can assume to
% be bound to |True|, which is in fact how it defined.

Pattern guards in $\Grd$ are the only guards that can possibly fail to match,
in which case the value of the scrutinee was not of the shape of the
constructor application it was matched against. The $\Gdt$ tree language
determines how to cope with a failed guard. Left-to-right matching semantics is
captured by $\gdtguard{}{\hspace{-0.6em}}$, whereas top-to-bottom backtracking
is expressed by sequence ($\gdtseq{}{}$). The leaves in a guard tree each
correspond to a GRHS.

\subsection{Checking guard trees} \label{sec:check}

Coverage checking works by gradually refining the set of reaching values
\ryan{Did you mean to write ``reachable values'' here? ``Reaching values''
reads strangely to me.}
\sg{I was thinking ``reaching values'' as in ``reaching definitions'': The set
of values that reach that particular piece of the guard tree.}
as they flow through the guard tree until it produces two outputs.
One output is the set of uncovered values that wasn't covered by any clause,
and the other output is an annotated guard tree skeleton
$\Ant$ with the same shape as the guard tree to check, capturing redundancy and
divergence information.

For the example of |liftEq|'s guard tree $t_|liftEq|$, we represent the set of
values reaching the first clause by the \emph{refinement type} $\reft{(mx :
|Maybe a|, my : |Maybe a|)}{\true}$ (which is a $\Theta$ from \cref{fig:syn}) .
This set is gradually refined until finally we have $\Theta_{|liftEq|} :=
\reft{(mx : |Maybe a|, my : |Maybe a|)}{\Phi}$ as the uncovered set, where the
predicate $\Phi$ is semantically equivalent to:
\[
\begin{array}{cl}
         & (mx \ntermeq \bot \wedge (mx \ntermeq \mathtt{Nothing} \vee (\ctcon{\mathtt{Nothing}}{mx} \wedge my \ntermeq \bot \wedge my \ntermeq \mathtt{Nothing}))) \\
  \wedge & (mx \ntermeq \bot \wedge (mx \ntermeq \mathtt{Just} \vee (\ctcon{\mathtt{Just}\;x}{mx} \wedge my \ntermeq \bot \wedge (my \ntermeq \mathtt{Just})))) \\
\end{array}
\]

Every $\vee$ disjunct corresponds to one way in which a pattern guard in the
tree could fail. It is not obvious at all for humans to read off inhbaitants
from this representation, but we will give an intuitive treatment of how
to do so in the next subsection.

The annotated guard tree skeleton corresponding to $t_|liftEq|$ looks like
this:

\begin{forest}
  anttree
  [
    [{\lightning}
      [1,acc]
      [{\lightning}
        [{\lightning} [2,acc]]
        [3,acc]]]]
\end{forest}

A GRHS is deemed accessible (\checked{}) whenever there is a non-empty set of
values reaching it. For the first GRHS, the set that reaches it looks
like $\{ (mx, my) \mid mx \ntermeq \bot, \grdcon{\mathtt{Nothing}}{mx}, my
\ntermeq \bot, \grdcon{\mathtt{Nothing}}{my} \}$, which is inhabited by
$(\mathtt{Nothing}, \mathtt{Nothing})$. Similarly, we can find inhabitants for
the other two clauses.

A \lightning{} denotes possible divergence in one of the bang guards and
involves testing the set of reaching values for compatibility with \ie $mx
\termeq \bot$. We cannot know in advance whether $mx$, $my$ or $t$ are
$\bot$ (hence the three uses of
\lightning{}), but we can certainly rule out $otherwise \termeq \bot$ simply by
knowing that it is defined as |True|. But since all GRHSs are accessible,
there is nothing to report in terms of redundancy and the \lightning{}
decorators are irrelevant.

Perhaps surprisingly and most importantly, $\Grd$ with its three primitive
guards, combined with left-to-right or top-to-bottom semantics in $\Gdt$, is
expressive enough to express all pattern matching in Haskell (cf. the
desugaring function $\ds$ in \cref{fig:desugar})! We have yet to find a
language extension that does not fit into this framework.

\subsubsection{Why do we not report redundant GRHSs directly?}

Why not compute the redundant GRHSs directly instead of building up a whole new
tree? Because determining inaccessibility \vs redundancy is a non-local
problem. Consider this example and its corresponding annotated tree after
checking:
\sg{I think this kind of detail should be motivated in a prior section and then
referenced here for its solution.}

\begin{minipage}{\textwidth}
\begin{minipage}{0.22\textwidth}
\centering
\begin{code}
g :: () -> Int
g ()   | False   = 1
       | True    = 2
g _              = 3
\end{code}
\end{minipage}%
\begin{minipage}{0.05\textwidth}
\centering
\[ \leadsto \]
\end{minipage}%
\begin{minipage}{0.2\textwidth}
\centering
\begin{forest}
  anttree
  [
    [{\lightning}
      [1,inacc]
      [2,acc]]
    [3,acc]]
\end{forest}
\end{minipage}
\end{minipage}

Is the first GRHS just inaccessible or even redundant? Although the match on
|()| forces the argument, we can delete the first GRHS without changing program
semantics, so clearly it is redundant.
But that wouldn't be true if the second GRHS wasn't there to ``keep alive'' the
|()| pattern!

In general, at least one GRHS under a \lightning{} may not be flagged as
redundant ($\times$).
Thus the checking algorithm can't decide which GRHSs are redundant (\vs just
inaccessible) when it reaches a particular GRHS.

\subsection{Generating inhabitants of a refinement type} \label{sec:inhabitants}

The predicate literals $\varphi$ of refinement types look quite similar to the
original $\Grd$ language, so how is checking them for emptiness an improvement
over reasoning about about guard trees directly? To appreciate the transition,
it is important to realise that semantics of $\Grd$s are \emph{highly
non-local}! Left-to-right and top-to-bottom match semantics means that it is
hard to view $\Grd$s in isolation; we always have to reason about whole
$\Gdt$s. By contrast, refinement types are self-contained, which means the
process of generating inhabitants can be treated separately from the process
of coverage checking.

Apart from generating inhabitants of the final uncovered set for non-exhaustive
match warnings, there are two points at which we have to check whether
a refinement type has become empty: To determine whether a right-hand side is
inaccessible and whether a particular bang guard may lead to divergence and
requires us to wrap a \lightning{}.

Take the final uncovered set $\Theta_{|liftEq|}$ after checking |liftEq| above
as an example. A bit of eyeballing |liftEq|'s definition reveals that |Nothing
(Just _)| is an uncovered pattern, but eyeballing the constraint formula of
$\Theta_{|liftEq|}$ seems impossible in comparison. A more systematic approach
is to adopt a generate-and-test scheme: Enumerate possible values of the data
types for each variable involved (the pattern variables |mx| and |my|, but also
possibly the guard-bound |x|, |y| and |t|) and test them for compatibility with
the recorded constraints.

Starting from |mx my|, we enumerate all possibilities for the shape of |mx|,
and similarly for |my|. The obvious first candidate in a lazy language is
$\bot$! But that is a contradicting assignment for both |mx| and |my|
indepedently. Refining to |Nothing Nothing| contradicts with the left part
of the top-level $\wedge$. Trying |Just y| (|y| fresh) instead as the shape for
|my| yields our first inhabitant! Note that |y| is unconstrained, so $\bot$ is
a trivial inhabitant. Similarly for |(Just _) Nothing| and |(Just _) (Just _)|.

Why do we have to test guard-bound variables in addition to the pattern
variables? It is because of empty data types and strict fields. For example,
|v| from \cref{ssec:strictness} does not have any uncovered patterns. And our
approach should see that by looking at its uncovered set $\reft{x : |Maybe
Void|}{x \ntermeq \bot \wedge x \ntermeq \mathtt{Nothing}}$. Specifically, the
candidate |SJust y| (for fresh |y|) for |x| should be rejected, because there
is no inhabitant for |y|! $\bot$ is ruled out by the strict field and |Void|
has no data constructors with which to instantiate |y|. Hence it is important
to test guard-bound variables for inhabitants, too.


\section{Formalism} \label{sec:formalism}

The previous section gave insights into how we represent coverage checking
problems as guard trees and provided an intuition for how to check them for
exhaustiveness and redundancy. This section formalises these intuitions in
terms of the syntax (\cf \cref{fig:syn}) we introduced earlier.

As in the previous section, we divide this section into three main parts:
desugaring, coverage checking, and finding inhabitants of the resulting
refinement types. The latter subtask proves challenging enough to warrant two
additional subsections.

\subsection{Desugaring to guard trees}

\begin{figure}

\[ \ruleform{ \ds(defn) = \Gdt, \ds(clause) = \Gdt, \ds(grhs) = \Gdt } \]
\[ \ruleform{ \ds(guard) = \overline{\Grd}, \ds(x, pat) = \overline{\Grd} } \]
\[
\begin{array}{lcl}

\ds(clause_1\,...\,clause_n) &=&
  \raisebox{3px}{\begin{forest}
    baseline,
    grdtree,
    grhs/.style={tier=rhs,edge={-}},
    [ [{$\ds(clause_1)$}] [...] [{$\ds(clause_n)$}] ] ]
  \end{forest}} \\
\\
\ds(f \; pat_1\,...\,pat_n \; \mathtt{=} \; expr) &=&
  \raisebox{3px}{\begin{forest}
    baseline,
    grdtree,
    [ [{$\ds(x_1, pat_1)\,...\,\ds(x_n, pat_n)$} [{$k$}] ] ]
  \end{forest}} \\
\ds(f \; pat_1\,...\,pat_n \; grhs_1\,...\,grhs_m) &=&
  \raisebox{3px}{\begin{forest}
    baseline,
    grdtree,
    grhs/.style={tier=rhs,edge={-}},
    [ [{$\ds(x_1, pat_1)\,...\,\ds(x_n, pat_n)$} [{$\ds(grhs_1)$}] [...] [{$\ds(grhs_m)$}] ] ]
  \end{forest}} \\
\\
\ds(\mathtt{\mid} \; guard_1\,...\,guard_n \; \mathtt{=} \; expr) &=&
  \raisebox{3px}{\begin{forest}
    baseline,
    grdtree,
    [ [{$\ds(guard_1)\,...\,\ds(guard_n)$} [{$k$}] ] ]
  \end{forest}} \\
\\
%TODO: Maybe make it explicit that we desugar to core here?
\ds(pat \leftarrow expr) &=& \grdlet{x}{expr}, \ds(x, pat) \\
\ds(expr) &=& \grdlet{b}{expr}, \ds(b, |True|) \\
\ds(\mathtt{let} \; x \; \mathtt{=} \; expr) &=& \grdlet{x}{expr} \\
\\
\ds(x, y) &=& \grdlet{y}{x} \\
\ds(x, |_|) &=& \epsilon \\
\ds(x, K \; pat_1\,...\,pat_n) &=& \grdbang{x}, \grdcon{K \; y_1\,...\,y_n}{x}, \ds(y_1, pat_1), ..., \ds(y_n, pat_n) \\
\ds(x, y|@|pat) &=& \grdlet{y}{x}, \ds(y, pat) \\
\ds(x, |!|pat) &=& \grdbang{x}, \ds(x, pat) \\
\ds(x, expr \rightarrow pat) &=& \grdlet{|y|}{expr \; x}, \ds(y, pat) \\
\end{array}
\]
\caption{Desugaring Haskell to $\Gdt$}
\label{fig:desugar}
\end{figure}

\Cref{fig:desugar} outlines the desugaring step from source Haskell to our
guard tree language $\Gdt$. It is assumed that the top-level match variables
$x_1$ through $x_n$ in the $clause$ cases have special, fixed names. All other
variables that aren't bound in arguments to $\ds$ have fresh names.

Consider this example function:

\begin{code}
f (Just (!xs,_))  ys@Nothing   = 1
f Nothing         (g -> True)  = 2
\end{code}

\noindent
Under $\ds$, this desugars to

\begin{forest}
  grdtree,
  [
    [{$\grdbang{x_1}, \grdcon{|Just t_1|}{x_1}, \grdbang{t_1}, \grdcon{(t_2, t_3)}{t_1}, \grdbang{t_2}, \grdlet{xs}{t_2}, \grdlet{ys}{x_2}, \grdbang{ys}, \grdcon{|Nothing|}{ys}$} [1]]
    [{$\grdbang{x_1}, \grdcon{|Nothing|}{x_1}, \grdlet{t_3}{|g x_2|}, \grdbang{y}, \grdcon{|True|}{t_3}$} [2]]]
\end{forest}

The definition of $\ds$ is straight-forward, but a little expansive because of
the realistic source language. Its most intricate job is keeping track of all
the renaming going on to resolve name mismatches. Other than that, the
desugaring follows from the restrictions on the $\Grd$ language, such as the
fact that source-level pattern guards also need to emit a bang guard on the
variable representing the scrutinee.

Note how our na{\"i}ve desugaring function generates an abundance of fresh
temporary variables. In practice, the implementation of $\ds$ can be smarter
than this by looking at the pattern (which might be a variable match or
|@|-pattern) when choosing a name for a variable.

\subsection{Checking guard trees}

\begin{figure}
\[ \textbf{Operations on $\Theta$} \]
\[
\begin{array}{lcl}
\reft{\Gamma}{\Phi} \andtheta \varphi &=& \reft{\Gamma}{\Phi \wedge \varphi} \\
\reft{\Gamma}{\Phi_1} \uniontheta \reft{\Gamma}{\Phi_2} &=& \reft{\Gamma}{\Phi_1 \vee \Phi_2} \\
\end{array}
\]

\[ \textbf{Checking Guard Trees} \]
\[ \ruleform{ \unc(\Theta, t_G) = \Theta } \]
\[
\begin{array}{lcl}
\unc(\reft{\Gamma}{\Phi}, \gdtrhs{n}) &=& \reft{\Gamma}{\false} \\
\unc(\Theta, \gdtseq{t}{u}) &=& \unc(\unc(\Theta, t), u) \\
\unc(\Theta, \gdtguard{(\grdbang{x})}{t}) &=& \unc(\Theta \andtheta (x \ntermeq \bot), t) \\
\unc(\Theta, \gdtguard{(\grdlet{x}{e})}{t}) &=& \unc(\Theta \andtheta (\ctlet{x}{e}), t) \\
\unc(\Theta, \gdtguard{(\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{t}) &=& (\Theta \andtheta (x \ntermeq K)) \uniontheta \unc(\Theta \andtheta (\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}), t) \\
\end{array}
\]
\[ \ruleform{ \ann(\Delta, t_G) = t_A } \]
\[
\begin{array}{lcl}
\ann(\Theta,\gdtrhs{n}) &=& \begin{cases}
    \antred{n}, & \generate(\Theta) = \emptyset \\
    \antrhs{n}, & \text{otherwise} \\
  \end{cases} \\
\ann(\Theta, (\gdtseq{t}{u})) &=& \antseq{\ann(\Theta, t)}{\ann(\unc(\Theta, t), u)} \\
\ann(\Theta, \gdtguard{(\grdbang{x})}{t}) &=& \begin{cases}
    \ann(\Theta \andtheta (x \ntermeq \bot), t), & \generate(\Theta \andtheta (x \termeq \bot)) = \emptyset \\
    \antdiv{\ann(\Theta \andtheta (x \ntermeq \bot), t)} & \text{otherwise} \\
  \end{cases} \\
\ann(\Theta, \gdtguard{(\grdlet{x}{e})}{t}) &=& \ann(\Theta \andtheta (\ctlet{x}{e}), t) \\
\ann(\Theta, \gdtguard{(\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{t}) &=& \ann(\Theta \andtheta (\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}), t) \\
\end{array}
\]
\[ \ruleform{ \red(t_A) = (\overline{k}, \overline{n}, \overline{m}) } \]
\[
\begin{array}{lcl}
\red(\antrhs{n}) &=& (n, \epsilon, \epsilon) \\
\red(\antred{n}) &=& (\epsilon, n, \epsilon) \\
\red(\antseq{t}{u}) &=& (\overline{k}\,\overline{k'}, \overline{n}\,\overline{n'}, \overline{m}\,\overline{m'}) \hspace{0.5em} \text{where} \begin{array}{l@@{\,}c@@{\,}l}
    (\overline{k}, \overline{n}, \overline{m}) &=& \red(t) \\
    (\overline{k'}, \overline{n'}, \overline{m'}) &=& \red(u) \\
  \end{array} \\
\red(\antdiv{t}) &=& \begin{cases}
    (\epsilon, m, \overline{m'}) & \text{if $\red(t) = (\epsilon, \epsilon, m\,\overline{m'})$} \\
    \red(t) & \text{otherwise} \\
  \end{cases} \\
\end{array}
\]

\caption{Coverage checking}
\label{fig:check}
\end{figure}

\Cref{fig:check} shows the two main functions for checking guard trees. $\unc$
carries out exhaustiveness checking by computing the set of uncovered values
for a particular guard tree, whereas $\ann$ computes the corresponding
annotated tree, capturing redundancy information. $\red$ extracts a triple of
accessible, inaccessible and redundant GRHS from such an annotated tree.

Both $\unc$ and $\ann$ take as their second parameter the set of values
\emph{reaching} the particular guard tree node. If no value reaches a
particular tree node, that node is inaccessible. The definition of $\unc$
follows the intuition we built up earlier: It refines the set of reaching
values as a subset of it falls through from one clause to the next. This is
most visible in the $\gdtseq{}{}$ case (top-to-bottom composition), where the
set of values reaching the right (or bottom) child is exactly the set of values
that were uncovered by the left (or top) child on the set of values reaching
the whole node. A GRHS covers every reaching value. The left-to-right semantics
of $\gdtguard{}{\hspace{-0.6em}}$ are respected by refining the set of values reaching the
wrapped subtree, depending on the particular guard. Bang guards and let
bindings don't do anything beyond that refinement, whereas pattern guards
additionally account for the possibility of a failed pattern match. Note that
a failing pattern guard is the \emph{only} way in which the uncovered set
can become non-empty!

When $\ann$ hits a GRHS, it asks $\generate$ for inhabitants of $\Theta$
to decide whether the GRHS is accessible or not. Since $\ann$ needs to compute
and maintain the set of reaching values just the same as $\unc$, it has to call
out to $\unc$ for the $\gdtseq{}{}$ case. Out of the three guard cases, the one
handling bang guards is the only one doing more than just refining the set of
reaching values for the subtree (thus respecting left-to-right semantics). A
bang guard $\grdbang{x}$ is handled by testing whether the set of reaching
values $\Theta$ is compatible with the assignment $x \termeq \bot$, which again
is done by asking $\generate$ for concrete inhabitants of the resulting
refinement type. If it \emph{is} inhabited, then the bang guard might diverge
and we need to wrap the annotated subtree in a \lightning{}.

Pattern guard semantics are important for $\unc$ and bang guard semantics are
important for $\ann$. But what about let bindings? They are in fact completely
uninteresting to the checking process, but making sense of them is important
for the precision of the emptiness check involving $\generate$. Of course,
``making sense'' of an expression is an open-ended endeavour, but we'll
see a few reasonable ways to improve precision considerably at almost no cost,
both in \cref{ssec:extinert} and \cref{ssec:extviewpat}.


\subsection{Generating inhabitants of a refinement type}
\label{ssec:gen}

\begin{figure}
\centering
\[ \textbf{Generate inhabitants of $\Theta$} \]
\[ \ruleform{ \generate(\Theta) = \mathcal{P}(\overline{p}) } \]
\[
\begin{array}{c}
   \generate(\reft{\Gamma}{\Phi}) = \left\{ \expand(\nabla, \mathsf{dom}(\Gamma)) \mid \nabla \in \construct(\ctxt{\Gamma}{\varnothing}, \Phi) \right\}
\end{array}
\]

\[ \textbf{Construct inhabited $\nabla$s from $\Phi$} \]
\[ \ruleform{ \construct(\nabla, \Phi) = \mathcal{P}(\nabla) } \]
\[
\begin{array}{lcl}

  \construct(\nabla, \varphi) &=& \begin{cases}
    \left\{ \ctxt{\Gamma'}{\Phi'} \right\} & \text{where $\ctxt{\Gamma'}{\Phi'} = \nabla \addphi \varphi$} \\
    \emptyset & \text{otherwise} \\
  \end{cases} \\
  \construct(\nabla, \Phi_1 \wedge \Phi_2) &=& \bigcup \left\{ \construct(\nabla', \Phi_2) \mid \nabla' \in \construct(\nabla, \Phi_1) \right\} \\
  \construct(\nabla, \Phi_1 \vee \Phi_2) &=& \construct(\nabla, \Phi_1) \cup \construct(\nabla, \Phi_2)

\end{array}
\]

\[ \textbf{Expand variables to $\Pat$ with $\nabla$} \]
\[ \ruleform{ \expand(\nabla, \overline{x}) = \overline{p} } \]
\[
\begin{array}{lcl}

  \expand(\nabla, \epsilon) &=& \epsilon \\
  \expand(\ctxt{\Gamma}{\Delta}, x_1 ... x_n) &=& \begin{cases}
    (K \; q_1 ... q_m) \, p_2 ... p_n & \parbox[t]{0.5\textwidth}{where $\rep{\Delta}{x} \termeq \deltaconapp{K}{a}{y} \in \Delta$\\ and $(q_1 ... q_m \, p_2 ... p_n) \in \expand(\ctxt{\Gamma}{\Delta}, y_1 ... y_m x_2 ... x_n)$} \\
    \_ \; p_2 ... p_n & \text{where $(p_2 ... p_n) \in \expand(\ctxt{\Gamma}{\Delta}, x_2 ... x_n)$} \\
  \end{cases} \\

\end{array}
\]

\[ \textbf{Finding the representative of a variable in $\Delta$} \]
\[ \ruleform{ \rep{\Delta}{x} = y } \]
\[
\begin{array}{lcl}
  \rep{\Delta}{x} &=& \begin{cases}
    \rep{\Delta}{y} & x \termeq y \in \Delta \\
    x & \text{otherwise} \\
  \end{cases} \\
\end{array}
\]


\caption{Generating inhabitants of $\Theta$ via $\nabla$}
\label{fig:gen}
\end{figure}

The key function for the emptiness test is $\generate$ in \cref{fig:gen}, which
generates a set of patterns which inhabit a given refinement type $\Theta$.
There might be multiple inhabitants, and $\construct$ will construct multiple
$\nabla$s, each representing at least one inhabiting assignment of the
refinement predicate $\Phi$. Each such assignment corresponds to a pattern
vector, so $\expand$ expands the assignments in a $\nabla$ into multiple
pattern vectors.

But what \emph{is} $\nabla$? It's a pair of a type context $\Gamma$ and a
$\Delta$, a set of mutually compatible constraints $\delta$, or a proven
incomatibility $\false$ between such a set of constraints. $\construct$ will
arrange it that every constructed $\nabla$ satisfies a number of
well-formedness constraints:

\begin{enumerate}
  \item[\inert{1}] \emph{Mutual compatibility}: No two constraints in $\nabla$
    should conflict with each other.
  \item[\inert{2}] \emph{Triangular form}: A $x \termeq y$ constraint implies
    absence of any other constraints mentioning |x| in its left-hand side.
  \item[\inert{3}] \emph{Single solution}: There is at most one positive
    constructor constraint $x \termeq \deltaconapp{K}{a}{y}$ for a given |x|.
\end{enumerate}

\noindent
We refer to such a $\nabla$ as an \emph{inert set}, in the sense that its
constraints are of canonical form and already checked for mutual compatibility
(\inert{1}), in analogy to a typechecker's implementation.

It is helpful at times to think of a $\Delta$ as a partial function from |x| to
its \emph{solution}, informed by the single positive constraint $x \termeq
\deltaconapp{K}{a}{y} \in \Delta$, if it exists. For example, $x \termeq
|Nothing|$ can be understood as a function mapping |x| to |Nothing|. This
reasoning is justified by \inert{3}. Under this view, $\Delta$ looks like a
substitution. As we'll see later in \cref{ssec:extinert}, this view is
supported by immense overlap with unification algorithms.

\inert{2} is actually a condition on the represented substitution. Whenever we
find out that $x \termeq y$, for example when matching a variable pattern |y|
against a match variable |x|, we have to merge all the other constraints on |x|
into |y| and say that |y| is the representative of |x|'s equivalence class.
This is so that every new constraint we record on |y| also affects |x| and vice
versa. The process of finding the solution of |x| in $x \termeq y, y \termeq
|Nothing|$ then entails \emph{walking} the substitution, because we have to look
up (in the sense of understanding $\Delta$ as a partial function) twice: The
first lookup will find |x|'s representative |y|, the second lookup on |y| will
then find the solution |Nothing|.

In denoting looking up the representative by $\Delta(x)$ (\cf \cref{fig:gen}),
we can assert that |x| has |Nothing| as a solution simply by writing $\Delta(x)
\termeq |Nothing| \in \Delta$.

Each $\Delta$ is one of possibly many valid variable assignments of the particular $\Phi$ it is
constructed for. In contrast to $\Phi$, there is no disjunction in $\Delta$,
which makes it easy to check if a new constraint is compatible with the
existing ones without any backtracking. Another fundamental difference is that
$\delta$ has no binding constructs (so every variable has to be bound in the
$\Gamma$ part of $\nabla$), whereas pattern bindings in $\varphi$ bind
constructor arguments.

$\construct$ is the function that breaks down a $\Phi$ into multiple $\nabla$s,
maintaining the invariant that no such $\nabla$ is $\false$.
At the heart of $\construct$ is adding a $\varphi$ literal to the $\nabla$
under construction via $\!\addphi\!$ and filtering out any unsuccessful
attempts (via intercepting the $\false$ failure mode of $\!\addphi\!$) to do
so. Conjunction is handled by the equivalent of a |concatMap|, whereas a
disjunction corresponds to a plain union.

Expanding a $\nabla$ to a pattern vector in $\expand$ is syntactically heavy,
but straightforward: When there is a solution like $\Delta(x) \termeq |Just y|$
in $\Delta$ for the head $x$ of the variable vector of interest, expand $y$ in
addition to the rest of the vector and wrap it in a |Just|. \inert{3}
guarantees that there is at most one such solution and $\expand$ is
well-defined.

\subsection{Extending the inert set}
\label{ssec:extinert}

\begin{figure}
\centering
\[ \textbf{Add a formula literal to the inert set} \]
\[ \ruleform{ \nabla \addphi \varphi = \nabla } \]
\[
\begin{array}{r@@{\,}c@@{\,}lcl}

  \nabla &\addphi& \false &=& \false \\
  \nabla &\addphi& \true &=& \nabla \\
  \ctxt{\Gamma}{\Delta} &\addphi& \ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x} &=&
    \ctxt{\Gamma,\overline{a},\overline{y:\tau}}{\Delta} \adddelta \overline{\gamma} \adddelta x \termeq \deltaconapp{K}{a}{y} \\
  \ctxt{\Gamma}{\Delta} &\addphi& \ctlet{x:\tau}{\expconapp{K}{\sigma'}{\sigma}{\gamma}{e}} &=& \ctxt{\Gamma,x:\tau,\overline{a},\overline{y:\tau'}}{\Delta} \adddelta \overline{a \typeeq \tau'} \adddelta x \termeq \deltaconapp{K}{a}{y} \addphi \overline{\ctlet{y}{e}} \text{ where $\overline{a} \# \Gamma$, $\overline{y} \# \Gamma$, $\overline{e:\tau'}$} \\
  \ctxt{\Gamma}{\Delta} &\addphi& \ctlet{x:\tau}{y} &=& \ctxt{\Gamma,x:\tau}{\Delta} \adddelta x \termeq y \\
  \ctxt{\Gamma}{\Delta} &\addphi& \ctlet{x:\tau}{e} &=& \ctxt{\Gamma,x:\tau}{\Delta} \\
  % TODO: Somehow make the coercion from delta to phi less ambiguous
  \ctxt{\Gamma}{\Delta} &\addphi& \varphi &=& \ctxt{\Gamma}{\Delta} \adddelta \varphi

\end{array}
\]

\[ \textbf{Add a constraint to the inert set} \]
\[ \ruleform{ \nabla \adddelta \delta = \nabla } \]
\[
\begin{array}{r@@{\,}c@@{\,}lcl}

  \false &\adddelta& \delta &=& \false \\
  \ctxt{\Gamma}{\Delta} &\adddelta& \gamma &=& \begin{cases}
    \ctxt{\Gamma}{(\Delta,\gamma)} & \parbox[t]{0.6\textwidth}{if type checker deems $\gamma$ compatible with $\Delta$ \\ and $\forall x \in \mathsf{dom}(\Gamma): \inhabited{\ctxt{\Gamma}{(\Delta,\gamma)}}{\rep{\Delta}{x}}$} \\
    \false & \text{otherwise} \\
  \end{cases} \\
  \ctxt{\Gamma}{\Delta} &\adddelta& x \termeq \deltaconapp{K}{a}{y} &=& \begin{cases}
    \ctxt{\Gamma}{\Delta} \adddelta \overline{a \typeeq b} \adddelta \overline{y \termeq z} & \text{if $\rep{\Delta}{x} \termeq \deltaconapp{K}{b}{z} \in \Delta$ } \\
    \false & \text{if $\rep{\Delta}{x} \termeq \deltaconapp{K'}{b}{z} \in \Delta$ } \\
    \ctxt{\Gamma}{(\Delta,\rep{\Delta}{x} \termeq \deltaconapp{K}{a}{y})} & \text{if $\rep{\Delta}{x} \ntermeq K \not\in \Delta$ and $\overline{\inhabited{\ctxt{\Gamma}{\Delta}}{\Delta(y)}}$} \\
    \false & \text{otherwise} \\
  \end{cases} \\
  \ctxt{\Gamma}{\Delta} &\adddelta& x \ntermeq K &=& \begin{cases}
    \false & \text{if $\rep{\Delta}{x} \termeq \deltaconapp{K}{a}{y} \in \Delta$} \\
    \false & \text{if not $\inhabited{\ctxt{\Gamma}{(\Delta,\rep{\Delta}{x} \ntermeq K)}}{\rep{\Delta}{x}}$} \\
    \ctxt{\Gamma}{(\Delta,\rep{\Delta}{x}\ntermeq K)} & \text{otherwise} \\
  \end{cases} \\
  \ctxt{\Gamma}{\Delta} &\adddelta& x \termeq \bot &=& \begin{cases}
    \false & \text{if $\rep{\Delta}{x} \ntermeq \bot \in \Delta$} \\
    \ctxt{\Gamma}{(\Delta,\rep{\Delta}{x}\termeq \bot)} & \text{otherwise} \\
  \end{cases} \\
  \ctxt{\Gamma}{\Delta} &\adddelta& x \ntermeq \bot &=& \begin{cases}
    \false & \text{if $\rep{\Delta}{x} \termeq \bot \in \Delta$} \\
    \false & \text{if not $\inhabited{\ctxt{\Gamma}{(\Delta,\rep{\Delta}{x}\ntermeq\bot)}}{\rep{\Delta}{x}}$} \\
    \ctxt{\Gamma}{(\Delta,\rep{\Delta}{x} \ntermeq \bot)} & \text{otherwise} \\
  \end{cases} \\
  \ctxt{\Gamma}{\Delta} &\adddelta& x \termeq y &=& \begin{cases}
    \ctxt{\Gamma}{\Delta} & \text{if $\rep{\Delta}{x} = \rep{\Delta}{y}$} \\
    \ctxt{\Gamma}{((\Delta \setminus \rep{\Delta}{x}), \rep{\Delta}{x} \termeq \rep{\Delta}{y})} \adddelta ((\Delta \cap \rep{\Delta}{x})[\rep{\Delta}{y} / \rep{\Delta}{x}]) & \text{otherwise} \\
  \end{cases} \\
\end{array}
\]

\[
\begin{array}{cc}
\ruleform{ \Delta \setminus x = \Delta } & \ruleform{ \Delta \cap x = \Delta } \\
\begin{array}{r@@{\,}c@@{\,}lcl}
  \varnothing &\setminus& x &=& \varnothing \\
  (\Delta,x \termeq \deltaconapp{K}{a}{y}) &\setminus& x &=& \Delta \setminus x \\
  (\Delta,x \ntermeq K) &\setminus& x &=& \Delta \setminus x \\
  (\Delta,x \termeq \bot) &\setminus& x &=& \Delta \setminus x \\
  (\Delta,x \ntermeq \bot) &\setminus& x &=& \Delta \setminus x \\
  (\Delta,\delta) &\setminus& x &=& (\Delta \setminus x),\delta \\
\end{array}&
\begin{array}{r@@{\,}c@@{\,}lcl}
  \varnothing &\cap& x &=& \varnothing \\
  (\Delta,x \termeq \deltaconapp{K}{a}{y}) &\cap& x &=& (\Delta \cap x), x \termeq \deltaconapp{K}{a}{y} \\
  (\Delta,x \ntermeq K) &\cap& x &=& (\Delta \cap x), x \ntermeq K \\
  (\Delta,x \termeq \bot) &\cap& x &=& (\Delta \cap x), x \termeq \bot \\
  (\Delta,x \ntermeq \bot) &\cap& x &=& (\Delta \cap x), x \ntermeq \bot \\
  (\Delta,\delta) &\cap& x &=& \Delta \cap x \\
\end{array}
\end{array}
\]

\caption{Adding a constraint to the inert set $\nabla$}
\label{fig:add}
\end{figure}

After tearing down abstraction after abstraction in the previous sections we
are nearly at the heart of \sysname: \Cref{fig:add} depicts how to add a
$\varphi$ constraint to an inert set $\nabla$.

It does so by expressing a $\varphi$ in terms of once again simpler constraints
$\delta$ and calling out to $\!\adddelta\!$. Specifically, for a lack of
binding constructs in $\delta$, pattern bindings extend the context and
disperse into separate type constraints and a positive constructor constraint
arising from the binding. The fourth case of $\!\adddelta\!$ finally performs
some limited, but important reasoning about let bindings: In case the
right-hand side was a constructor application (which is not to be confused with
a pattern binding, if only for the difference in binding semantics!), we add
appropriate positive constructor and type constraints, as well as recurse into
the field expressions, which might in turn contain nested constructor
applications. All other let bindings are simply discarded. We'll see an
extension in \cref{ssec:extviewpat} which will expand here. The last case of
$\!\addphi\!$ turns the syntactically and semantically identical subset of
$\varphi$ into $\delta$ and adds that constraint via $\!\adddelta\!$.

Which brings us to the prime unification procedure, $\!\adddelta\!$.
Consider adding a positive constructor constraint like $x \termeq |Just y|$:
The unification procedure will first look for any positive constructor constraint
involving the representative of $x$ with \emph{that same constructor}. Let's say
there is $\Delta(x) = z$ and $z \termeq |Just u| \in \Delta$. Then
$\!\adddelta\!$ decomposes the new constraint just like a classic unification
algorithm operating on the transitively implied equality $|Just y| \termeq
|Just u|$, by equating type and term variables with new constraints, \ie $|y|
\termeq |u|$. The original constraint, although not conflicting (thus maintaining
wellformed-ness condition \inert{1}), is not added to the inert set because of
\inert{2}.

If there was no positive constructor constraint with the same constructor, it
will look for such a constraint involving a different constructor, like $x
\termeq |Nothing|$, in which case the new constraint is incompatible with the
existing solution. There are two other ways in which the constraint can be
incompatible: If there was a negative constructor constraint $x \ntermeq
|Just|$ or if any of the fields were not inhabited, which is checked by the
$\inhabited{\nabla}{x}$ judgment in \cref{fig:inh}. Otherwise, the constraint
is compatible and is added to $\Delta$.

Adding a negative constructor constraint $x \ntermeq Just$ is quite
similar, as is handling of positive and negative constraints involving $\bot$.
The idea is that whenever we add a negative constraint that doesn't
contradict with positive constraints, we still have to test if there are any
inhabitants left.

Adding a type constraint $\gamma$ drives this paranoia to a maximum: After
calling out to the type-checker (the logic of which we do not and would not
replicate in this paper or our implementation) to assert that the constraint is
consistent with the inert set, we have to test \emph{all} variables in the
domain of $\Gamma$ for inhabitants, because the new type constraint could have
rendered a type empty. To demonstrate why this is necessary, imagine we have
$\ctxt{x : a}{x \ntermeq \bot}$ and try to add $a \typeeq |Void|$. Although the
type constraint is consistent, $x$ in $\ctxt{x : a}{x \ntermeq \bot, a \typeeq
|Void|}$ is no longer inhabited. There is room for being smart about which
variables we have to re-check: For example, we can exclude variables whose type
is a non-GADT data type.

The last case of $\!\adddelta\!$ equates two variables ($x \termeq y$) by
merging their equivalence classes. Consider the case where $x$ and $y$ don't
already belong to the same equivalence class and thus have different representatives
$\Delta(x)$ and $\Delta(y)$. $\Delta(y)$ is arbitrarily chosen to be the new
representative of the merged equivalence class. Now, to uphold the
well-formedness condition \inert{2}, all constraints mentioning $\Delta(x)$
have to be removed and renamed in terms of $\Delta(y)$ and then re-added to
$\Delta$. That might fail, because $\Delta(x)$ might have a constraint that
conflicts with constraints on $\Delta(y)$, so it is better to use $\!\adddelta\!$ rather
than to add it blindly to $\Delta$.


\subsection{Inhabitation test}

\begin{figure}
\centering
\[ \textbf{Test if $x$ is inhabited considering $\nabla$} \]
\[ \ruleform{ \inhabited{\nabla}{x} } \]
\[
\begin{array}{c}

  \prooftree
    (\ctxt{\Gamma}{\Delta} \adddelta x \termeq \bot) \not= \false
  \justifies
    \inhabited{\ctxt{\Gamma}{\Delta}}{x}
  \using
    \inhabitedbot
  \endprooftree

  \qquad

  \prooftree
    {x:\tau \in \Gamma \quad \cons(\ctxt{\Gamma}{\Delta}, \tau) = \bot}
  \justifies
    \inhabited{\ctxt{\Gamma}{\Delta}}{x}
  \using
    \inhabitednocpl
  \endprooftree

  \\
  \\

  \prooftree
    \Shortstack{{x:\tau \in \Gamma \quad K \in \cons(\ctxt{\Gamma}{\Delta}, \tau)}
                {\inst(\ctxt{\Gamma}{\Delta}, x, K) \not= \false}}
  \justifies
    \inhabited{\ctxt{\Gamma}{\Delta}}{x}
  \using
    \inhabitedinst
  \endprooftree

\end{array}
\]

\[ \textbf{Find data constructors of $\tau$} \]
\[ \ruleform{ \cons(\ctxt{\Gamma}{\Delta}, \tau) = \overline{K}} \]
\[
\begin{array}{c}

  \cons(\ctxt{\Gamma}{\Delta}, \tau) = \begin{cases}
    \overline{K} & \parbox[t]{0.8\textwidth}{$\tau = T \; \overline{\sigma}$ and $T$ data type with constructors $\overline{K}$ \\ (after normalisation according to the type constraints in $\Delta$)} \\
    % TODO: We'd need a cosntraint like \delta's \false here... Or maybe we
    % just omit this case and accept that the function is partial
    \bot & \text{otherwise} \\
  \end{cases} \\

\end{array}
\]

% This is mkOneConFull
\[ \textbf{Instantiate $x$ to data constructor $K$} \]
\[ \ruleform{ \inst(\nabla, x, K) = \nabla } \]
\[
\begin{array}{c}

  \inst(\ctxt{\Gamma}{\Delta}, x, K) =
    \ctxt{\Gamma,\overline{a},\overline{y:\sigma}}{\Delta}
      \adddelta \tau_x \typeeq \tau
      \adddelta \overline{\gamma}
      \adddelta x \termeq \deltaconapp{K}{a}{y}
      \adddelta \overline{y' \ntermeq \bot} \\
  \qquad \qquad
    \text{where $K : \forall \overline{a}. \overline{\gamma} \Rightarrow \overline{\sigma} \rightarrow \tau$, $\overline{y} \# \Gamma$, $\overline{a} \# \Gamma$, $x:\tau_x \in \Gamma$, $\overline{y'}$ bind strict fields} \\

\end{array}
\]

\caption{Inhabitance test}
\label{fig:inh}
\end{figure}

\sg{We should find better subsection titles that clearly distinguish
"Testing ($\Theta$) for Emptiness" from "Inhabitation Test(ing a
particular variable in $\nabla$)".}
The process for adding a constraint to an inert set above (which turned out to
be a unification procedure in disguise) frequently made use of an
\emph{inhabitation test} $\inhabited{\nabla}{x}$, depicted in \cref{fig:inh}.
In contrast to the emptiness test in \cref{fig:gen}, this one focuses on a
particular variable and works on a $\nabla$ rather than a much higher-level
$\Theta$.

The \inhabitedbot judgment of $\inhabited{\nabla}{x}$ tries to instantiate $x$ to
$\bot$ to conclude that $x$ is inhabited. \inhabitedinst instantiates $x$ to one
of its data constructors. That will only work if its type ultimately reduces to
a data type under the type constraints in $\nabla$. Rule \inhabitednocpl will
accept unconditionally when its type is not a data type, \ie for $x : |Int ->
Int|$.

Note that the outlined approach is complete in the sense that
$\inhabited{\nabla}{x}$ is derivable (if and) only if |x| is actually inhabited
in $\nabla$, because that means we don't have any $\nabla$s floating around
in the checking process that actually aren't inhabited and trigger false
positive warnings. But that also means that the $\inhabited{}{}$ relation is
undecidable! Consider the following example:
\begin{code}
data T = MkT !T
f :: SMaybe T -> ()
f SNothing = ()
\end{code}

\noindent
This is exhaustive, because |T| is an uninhabited type. Upon adding the constraint
$x \ntermeq |SNothing|$ on the match variable |x| via $\!\adddelta\!$, we
perform an inhabitation test, which tries to instantiate the $|SJust|$ constructor
via \inhabitedinst. That implies adding (via $\!\adddelta\!$) the constraints
$x \termeq |SJust y|, y \ntermeq \bot$, the latter of which leads to an
inhabitation test on |y|. That leads to instantiation of the |MkT| constructor,
which leads to constraints $y \termeq |MkT z|, z \ntermeq \bot$, and so on for
|z| \etc. An infinite chain of fruitless instantiation attempts!

In practice, we implement a fuel-based approach that conservatively assumes
that a variable is inhabited after $n$ such iterations and consider
supplementing that with a simple termination analysis in the future.


\section{Possible extensions}

\sysname is well equipped to handle the fragment of Haskell it was designed to
handle. But GHC (and other languages, for that matter) extends Haskell in
non-trivial ways. This section exemplifies how our solution can be easily
supplemented to deal with new language features or measures for increasing
the precision of the checking process.

\subsection{Long-distance information}
\label{ssec:ldi}

Coverage checking as described also works for |case| expressions (with the
appropriate desugaring function) and nested function definitions, like in the
following example:
\begin{code}
f True = 1
f x = ... (case x of
  False -> 2
  True -> 3) ...
\end{code}

\noindent
\sysname as is will not produce any warnings for this definition. But the
reader can easily make the ``long distance connection'' that the last GRHS of
the |case| expression is redundant! That simply follows by context-sensitive
reasoning, knowing that |x| was already matched against |True|.

In fact, \sysname does exactly the same kind of reasoning when
checking |f|! Specifically, the set of values reaching the second GRHS (which
we test for inhabitants to determine whether the GRHS is accessible)
$\Theta_{rhs2}$ encodes the information we are after. We just have to start
checking the |case| expression starting from $\Theta_{rhs2}$ as the initial set
of reaching values instead of $\reft{x:|Bool|}{\true}$.


\subsection{Empty case}

As can be seen in \cref{fig:srcsyn}, Haskell function definitions need to have
at least one clause. That leads to an awkward situation when pattern matching
on empty data types, like |Void|:
\begin{code}
absurd :: Void -> a
absurd _   = undefined
absurd !_  = undefined
\end{code}

\noindent
Clearly, neither option is satisfactory to implement |absurd|: The first one
would actually return |undefined| when called with $\bot$, thus masking the
original $\bot$ with the error thrown by |undefined|. The second one would
diverge alright, but it is unfortunate that we still have to provide a RHS that
we know will never be entered. In fact, \sysname will mark the
second option as having an inaccessible RHS!

GHC provides an extension, called \extension{EmptyCase}, that introduces the
following bit of new syntax:
\begin{code}
absurd x = case x of {}
\end{code}

\noindent
Such a |case| expression without any alternatives evaluates its argument to
WHNF and crashes when evaluation returns.

Although we did not give the syntax of |case| expressions in \cref{fig:srcsyn},
it is quite easy to see that $\Gdt$ lacks expressive power to desugar
\extension{EmptyCase} into, since all leaves in a guard tree need to have
corresponding RHSs. Therefore, we need to introduce $\gdtempty$ to $\Gdt$ and
$\antempty$ to $\Ant$. The new $\gdtempty$ case has to be handled by the
checking functions and is a neutral element to $\gdtseq{}{}$ as far as $\unc$
is concerned:
\[
\begin{array}{lcl}
\unc(\Theta, \gdtempty) &=& \Theta \\
\ann(\Theta, \gdtempty) &=& \antempty \\
\end{array}
\]

Since \extension{EmptyCase}, unlike regular |case|, evaluates its scrutinee
to WHNF \emph{before} matching any of the patterns, the set of reaching
values is refined with a $x \ntermeq \bot$ constraint before traversing the
guard tree. So, for checking an empty |case|, the call to $\unc$ looks like
$\unc(\Theta \andtheta (x \ntermeq \bot), \gdtempty)$, where $\Theta$ is the
context-sensitive set of reaching values, possibly enriched with long distance
information (\cf \cref{ssec:ldi}).


\subsection{View patterns}
\label{ssec:extviewpat}

Our source syntax had support for view patterns to start with (\cf
\cref{fig:srcsyn}). And even the desugaring we gave as part of the definition
of $\ds$ in \cref{fig:desugar} is accurate. But this desugaring alone is
insufficient for the checker to conclude that |safeLast| from
\cref{sssec:viewpat} is an exhaustive definition! To see why, let's look at its
guard tree:

\begin{forest}
  grdtree,
  [
    [{$\grdlet{|y_1|}{|reverse x_1|}, \grdbang{|y_1|}, \grdcon{|Nothing|}{|y_1|}$} [1]]
    [{$\grdlet{|y_2|}{|reverse x_1|}, \grdbang{|y_2|}, \grdcon{|Just t_1|}{|y_2|}, \grdbang{|t_1|}, \grdcon{|(t_2, t_3)|}{|t_1|}$} [2]]]
\end{forest}

Although |y_1| and |y_2| bind syntactically equivalent expressions, our simple
desugaring function doesn't see that and allocated fresh names for each of
them. That in turn means that both the match on |y_1| and |y_2| by itself are
inexhaustive. But due to referential transparency, the result of |reverse x_1|
doesn't change! By making the connection between |y_1| and |y_2|, the checker
could infer that the match was exhaustive.

This can be fixed at any level of abstraction (\ie in $\ds$ or $\!\addphi\!$)
by maintaining equivalence classes of semantically equivalent expressions. For
the example above, handling $\grdlet{|y_2|}{|reverse x_1|}$ in the second
branch would entail looking up the equivalence class of |reverse x_1| and
finding out that it is also bound by |y_1|, so we can handle
$\grdlet{|y_2|}{|y_1|}$ instead and make sense of the $|y_1| \ntermeq
|Nothing|$ constraint that fell through from the first branch to conclude
that the match is exhaustive.

In fact, that is just like performing an on-the-fly global value numbering
(GVN) of expression~\cite{gvn}! We decided to perform (an approximation to) GVN
at the level of $\!\addphi\!$, because it is more broadly applicable there and
a very localised change:
\[
\begin{array}{r@@{\,}c@@{\,}lcl}
  \ctxt{\Gamma}{\Delta} &\addphi& \ctlet{x:\tau}{e} &=& \highlight{\ctxt{\Gamma}{\Delta} \addphi \ctlet{x:\tau}{r_i} \quad \text{where $i$ is global value number of |e|}} \\
\end{array}
\]

Where |r_i| is the representative of the equivalence class of expressions with
global value number $i$. Thus, our implementation will not emit any warning for
a definition like |safeLast|.


\subsection{Pattern synonyms}
\label{ssec:extpatsyn}

To accommodate checking of pattern synonyms $P$, we first have to extend the
source syntax and IR syntax by adding the syntactic concept of a
\emph{ConLike}:
\[
\begin{array}{cc}
\begin{array}{rcl}
  cl     &\Coloneqq& K \mid P \\
  pat    &\Coloneqq& x \mid |_| \mid \highlight{cl} \; \overline{pat} \mid x|@|pat \mid ... \\
\end{array} &
\begin{array}{rlcl}
  P \in           &\PS \\
  C \in           &\CL  &\Coloneqq& K \mid P \\
  p \in           &\Pat &\Coloneqq& \_ \mid \highlight{C} \; \overline{p} \mid ... \\
\end{array}
\end{array}
\]

\sg{For coverage checking purposes, we assume that pattern synonym matches
are strict, just like data constructor matches. This is not generally true, but
\ticket{17357} has a discussion of why being conservative is too disruptive to
be worth the trouble. Should we talk about that? It concerns the definition of
$\ds$, namely whether to add a $\grdbang{x}$ on the match var or not. Maybe a
footnote?}

Assuming every definition encountered so far is changed to handle ConLikes $C$
now instead of data constructors $K$, everything should work almost fine. Why
then introduce the new syntactic variant in the first place? Consider
\begin{code}
pattern P = ()
pattern Q = ()
n = case P of Q -> 1; P -> 2
\end{code}

Knowing that the definitions of |P| and |Q| completely overlap, we can see that
|Q| will cover all values that could reach |P|, so clearly |P| is redundant.
A sound approximation to that would be not to warn at all. And that's reasonable,
after all we established in \cref{ssec:patsyn} that reasoning about pattern
synonym definitions is undesirable.

But equipped with long distance information from the scrutinee expression, the
checker would mark the \emph{first case alternative} as redundant, which
clearly is unsound! Deleting the first alternative would change its semantics
from returning 1 to returning 2. In general, we cannot assume that arbitrary
pattern synonym definitions are disjunct. That is in stark contrast to data
constructors, which never overlap.

The solution is to tweak the clause of $\!\adddelta\!$ dealing with positive
ConLike constraints $x \termeq \deltaconapp{C}{a}{y}$:
\[
\begin{array}{r@@{\,}c@@{\,}lcl}
\ctxt{\Gamma}{\Delta} &\adddelta& x \termeq \deltaconapp{C}{a}{y} &=& \begin{cases}
    \ctxt{\Gamma}{\Delta} \adddelta \overline{a \typeeq b} \adddelta \overline{y \termeq z} & \text{if $\rep{\Delta}{x} \termeq \deltaconapp{C}{b}{z} \in \Delta$ } \\
    \false & \text{if $\rep{\Delta}{x} \termeq \deltaconapp{C'}{b}{z} \in \Delta$ \highlight{\text{and $C \cap C' = \emptyset$}}} \\
    \ctxt{\Gamma}{(\Delta,\rep{\Delta}{x} \termeq \deltaconapp{C}{a}{y})} & \text{if $\rep{\Delta}{x} \ntermeq C \not\in \Delta$ and $\overline{\inhabited{\ctxt{\Gamma}{\Delta}}{\Delta(y)}}$} \\
    \false & \text{otherwise} \\
  \end{cases} \\
\end{array}
\]

Where the suggestive notation $C \cap C' = \emptyset$ is only true if $C$ and
$C'$ don't overlap, if both are data constructors, for example.

Note that the slight relaxation means that the constructed $\nabla$ might
violate $\inert{3}$, specifically when $C \cap C' \not= \emptyset$. In practice
that condition only matters for the well-definedness of $\expand$, which in
case of multiple solutions (\ie $x \termeq P, x\termeq Q$) has to commit to one
them for the purposes of reporting warnings. Fixing that requires a bit of
boring engineering.

\subsection{\extension{COMPLETE} pragmas}
\label{ssec:complete}

In a sense, every algebraic data type defines its own builtin
\extension{COMPLETE} set, consisting of all its data constructors, so the
coverage checker already manages a single \extension{COMPLETE} set.

We have \inhabitedinst from \cref{fig:inh} currently making sure that this
\extension{COMPLETE} set is in fact inhabited. We also have \inhabitednocpl
that handles the case when we can't find \emph{any} \extension{COMPLETE} set
for the given type (think |x : Int -> Int|). The obvious way to generalise this
is by looking up all \extension{COMPLETE} sets attached to a type and check
that none of them is completely covered:
\[
\begin{array}{cc}
  \prooftree
    (\ctxt{\Gamma}{\Delta} \adddelta x \termeq \bot) \not= \false
  \justifies
    \inhabited{\ctxt{\Gamma}{\Delta}}{x}
  \using
    \inhabitedbot
  \endprooftree

  &

  \prooftree
    \Shortstack{{x:\tau \in \Gamma \quad \cons(\ctxt{\Gamma}{\Delta}, \tau)=\highlight{\overline{C_1,...,C_{n_i}}^i}}
                {\highlight{\overline{\inst(\ctxt{\Gamma}{\Delta}, x, C_j) \not= \false}^i}}}
  \justifies
    \inhabited{\ctxt{\Gamma}{\Delta}}{x}
  \using
    \inhabitedinst
  \endprooftree
\end{array}
\]
\[
\begin{array}{c}
  \cons(\ctxt{\Gamma}{\Delta}, \tau) = \begin{cases}
    \highlight{\overline{C_1,...,C_{n_i}}^i} & \parbox[t]{0.8\textwidth}{$\tau = T \; \overline{\sigma}$ and $T$ \highlight{\text{type constructor with \extension{COMPLETE} sets $\overline{C_1,...,C_{n_i}}^i$}} \\ (after normalisation according to the type constraints in $\Delta$)} \\
    \highlight{\epsilon} & \text{otherwise} \\
  \end{cases}
\end{array}
\]

\sg{What do you think of the indexing on $C_i$? It's not entirely accurate, but
do we want to cloud the presentation with \ie $\overline{C_{i,1},...,C_{i,n_i}}^i$?}

$\cons$ was changed to return a list of all available \extension{COMPLETE} sets,
and \inhabitedinst tries to find an inhabiting ConLike in each one of them in
turn. Note that \inhabitednocpl is gone, because it coincides with
\inhabitedinst for the case where the list returned by $\cons$ was empty. The
judgment has become simpler and and more general at the same time!

Note that checking against multiple \extension{COMPLETE} sets so frequently is
computationally intractable. We will worry about that in \cref{sec:impl}.


\subsection{Literals}

The source syntax in \cref{fig:srcsyn} deliberately left out literal patterns
$l$. Literals are very similar to nullary data constructors, with one caveat:
They don't come with a builtin \texttt{COMPLETE} set. Before
\cref{ssec:complete}, that would have meant quite a bit of hand waving and
complication to the $\inhabited{}{}$ judgment. Now, literals can be handled
like disjunct pattern synonyms (\ie $l_1 \cap l_2 = \emptyset$ for any two
literals $l_1, l_2$) without a \texttt{COMPLETE} set!

We can even handle overloaded literals, but will find ourselves in a similar
situation as with pattern synonyms:
\begin{code}
instance Num () where
  fromInteger _ = ()
n = case (0 :: ()) of 1 -> 1; 0 -> 2
\end{code}

\noindent
Considering overloaded literals to be disjunct would mean marking the first
alternative as redundant, which is unsound. Hence we regard overloaded literals
as possibly overlapping, so they behave exactly like nullary pattern synonyms
without a \extension{COMPLETE} set.


\subsection{Newtypes}

\begin{figure}
\[
\begin{array}{cc}
\begin{array}{c}
  cl \Coloneqq K \mid P \mid \highlight{N} \\
\end{array} &
\begin{array}{rlcl}
  N  \in &\NT \\
  C  \in &K \mid P \mid \highlight{N} \\
\end{array}
\end{array}
\]
\[
  \ds(x, N \; pat_1\,...\,pat_n) = \grdcon{N \; y_1\,...\,y_n}{x}, \ds(y_1, pat_1), ..., \ds(y_n, pat_n)
\]
\[
\begin{array}{cc}
  \prooftree
    \Shortstack{{(\ctxt{\Gamma}{\Delta} \adddelta x \termeq \bot) \not= \false}
                {\highlight{x:\tau \in \Gamma \quad \text{$\tau$ not a Newtype}}}}
  \justifies
    \inhabited{\ctxt{\Gamma}{\Delta}}{x}
  \using
    \inhabitedbot
  \endprooftree

  &

  \prooftree
    \Shortstack{{x:\tau \in \Gamma \quad \cons(\ctxt{\Gamma}{\Delta}, \tau)=\overline{C_1,...,C_{n_i}}^i}
                {\overline{\inst(\ctxt{\Gamma}{\Delta}, x, C_j) \not= \false}^i \quad \highlight{\text{$\tau$ not a Newtype}}}}
  \justifies
    \inhabited{\ctxt{\Gamma}{\Delta}}{x}
  \using
    \inhabitedinst
  \endprooftree \\

  \highlight{\prooftree
    \Shortstack{{\text{$\tau$ Newtype with constructor |N| wrapping $\sigma$}}
                {x:\tau \in \Gamma \quad y\#\Gamma \quad \inhabited{\ctxt{\Gamma,y:\sigma}{\Delta} \adddelta x \termeq |N y|}{|y|}}}
  \justifies
    \inhabited{\ctxt{\Gamma}{\Delta}}{x}
  \using
    \inhabitedinst
  \endprooftree}
\end{array}
\]
\[
\begin{array}{r@@{\,}c@@{\,}lcl}
  \ctxt{\Gamma}{\Delta} &\adddelta& x \termeq \bot &=& \begin{cases}
    \false & \text{if $\rep{\Delta}{x} \ntermeq \bot \in \Delta$} \\
    \highlight{\ctxt{\Gamma}{\Delta} \adddelta x \termeq |N y| \adddelta y \termeq \bot} & \text{if $x:\tau \in \Gamma$, $\tau$ Newtype with constructor |N| wrapping $\sigma$} \\
    \ctxt{\Gamma}{(\Delta,\rep{\Delta}{x}\termeq \bot)} & \text{otherwise} \\
  \end{cases} \\
  \ctxt{\Gamma}{\Delta} &\adddelta& x \ntermeq \bot &=& \begin{cases}
    \false & \text{if $\rep{\Delta}{x} \termeq \bot \in \Delta$} \\
    \false & \text{if not $\inhabited{\ctxt{\Gamma}{(\Delta,\rep{\Delta}{x}\ntermeq\bot)}}{\rep{\Delta}{x}}$} \\
    \highlight{\ctxt{\Gamma}{\Delta} \adddelta x \termeq |N y| \adddelta y \ntermeq \bot} & \text{if $x:\tau \in \Gamma$, $\tau$ Newtype with constructor |N| wrapping $\sigma$} \\
    \ctxt{\Gamma}{(\Delta,\rep{\Delta}{x} \ntermeq \bot)} & \text{otherwise} \\
  \end{cases} \\
\end{array}
\]

\caption{Extending coverage checking to handle Newtypes}
\label{fig:newtypes}
\end{figure}

Newtypes have strange semantics. Here are two key examples that distinguish
it from data types:
\begin{minipage}{\textwidth}
\begin{minipage}[b]{0.33\textwidth}
\centering
\begin{code}
newtype N a = N a
g1 :: N () -> Bool -> Int
g1 !!(N _)   True = 1
g1   (N !_)  True = 2
\end{code}
\end{minipage}%
\begin{minipage}[b]{0.33\textwidth}
\centering
\begin{code}
g2 :: N () -> Bool -> Int
g2   (N !_)  True = 2
g2 !!(N _)   True = 1
\end{code}
\end{minipage}%
\begin{minipage}[b]{0.33\textwidth}
\centering
\begin{code}
f :: N Void -> Bool -> Int
f _      True   = 1
f (N _)  True   = 2
f !_     True   = 3
\end{code}
\end{minipage}
\end{minipage}

The definition of |f| is subtle. Contrary to the situation with data
constructors, the second GRHS is \emph{redundant}: The pattern match on the
Newtype constructor is a no-op. Conversely, the bang pattern in the third GRHS
forces not only the Newtype constructor, but also its wrapped thing. That could
lead to divergence, so the third GRHS is \emph{inaccessible} (because every
value it could cover was already covered by the first GRHS), but not redundant.
A perhaps surprising consequence is that the definition of |f| is exhaustive,
because after |N Void| was deprived of its sole inhabitant $\bot \equiv
N\,\bot$, there is nothing left to match on.

\Cref{fig:newtypes} outlines a solution that handles |f| correctly. The idea
is to treat Newtype pattern matches lazily (so compared to data constructor
matches, $\ds$ omits the $\grdbang{x}$). The other significant change is
to the $\inhabited{}{}$ judgment form, where we introduce a new rule
\inhabitednt that is specific to Newtypes, which can no longer be proven
inhabited by either \inhabitedinst or \inhabitedbot.

But |g1| crushes this simple hack. We would mark its second GRHS as
inaccessible when it is clearly redundant, because the $x \ntermeq \bot$
constraint on the match variable |x| wasn't propagated to the wrapped |()|.
The inner bang pattern has nothing to evaluate. This is arguably a small
downside and doesn't even regress in terms of soundness.

We counter that with another refinement: We just add $|x| \termeq N y$ and $|y|
\ntermeq \bot$ constraints (similarly for $|y| \termeq \bot$) whenever we add
$|x| \ntermeq \bot$ constraints when we know that |x| is a Newtype with
constructor |N|. Both |g1| and |g2| will be handled correctly.

\sg{Needless to say, we won't propagate $\bot$ constraints when we only find
out (by additional type info) that something is a Newtype \emph{after} adding
the constraints (think |SMaybe a| and we later find that $a \typeeq N Void$),
but let's call it a day.}

An alternative, less hacky solution would be treating Newtype wrappers as
coercions and at the level of $\Delta$ consider equivalence classes modulo
coercions. That entails a slew of modifications and has deep ramifications
throughout the presentation.


\subsection{Strictness}

Instead of extending the source language, let's discuss ripping out a language
feature, for a change! So far, we have focused on Haskell as the source
language of the checking process, which is lazy by default. Although the
desugaring function makes sure that the difference in evaluation strategy of
the source language quickly becomes irrelevant, it raises the question of how
much our approach could be simplified if we targeted a source language that was
strict by default, such as OCaml or Idris.

First off, both languages offer language support for laziness and lazy pattern
matches, so the question rather becomes whether the gained simplification is
actually worth risking unusable or even unsound warning messages when making
use of laziness. If the answer is ``No'', then there isn't anything to
simplify, just relatively more $x \termeq \bot$ constraints to handle.

Otherwise, in a completely eager language we could simply drop $\grdbang{x}$
from $\Grd$ and $\antdiv{}$ from $\Ant$. Actually, $\Ant$ and $\red$ could go
altogether and $\ann$ could just collect the redundant GRHS directly!

Since there wouldn't be any bang guards, there is no reason to have $x \termeq
\bot$ and $x \ntermeq \bot$ constraints either. Most importantly, the
\inhabitedbot judgment form has to go, because $\bot$ does not inhabit any
types anymore.


\section{Implementation}
\label{sec:impl}

The implementation of \sysname in GHC accumulates quite a few tricks that
go beyond the pure formalism. This section is dedicated to describing these.

Warning messages need to reference source syntax in order to be comprehensible
by the user. At the same time, coverage checks involving GADTs need a
type-checked program, so the only reasonable design to run the coverage checker
between type-checking and desugaring to GHC Core, a typed intermediate
representation lacking the connection to source syntax. We perform coverage
checking in the same tree traversal as desugaring.

\sg{New implementation (pre !2753) has 3850 lines, out of which 1753 is code.
Previous impl as of GHC 8.6.5 had 3118 lines, out of which 1438 were code. Not
sure how to sell that.}

\subsection{Interleaving $\unc$ and $\ann$}
\label{ssec:interleaving}

\begin{figure}
\[ \ruleform{ \overline{\nabla} \addphiv \varphi = \overline{\nabla} } \]
\[
\begin{array}{r@@{\,}c@@{\,}lcl}
\epsilon &\addphiv& \varphi &=& \epsilon \\
(\nabla_1\,...\,\nabla_n) &\addphiv& \varphi &=& \begin{cases}
    (\ctxt{\Gamma}{\Delta}) \, (\nabla_2\,...\,\nabla_n \addphiv \varphi) & \text{if $\ctxt{\Gamma}{\Delta} = \nabla \addphi \varphi$} \\
    (\nabla_2\,...\,\nabla_n) \addphiv \varphi & \text{otherwise} \\
  \end{cases} \\
\end{array}
\]
\[ \ruleform{ \uncann(\overline{\nabla}, t_G) = (\overline{\nabla}, \Ant) } \]
\[
\begin{array}{lcl}
\uncann(\epsilon, \gdtrhs{n}) &=& (\epsilon, \antred{n}) \\
\uncann(\overline{\nabla}, \gdtrhs{n}) &=& (\epsilon, \antrhs{n}) \\
\uncann(\overline{\nabla}, \gdtseq{t_G}{u_G}) &=& (\overline{\nabla}_2, \antseq{t_A}{u_A}) \hspace{0.5em} \text{where} \begin{array}{l@@{\,}c@@{\,}l}
    (\overline{\nabla}_1, t_A) &=& \uncann(\overline{\nabla}, t_G) \\
    (\overline{\nabla}_2, u_A) &=& \uncann(\overline{\nabla}_1, u_G)
  \end{array} \\
\uncann(\overline{\nabla}, \gdtguard{(\grdbang{x})}{t_G}) &=& \begin{cases}
    (\overline{\nabla}', t_A), & \overline{\nabla} \addphiv (x \termeq \bot) = \epsilon \\
    (\overline{\nabla}', \antdiv{t_A}) & \text{otherwise} \\
  \end{cases} \\
  && \quad \text{where } (\overline{\nabla}', t_A) = \uncann(\overline{\nabla} \addphiv (x \ntermeq \bot), t_G) \\
\uncann(\overline{\nabla}, \gdtguard{(\grdlet{x}{e})}{t}) &=& \uncann(\overline{\nabla} \addphiv (\ctlet{x}{e}), t) \\
\uncann(\overline{\nabla}, \gdtguard{(\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{t_G}) &=& ((\overline{\nabla} \addphiv (x \ntermeq K)) \, \overline{\nabla}', t_A) \\
  && \quad \text{where } (\overline{\nabla}', t_A) = \uncann(\overline{\nabla} \addphiv (\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}), t_G) \\
\end{array}
\]

\caption{Fast coverage checking}
\label{fig:fastcheck}
\end{figure}

The set of reaching values is an argument to both $\unc$ and $\ann$. given a
particular set of reaching values and a guard tree, one can see by a simple
inductive argument that both $\unc$ and $\ann$ are always called at the same
arguments! Hence for an implementation it makes sense to compute both results
together, if only for not having to recompute the results of $\unc$ again in
$\ann$.

But there's more: Looking at the last clause of $\unc$ in \cref{fig:check},
we can see that we syntactically duplicate $\Theta$ every time we have a
pattern guard. That can amount to exponential growth of the refinement
predicate in the worst case and for the time to prove it empty!

Clearly, the space usage won't actually grow exponentially due to sharing in
the implementation, but the problems for runtime performance remain.
What we really want is to summarise a $\Theta$ into a more compact canonical
form before doing these kinds of \emph{splits}. But that's exactly what
$\nabla$ is! Therefore, in our implementation we don't really build up a
refinement type but pass around the result of calling $\construct$ on what
would have been the set of reaching values.

You can see the resulting definition in \cref{fig:fastcheck}. The readability
of the interleaving of both functions is clouded by unwrapping of pairs. Other
than that, all references to $\Theta$ were replaced by a vector of $\nabla$s.
$\uncann$ requires that these $\nabla$s are non-empty, \ie not $\false$. This
invariant is maintained by adding $\varphi$ constraints through $\addphiv$,
which filters out any $\nabla$ that would become empty. All mentions of
$\generate$ are gone, because we never were interested in inhabitants in the
first place, only whether there where any inhabitants at all! In this new
representation, whether a vector of $\nabla$ is inhabited is easily seen by
syntactically comparing it to the empty vector, $\epsilon$.

\subsection{Throttling for graceful degradation}

Even with the tweaks from \cref{ssec:interleaving}, checking certain pattern
matches remains NP-hard \sg{Cite something here or earlier, bring an example}.
Naturally, there will be cases where we have to conservatively approximate in
order not to slow down compilation too much. After all, coverage checking
is just a static analysis pass without any effect on the produced binary!
Consider the following example:
\begin{code}
f1, f2 :: Int -> Bool
g _
  | True <- f1 0,  True <- f2 0  = ()
  | True <- f1 1,  True <- f2 1  = ()
  ...
  | True <- f1 N,  True <- f2 N  = ()
\end{code}

Here's the corresponding guard tree:

\begin{forest}
  grdtree,
  [
    [{$\grdlet{t_1}{|f1 0|}, \grdbang{t_1}, \grdcon{|True|}{t_1}, \grdlet{t_2}{|f2 0|}, \grdbang{t_2}, \grdcon{|True|}{t_2}$} [1]]
    [{$\grdlet{t_3}{|f1 1|}, \grdbang{t_3}, \grdcon{|True|}{t_3}, \grdlet{t_4}{|f2 1|}, \grdbang{t_4}, \grdcon{|True|}{t_4}$} [2]]
    [... [...]]
    [{$\grdlet{t_{2*N+1}}{|f1 N|}, \grdbang{t_{2*N+1}}, \grdcon{|True|}{t_{2*N+1}}, \grdlet{t_{2*N+2}}{|f2 N|}, \grdbang{t_{2*N+2}}, \grdcon{|True|}{t_{2*N+2}}$} [N]]]
\end{forest}

Each of the $N$ GRHS can fall through in two distinct ways: By failure of
either pattern guard involving |f1| or |f2|. Each way corresponds to a way in
which the vector of reaching $\nabla$s is split. For example, the single,
unconstrained $\nabla$ reaching the first equation will be split in one $\nabla$
that records that either $t_1 \ntermeq |True|$ or that $t_2 \ntermeq |True|$.
Now two $\nabla$s fall through and reach the second branch, where they are
split into four $\nabla$s. This exponential pattern repeats $N$ times, and
leads to horrible performance!

There are a couple of ways to go about this. First off, that it is always OK to
overapproximate the set of reaching values! Instead of \emph{refining} $\nabla$
with the pattern guard, leading to a split, we could just continue with the
original $\nabla$, thus forgetting about the $t_1 \ntermeq |True|$ or $t_2
\ntermeq |True|$ constraints. In terms of the modeled refinement type, $\nabla$
is still a superset of both refinements.

Another realisation is that each of the temporary variables binding the pattern
guard expressions are only scrutinised once, within the particular branch they
are bound. That makes one wonder why we record a fact like $t_1 \ntermeq
|True|$ in the first place. Some smart "garbage collection" process might get
rid of this additional information when falling through to the next equation,
where the variable is out of scope and can't be accessed. The same procedure
could even find out that in the particular case of the split that the $\nabla$
falling through from the |f1| match models a superset of the $\nabla$ falling
through from the |f2| match (which could additionally diverge when calling
|f2|). This approach seemed far to complicated for us to pursue.

Instead, we implement \emph{throttling}: We limit the number of reaching
$\nabla$s to a constant. Whenever a split would exceed this limit, we continue
with the original reaching $\nabla$ (which as we established is a superset,
thus a conservative estimate) instead. Intuitively, throttling corresponds to
\emph{forgetting} what we matched on in that particular subtree.

Throttling is refreshingly easy to implement! Only the last clause of
$\uncann$, where splitting is performed, needs to change:
\[
\begin{array}{r@@{\,}c@@{\,}lcl}
\uncann(\overline{\nabla}, \gdtguard{(\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{t_G}) &=& (\throttle{\overline{\nabla}}{(\overline{\nabla} \addphiv (x \ntermeq K)) \, \overline{\nabla}'}, t_A) \\
  && \quad \text{where } (\overline{\nabla}', t_A) = \uncann(\overline{\nabla} \addphiv (\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}), t_G)
\end{array}
\]

where the new throttling operator $\throttle{\mathunderscore}{\mathunderscore}$
is defined simply as
\[
\begin{array}{lcl}
\throttle{\overline{\nabla}'}{\overline{\nabla}} &=& \begin{cases}
    \overline{\nabla} & \text{if $||\{\overline{\nabla}\}|| \leq K$} \\
    \overline{\nabla}' & \text{otherwise}
  \end{cases}
\end{array}
\]

with $K$ being an arbitrary constant. We use 30 as an arbitrary limit in our
implementation (dynamically configurable via a command-line flag) without
noticing any false positives in terms of exhaustiveness warnings outside of the
test suite.

For the sake of our above example we'll use 4 as the limit. The initial $\nabla$
will be split by the first equation in two, which in turn results in 4 $\nabla$s
reaching the third equation. Here, splitting would result in 8 $\nabla$s, so
we throttle, so that the same four $\nabla$s reaching the third equation also
reach the fourth equation, and so on. Basically, every equation is checked for
overlaps \emph{as if} it was the third equation, because we keep on forgetting
what was matched beyond that.


\subsection{Maintaining residual \extension{COMPLETE} sets}
\label{ssec:residual-complete}

Our implementation applies a few hacks to make the inhabitation test as
efficient as possible. For example, we represent $\Delta$s by a mapping from
variables to their positive and negative constraints for easier indexing.
But there are also asymptotical improvements. Consider the following function:
\begin{minipage}{\textwidth}
\begin{minipage}[t]{0.33\textwidth}
\begin{code}
data T = A1 | ... | A1000
pattern P = ...
{-# COMPLETE A1, P #-}
\end{code}
\end{minipage}
\begin{minipage}[t]{0.22\textwidth}
\begin{code}
f :: T -> Int
f A1     = 1
f A2     = 2
...
f A1000  = 1000
\end{code}
\end{minipage}
\end{minipage}

|f| is exhaustively defined. For seeing that we need to perform an inhabitation
test for the match variable |x| after the last clause. The test will conclude
that the builtin \extension{COMPLETE} set was completely overlapped. But in
order to conclude that, our algorithm tries to instantiate |x| (via
\inhabitedinst) to each of its 1000 constructors and try to add a positive
constructor constraint! What a waste of time, given that we could just look at
the negative constraints on |x| \emph{before} trying to instantiate |x|. But
asymptotically it shouldn't matter much, since we're doing this only once at
the end.

Except that is not true, because we also perform redundancy checking! At any
point in |f|'s definition there might be a match on |P|, after which all
remaining clauses would be redundant by the user-supplied \extension{COMPLETE}
set. Therefore, we have to perform the expensive inhabitation test \emph{after
every clause}, involving $\mathcal{O}(n)$ instantiations each.

Clearly, we can be smarter about that! Indeed, we cache \emph{residual
\extension{COMPLETE} sets} in our implementation: Starting from the full
\extension{COMPLETE} sets, we delete ConLikes from them whenever we add a new
negative constructor constraint, maintaining the invariant that each of the
sets is inhabited by at least one constructor. Note how we never need to check
the same constructor twice (except after adding new type constraints), thus we
have an amortised $\mathcal{O}(n)$ instantiations for the whole checking
process.

\section{Evaluation}
\label{sec:eval}

\ryan{Put a snappy intro here}

\subsection{Reporting uncovered patterns}

Our formalism in \cref{fig:gen} is subtly buggy when it comes to presenting
uncovered patterns to the user. Consider a definition like |f True = ()|. The
computed uncovered set of |f| is the refinement type $\{ x:|Bool| \mid x
\ntermeq \bot, x \ntermeq |True| \}$, which crucially contains no positive
information! As a result, the result of expanding the resulting $\nabla$ (which
looks quite similar) with $\expand$ just unhelpfully reports |_| as an uncovered
pattern.

Our implementation thus splits the $\nabla$ into (possibly multiple)
sub-$\nabla$s with positive information on variables we have negative
information on before handing off to $\expand$.

\subsection{GHC issues}

Implementing \sysname in GHC has fixed a litany of bug reports related
to coverage checking. These include:

\begin{itemize}
  \item
    Better compile-time performance
    \cite{gitlab:11195,gitlab:11528,gitlab:17096,gitlab:17264}

  \item
    More accurate warnings for empty |case| expressions
    \cite{gitlab:10746,gitlab:13717,gitlab:14813,gitlab:15450,gitlab:17376}

  \item
    More accurate warnings due to \sysname's desugaring
    \cite{gitlab:11984,gitlab:12949,gitlab:14098,gitlab:15385,gitlab:17646}

  \item
    More accurate warnings due to improved term-level reasoning
    \cite{gitlab:12957,gitlab:14546,gitlab:14667,gitlab:15713,gitlab:15753,gitlab:15884,gitlab:16129,gitlab:16289,gitlab:17251}

  \item
    More accurate warnings due to tracking long-distance information
    \cite{gitlab:17465,gitlab:17703,gitlab:17783}

  \item
    Improved treatment of \extension{COMPLETE} sets
    \cite{gitlab:13021,gitlab:13363,gitlab:13965,gitlab:14059,gitlab:14253,gitlab:14851,gitlab:17112,gitlab:17149,gitlab:17386}

  \item
    Better treatment of strictness, bang patterns, and newtypes
    \cite{gitlab:15305,gitlab:15584,gitlab:17234,gitlab:17248}

\end{itemize}

\section{Related work} \label{sec:related}

\subsection{Comparison with GADTs Meet Their Match}
\label{ssec:gmtm}

\citet{gadtpm} present GADTs Meet Their Match (\gmtm), an algorithm which
handles many of the
subtleties of GADTs, guards, and laziness mentioned earlier in this
section. Despite this, the \gmtm algorithm still gives incorrect warnings
in many cases.

\subsubsection{\gmtm does not consider laziness in its full glory}

The formalism in \citet{gadtpm} incorporates strictness constraints, but
these constraints can only arise from matching against data constructors.
\gmtm does not consider strict matches that arise from strict fields of
data constructors or bang patterns. A consequence of this is that \gmtm
would incorrectly warn that |v| (\ryan{Cite the section!}) is missing a
case for |SJust|, even though such a case is unreachable. \sysname,
on the other hand, more thoroughly tracks strictness when desugaring
Haskell programs.

\subsubsection{\gmtm's treatment of guards is shallow}

\gmtm can only reason about guards through an abstract term oracle.
Although the algorithm is parametric over the choice of oracle, in practice
the implementation of \gmtm in GHC uses an extremely simple oracle that can
only reason about guards in a limited fashion.
More sophisticated uses of guards, such
as in the |safeLast| function from \ryan{Cite the section!}, will
cause \gmtm to emit erroneous warnings.

While \gmtm's term oracle is customizable, it is not as simple to customize
as one might hope. The formalism in \citet{gadtpm} represents all guards as
|p <- e|, where |p| is a pattern and |e| is an expression. This is a
straightforward, syntactic representation, but it also makes it more difficult to
analyse when |e| is a complicated expression. This is one of the reasons why
it is difficult for \gmtm to accurately give warnings for the |safeLast|
function, since it would require recognizing that both clauses scrutinise
the same expression in their view patterns.

\sysname makes analysing term equalities simpler by first desugaring guards
from the surface syntax to guard trees. The $\addphi$ function, which is
roughly a counterpart to \gmtm's term oracle, can then reason
about terms arising from patterns. While $\addphi$ is already more powerful
than a trivial term oracle, its real strength lies in the fact that it can
easily be extended, as \sysname's treatment of pattern synonyms
(\cref{ssec:extpatsyn}) demonstrates. While \gmtm's term oracle could be
improved to accomplish the same thing, it is unlikely to be as
straightforward of a process as extending $\addphi$.

\ryan{Should we mention something about the performance of \gmtm here?}

\subsection{Comparison with similar coverage checkers}

\subsubsection{Structural and semantic pattern matching analysis in Haskell}

\citet{kalvoda2019structural} implement a variation of \gmtm that leverages an
SMT solver to give more accurate coverage warnings for programs that use
guards. For instance, their implementation can conclude that
the |signum| function from \ryan{Which section?} is exhaustive. This is something
that \sysname cannot do out of the box, although it would be possible to
extend $\addphi$ with SMT-like reasoning about booleans and integer arithmetic.
\ryan{Sebastian: is this the thing that would need to be extended?}
\sg{Yes, I imagine that $\addphi$ would match on arithmetic expressions and then
add some kind of new $\delta$ constraint to $\Delta$. $\adddelta$ would then
have to do the actual linear arithmetic reasoning, \eg conclude from
$x \not< e, x \ntermeq e, x \not> e$ (and $x \ntermeq \bot$) that $x$ is not
inhabited, quite similar to a \extension{COMPLETE} set.}

\subsubsection{Warnings for pattern matching}
\label{ssec:maranget}

\citet{maranget:warnings} presents a coverage checking algorithm for OCaml. While
OCaml is a strict language, the algorithm claims to be general enough to handle
languages with non-strict semantics such as Haskell. However, we have found that
this algorithm actually handles laziness incorrectly.
\ryan{I need Sebastian to fill in the rest...}

\subsubsection{Elaborating dependent (co)pattern matching}

\citet{dependent-copattern} design a coverage checking algorithm for a dependently
typed language with both pattern matching and \emph{copattern} matching, which is
a feature that GHC lacks. While the source language for their algorithm is much more
sophisticated than GHC's, their algorithm is similar to \sysname in that it first
desugars definitions by clauses to \emph{case trees}. Case trees present a simplified
form of pattern matching that is easier to check for coverage, much like guard trees
in \sysname. Guard trees could take inspiration from case trees should a future
version of GHC add dependent types or copatterns.

\subsection{Positive and negative information}

\sysname's use of positive and negative constructor constraints inert sets is
inspired by \citet{sestoft1996ml}, which uses positive and negative information
to implement a pattern-match compiler for ML. Sestoft utilises positive and
negative information to generate decision trees that avoid
scrutinizing the same terms repeatedly. This insight is equally applicable to
coverage checking and is one of the primary reasons for \sysname's efficiency.
For instance, tracking negative constructor constraints allows \sysname
to check \extension{COMPLETE} sets while avoiding quadratic blowup
(\cref{ssec:residual-complete}).

Other coverage checkers for Haskell, such as those of
\citet{gadtpm} (\cref{ssec:gmtm})
and
\citet{maranget:warnings} (\cref{ssec:maranget}),
only track positive constructor constraints.
Not tracking negative constructor constraints makes them more susceptible
to \ryan{Bugs? Efficiency problems? Not sure how to best finish this
sentence...}
\sg{Moving a note from section 4 here for inspiration:

We need to brag about how this (with negative info) representation is better
than GMTMs. Example:

\begin{code}
data T = A1 | ... | A1000
f :: T -> T -> ()
f A1 _  = ()
f _  A1 = ()
\end{code}

This will split (a term which is introduced in \cref{sec:impl}) into a million
value vectors in GMTMs model, whereas there will only be ever fall through one
$\nabla$ from one equation to the next because of negative constraints.

Also GMTM comitting to a particular COMPLETE set the first time it splits on a
constructor pattern means buggy COMPLETE pragma handling. I think this
comparison should go into Related Work.}


\subsection{Refinement types in coverage checking}

In addition to \sysname, Liquid Haskell uses refinement types to perform a limited form of
exhaustivity checking \cite{liquidhaskell,refinement-reflection}.
While exhaustiveness checks are optional in ordinary
Haskell, they are mandatory for Liquid Haskell, as proofs written in Liquid
Haskell require user-defined functions to be total (and therefore exhaustive)
in order to be sound. For example, consider this non-exhaustive function:

\begin{code}
fibPartial :: Integer -> Integer
fibPartial 0 = 0
fibPartial 1 = 1
\end{code}

When compiled, GHC fills out this definition by adding an extra
|fibPartial _ = error "undefined"| clause.
Liquid Haskell leverages this by
giving |error| the refinement type:

\begin{code}
error :: { v:String | false } -> a
\end{code}

As a result, attempting to
use |fibPartial| in a proof will yield an inconsistent environment (and therefore
fail to verify) unless the user can
prove that |fibPartial| is only ever invoked with the arguments |0| or |1|.

\ryan{Other things from GMTM's related work?}

\section{Conclusion}

\TODO

\bibliography{references}

\end{document}
