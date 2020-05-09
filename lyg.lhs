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

%\documentclass[acmsmall,review,anonymous]{acmart}\settopmatter{printfolios=true,printccs=false,printacmref=false}
\documentclass[acmsmall]{acmart}\settopmatter{}

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
\usepackage{fancyvrb}  % for indentation in Verbatim
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

% Comment out to build the Appendix only
\newcommand*{\MAIN}{}
\ifdefined\MAIN

\begin{abstract}
One of a compiler's roles is to warn if a function defined by pattern matching
does not cover its inputs---that is, if there are missing or redundant
patterns. Generating such warnings accurately is difficult
for modern languages due to the myriad of interacting language features
when pattern matching. This is especially true in Haskell, a language with
a complicated pattern language that is made even more complex by extensions
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
\keywords{Haskell, pattern matching, guards, strictness}  %% \keywords are mandatory in final camera-ready submission

\section{Introduction}

Pattern matching is a tremendously useful feature in Haskell and many other
programming languages, but it must be used with care. Consider this
example of pattern matching gone wrong:

\begin{code}
f :: Int -> Bool
f 0 = True
f 0 = False
\end{code}
\noindent
The function |f| has two serious flaws. One obvious problem is that there
are two clauses that match on |0|, and due to the top-to-bottom semantics of
pattern matching, this makes the |f 0 = False| clause completely unreachable.
Even worse is that |f| never matches on any patterns besides |0|, making it not fully
defined. Attempting to invoke |f 1|, for instance, will fail.

To avoid these mishaps, compilers for languages with pattern matching often
emit warnings (or errors) if a function is missing clauses (i.e., if it is
\emph{non-exhaustive}), if one of its right-hand sides will never be entered
(i.e., if it is \emph{inaccessible}), or if one of its equations can be deleted
altogether (i.e., if it is \emph{redundant}). We refer to the combination of
checking for exhaustivity, redundancy, and accessibility as \emph{pattern-match
coverage checking}. Coverage checking is the first line of defence in catching
programmer mistakes when defining code that uses pattern matching.

Coverage checking for a set of equations matching on algebraic data
types is a well studied (although still surprisingly tricky) problem---see
\Cref{sec:related} for this related work.
But the coverage-checking problem becomes \emph{much} harder when one includes the
raft of innovations that have become part of a modern programming language
like Haskell, including: view patterns, pattern guards, pattern synonyms,
overloaded literals, bang patterns, lazy patterns, as-patterns, strict data constructors,
empty case expressions, and long-distance effects (\Cref{sec:extensions}).
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

The current state of the art for coverage checking in a richer language of this
sort is \emph{GADTs Meet Their Match} \cite{gadtpm}, or \gmtm{} for short. It
presents an algorithm that handles the intricacies of checking GADTs, lazy
patterns, and pattern guards. However \gmtm{} is monolithic and does not
account for a number of important language features; it gives incorrect results
in certain cases; its formulation in terms of structural pattern matching makes
it hard to avoid some serious performance problems; and its implementation in
GHC, while a big step forward over its predecessors, has proved complex and
hard to maintain.

In this paper we propose a new, compositional coverage-checking algorithm,
called Lower Your Guards (\lyg), that is simpler, more modular, \emph{and}
more powerful than \gmtm (see \cref{ssec:gmtm}). Moreover, it avoids \gmtm's
performance pitfalls. We make the following contributions:

\begin{itemize}
\item
  We characterise some nuances of coverage checking that not even
  \gmtm handles (\Cref{sec:problem}). We also identify issues in GHC's
  implementation of \gmtm.

\item
  We describe a new, compositional coverage checking algorithm, \lyg{}, in \Cref{sec:overview}.
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
  We demonstrate the compositionality of \lyg by augmenting it with
  several language extensions (\Cref{sec:extensions}). Although these extensions can change the source
  language in significant ways, the effort needed to incorporate them into the
  algorithm is comparatively small.

\item
  We discuss how to optimize the performance of \lyg (\Cref{sec:impl}) and
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
check that every function is exhaustive, \ie matches on every possible
combination of data constructors. Additionally, every equation must match
\emph{some} combination of data constructors, otherwise it is redundant.

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

Prior work on coverage checking (discussed in
\Cref{sec:related}) accounts for some of these nuances, but
not all of them. In this section we identify some key language features that
make coverage checking difficult. While these features may seem disparate at first,
we will later show in \Cref{sec:overview} that these ideas can all fit
into a unified framework.

\subsection{Guards} \label{ssec:guards}

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
\noindent
This function has four \emph{guarded right-hand sides} or GRHSs for short.
The first GRHS has a \emph{boolean guard}, |(c1 == 'a')|, that succeeds
if the expression in the guard returns |True|. The second GRHS has a \emph{pattern
guard}, |('b' <- c1)|, that succeeds if the pattern in the guard
successfully matches.
The next line illustrates that a GRHS may have multiple guards,
and that guards include |let| bindings, such as |let c1' = c2|.
The fourth GRHS uses |otherwise|, which is simply defined as |True|.

Guards can be thought of as a generalization of patterns, and we would like to
include them as part of coverage checking. Checking guards is significantly more
complicated than checking ordinary structural pattern matches, however, since guards can
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
inequalities. Clearly, coverage checking for guards is
undecidable in general. However, while we cannot accurately check \emph{all} uses of guards,
we can at least give decent warnings for some common use-cases.
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
not2 False  = True
not2 True   = False
\end{code}
\end{minipage}
\begin{minipage}{0.33\textwidth}
\centering
\begin{code}
not3 :: Bool -> Bool
not3 x | False <- x  = True
not3 True            = False
\end{code}
\end{minipage}
\end{minipage}
\noindent
Clearly all are equivalent.  Our coverage checking algorithm should find that all three
are exhaustive, and indeed, \lyg does so.
% We explore the subset of guards that
% \lyg can check in more detail in \ryan{Cite relevant section}\sg{I think
% that's mostly in Related Work? Not sure we give a detailed account anywhere}.

\subsection{Programmable patterns}

Expressions in guards are not the only source of undecidability that the
coverage checker must cope with. GHC extends the pattern language in other ways
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
matching. When a value |v| is matched against a view pattern |(f -> p)|, the
match is successful when |f v| successfully matches against the pattern |p|.
For example, one can use view patterns to succinctly define a function that
computes the length of Haskell's opaque |Text| data type:

\begin{code}
Text.null :: Text -> Bool   -- Checks if a Text is empty
Text.uncons :: Text -> Maybe (Char, Text)  -- If a Text is non-empty, return Just (x, xs),
                                           -- where x is the first character and xs is the rest

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

\noindent
% When compiled, a view pattern desugars into a pattern guard. The desugared version
% of |length|, for instance, would look like this:
%
% \begin{code}
% length' :: Text -> Int
% length' t  | True <- Text.null t            = True
%            | Just (_, xs) <- Text.uncons t  = False
% \end{code}
% \noindent
% As a result, any coverage-checking algorithm that can handle guards can also
% handle view patterns, provided that the view patterns desugar to guards that
% are not too complex.
Again, it would be unreasonable to expect a coverage checking algorithm to
prove that |length| is exhaustive, but one might hope for a coverage checking algorithm that handles
some common usage patterns.  For example, \lyg{} indeed \emph{is} able to
prove that |safeLast| function is exhaustive:
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
length (Cons _ xs) = 1 + length xs
\end{code}
\end{minipage}
\end{minipage}

The pattern synonym |Nil| matches everywhere the view pattern
|Text.null -> True| would match, and similarly for |Cons|.

How should a coverage checker handle pattern synonyms? One idea is to simply ``look
through'' the definitions of each pattern synonym and verify whether the underlying
patterns are exhaustive. This would be undesirable, however, because (1) we would
like to avoid leaking the implementation details of abstract pattern synonyms, and
(2) even if we \emph{did} look at the underlying implementation, it would be
challenging to automatically check that the combination of |Text.null| and
|Text.uncons| is exhaustive.

Nevertheless, |Text.null| and |Text.uncons| together are in fact exhaustive, and  GHC allows
programmers to communicate this fact to the coverage checker using
a \extension{COMPLETE} pragma
\cite{complete-users-guide}.
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
into extra strict evaluation by giving a data type strict fields, such as in
this example:

\begin{code}
data Void -- No data constructors; only inhabitant is bottom
data SMaybe a = SJust !!a | SNothing

v :: SMaybe Void -> Int
v SNothing   = 0
v (SJust _)  = 1   -- Redundant!
\end{code}
The ``!'' in the definition of |SJust| makes the constructor strict,
so $(|SJust|~ \bot) = \bot$.
Curiously, this makes the second equation of $v$ redundant!
Since $\bot$ is the only inhabitant of type |Void|, the only inhabitants of
|SMaybe Void| are |SNothing| and $\bot$.  The former will match on the first equation;
the latter will make the first equation diverge.  In neither case will execution
flow to the second equation, so it is redundant and can be deleted.

% Although \citet{gadtpm} incorporates strictness constraints into their algorithm,
% it does not consider constraints that arise from strict fields.

\subsubsection{Redundancy versus inaccessibility}
\label{sssec:inaccessibility}

When reporting unreachable cases, we must distinguish between \emph{redundant}
and \emph{inaccessible} cases. Redundant cases can be removed from a function
without changing its semantics, whereas inaccessible cases have semantic importance.
The examples below illustrate this:

\begin{minipage}{\textwidth}
\begin{minipage}{0.4\textwidth}
\centering
\begin{code}
u :: () -> Int
u ()   | False   = 1
       | True    = 2
u _              = 3
\end{code}
\end{minipage} %
\begin{minipage}{0.4\textwidth}
\centering
\begin{code}
u' :: () -> Int
u' ()   | False   = 1
        | False   = 2
u' _              = 3
\end{code}
\end{minipage}
\end{minipage}

Within |u|, the equations that return |1| and |3| could be deleted without
changing the semantics of |u|, so they are classified as redundant. Within |u'|,
one can never reach the right-hand sides of the equations that return |1| and |2|,
but they cannot be removed so easily. Using the
definition above, $|u'|~\bot~|=|~\bot$, but if the first two equations were removed,
then $|u'|~\bot~|= 3|$. As a result, \lyg warns that the first two equations in |u'| are
inaccessible, which suggests to the programmer that |u'| might benefit from
a refactor to avoid this (e.g., |u' () = 3|).

Observe that |u| and |u'| have completely different warnings, but the
only difference between the two functions is whether the second equation uses |True| or |False| in its guard.
Moreover, this second equation affects the warnings for \emph{other} equations.
This demonstrates that determining whether code is redundant or inaccessible
is a non-local problem.
Inaccessibility may seem like a tricky corner case, but GHC's users have
reported many bugs of this sort (\Cref{sec:ghc-issues}).

\subsubsection{Bang patterns}

Strict fields are one mechanism for adding extra strictness in ordinary Haskell, but
GHC adds another in the form of \emph{bang patterns}. A bang pattern
such as |!pat| indicates that matching a value $v$ against |pat| always evaluates $v$ to
weak-head normal form (WHNF). Here is a variant of $v$, this time using the standard, lazy |Maybe| data type:

\begin{code}
v' :: Maybe Void -> Int
v' Nothing = 0
v' (Just !_) = 1    -- Not redundant, but RHS is inaccessible
\end{code}
The inhabitants of the type |Maybe Void| are $\bot$, |Nothing|, and $(|Just|~\bot)$.
The input $\bot$ makes the first equation diverge; |Nothing| matches on the first equation;
and $(|Just|~\bot)$ makes the second equation diverge because of the bang pattern.
Therefore, none of the three inhabitants will result in the right-hand side of
the second equation being reached. Note that the second equation is inaccessible, but not redundant
(\cref{sssec:inaccessibility}).

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
also used to rule out cases made unreachable by type equalities, and \lyg
adopts a similar approach.
Besides GHC's current coverage checker \cite{gadtpm}, there are a variety of
other coverage checking algorithms that account for GADTs,
including those for OCaml \cite{ocamlgadts},
Dependent ML \cite{deadcodexi,xithesis,dependentxi}, and
Stardust \cite{dunfieldthesis}.
% \lyg continues this tradition---see
% \ryan{What section?}\sg{It's a little implicit at the moment, because it just works. Not sure what to reference here.} for \lyg's take on GADTs.

\begin{figure}
\centering
\[
\begin{array}{cc}
\textbf{Meta variables} & \textbf{Pattern syntax} \\
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

\caption{Source syntax: A desugared Haskell}
\label{fig:srcsyn}
\end{figure}


\section{Lower Your Guards: a new coverage checker}
\label{sec:overview}

\begin{figure}
\includegraphics{pipeline.pdf}
\caption{Bird's eye view of pattern match checking}
\label{fig:pipeline}
\end{figure}

\begin{figure}
\centering
\[ \textbf{Guard syntax} \]
\[
\begin{array}{cc}
\begin{array}{rlcl}
  k,n,m       \in &\mathbb{N}&    & \\
  K           \in &\Con &         & \\
  x,y,a,b     \in &\Var &         & \\
  \tau,\sigma \in &\Type&         & \\
  e \in           &\Expr&\Coloneqq& x \\
                  &     &\mid     & \genconapp{K}{\tau}{\gamma}{e} \\
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

\[ \textbf{Refinement type syntax} \]
\[
\begin{array}{rcll}
  \Gamma &\Coloneqq& \varnothing \mid \Gamma, x:\tau \mid \Gamma, a & \text{Context} \\
  \varphi &\Coloneqq& \true \mid \false \mid \ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x} \mid x \ntermeq K \mid x \termeq \bot \mid x \ntermeq \bot \mid \ctlet{x}{e} & \text{Literals} \\
  \Phi &\Coloneqq& \varphi \mid \Phi \wedge \Phi \mid \Phi \vee \Phi & \text{Formula} \\
  \Theta &\Coloneqq& \reft{\Gamma}{\Phi} & \text{Refinement type} \\
\end{array}
\]

\[ \textbf{Clause tree syntax} \]
\[
\begin{array}{rcll}
  t \in \Gdt &\Coloneqq& \gdtrhs{n} \mid \gdtseq{t_1}{t_2} \mid \gdtguard{g}{t}         \\
  u \in \Ant &\Coloneqq& \antrhs{\Theta}{n} \mid \antseq{u_1}{u_2} \mid \antbang{\Theta}{u} \\
\end{array}
\]

\[ \textbf{Graphical notation} \]
\[
\begin{array}{cc}
  \begin{array}{rcll}
    \vcenter{\hbox{\begin{forest}
      grdtree,
      for tree={delay={edge={-}}},
      [ [{$t_1$}] [{$t_2$}] ]
    \end{forest}}} & \Coloneqq & \gdtseq{t_1}{t_2} \\
    \vcenter{\hbox{\begin{forest}
      grdtree,
      for tree={delay={edge={-}}},
      [ {$g_1, ...\;, g_n$} [{$t$}] ]
    \end{forest}}} & \Coloneqq & \gdtguard{g_1}{...\; (\gdtguard{g_n}{t})} \\
    \vcenter{\hbox{\begin{forest}
      grdtree,
      [ [{$n$}] ]
    \end{forest}}} & \Coloneqq & \gdtrhs{n} \\
  \end{array}&
  \begin{array}{rcll}
    \vcenter{\hbox{\begin{forest}
      anttree,
      for tree={delay={edge={-}}},
      [ [{$u_1$}] [{$u_2$}] ]
    \end{forest}}} & \Coloneqq & \antseq{u_1}{u_2} \\
    \vcenter{\hbox{\begin{forest}
      anttree,
      for tree={delay={edge={-}}},
      [{$\Theta$\,\lightning} [{$u$}] ]
    \end{forest}}} & \Coloneqq & \antbang{\Theta}{u} \\
    \vcenter{\hbox{\begin{forest}
      anttree,
      [ [{$\Theta$\,$n$}] ]
    \end{forest}}} & \Coloneqq & \antrhs{\Theta}{n} \\
  \end{array}
\end{array}
\]

\caption{IR syntax}
\label{fig:syn}
\end{figure}

In this section, we describe our new coverage checking algorithm, \lyg.
\Cref{fig:pipeline} depicts a high-level overview, which divides into three steps:
\begin{itemize}
\item First, we desugar the complex source Haskell syntax (\cf \cref{fig:srcsyn})
  into a \emph{guard tree} $t:\Gdt$ (\Cref{sec:desugar}).
  The language of guard trees is tiny but expressive, and allows the subsequent passes to be entirely
  independent of the source syntax.
  \lyg{} can readily be adapted to other languages simply by changing the desugaring
    algorithm.
\item Next, the resulting guard
  tree is then processed by two different functions (\Cref{sec:check}).   The function $\ann(t)$ produces
  an \emph{annotated tree} $u : \Ant$, which has the same general branching structure as $t$ but
  describes which clauses are accessible, inaccessible, or redundant.
  The function $\unc(t)$, on the other hand, returns a \emph{refinement type} $\Theta$
  \cite{rushby1998subtypes,boundschecking}
  that describes the set of \emph{uncovered values}, which are not matched by any of the clauses.
\item Finally, an error-reporting pass generates comprehensible error messages (\Cref{sec:inhabitants}).
  Again there are two things to do.
  The function $\red$ processes the annotated tree produced by $\ann$ to explicitly identify the
  accessible, inaccessible, or redundant clauses.
  The function $\generate(\Theta)$ produces representative \emph{inhabitants}
  of the refinement type $\Theta$ (produced by $\unc$) that describes the
  uncovered values.
\end{itemize}

\lyg's main contribution when compared to other coverage checkers, such as
GHC's implementation of \gmtm, is its incorporation of many small improvements
and insights, rather than a single defining breakthrough. In particular, \lyg's
advantages are:

\begin{itemize}
  \item
    Correctly accounting for strictness in identifying redundant and inaccessible
    code (\cref{ssec:strict-fields}).

  \item
    Using detailed term-level reasoning
    (\cref{fig:gen,fig:add,fig:inh}),
    which \gmtm does not.

  \item
    Using \emph{negative information} to sidestep serious performance issues in
    \gmtm without changing the worst-case complexity (\cref{ssec:negative-information}).
    This also enables
    graceful degradation (\cref{ssec:throttling})
    and the ability to handle \extension{COMPLETE}
    sets properly (\cref{ssec:residual-complete}).

  \item
    Achieving modularity by clearly separating the source syntax (\cref{fig:srcsyn})
    from the intermediate language (\cref{fig:syn}).

  \item
    Fixing various bugs present in \gmtm, both in the paper \cite{gadtpm} and
    in GHC's implementation thereof (\cref{sec:ghc-issues}).

\end{itemize}


\subsection{Desugaring to guard trees} \label{sec:desugar}

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
    [ [{$\ds(x_1, pat_1)\,...\,\ds(x_n, pat_n)$} [{$k_{rhs}$}] ] ]
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
\ds(pat \leftarrow expr) &=& \grdlet{x}{expr}, \ds(x, pat) \\
\ds(expr) &=& \grdlet{y}{expr}, \ds(y, |True|) \\
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
\caption{Desugaring from source language to $\Gdt$}
\label{fig:desugar}
\end{figure}

The first step is to desugar the source language into the language of guard
trees. The syntax of the source language is given in \Cref{fig:srcsyn}.
Definitions $\mathit{defn}$ consist of a list of $\mathit{clauses}$, each of
which has a list of \emph{patterns}, and a list of \emph{guarded right-hand
sides} (GRHSs). Patterns include variables and constructor patterns, of course,
but also a representative selection of extensions: wildcards, as-patterns, bang
patterns, and view patterns. We explore several other extensions in
\Cref{sec:extensions}.

The language of guard trees $\Gdt$ is much smaller; its syntax is given in \Cref{fig:syn}.
All of the syntactic redundancy of the source language is translated
into a minimal form very similar to pattern guards.  We start with an example:

\begin{code}
f (Just (!xs,_))  ys@Nothing   = 1
f Nothing         (g -> True)  = 2
\end{code}

\noindent
This desugars to the following guard tree:

\begin{forest}
  grdtree,
  [
    [{$\grdbang{x_1}, \grdcon{|Just t_1|}{x_1}, \grdbang{t_1}, \grdcon{(t_2, t_3)}{t_1}, \grdbang{t_2}, \grdlet{xs}{t_2}, \grdlet{ys}{x_2}, \grdbang{ys}, \grdcon{|Nothing|}{ys}$} [1]]
    [{$\grdbang{x_1}, \grdcon{|Nothing|}{x_1}, \grdlet{t_3}{|g x_2|}, \grdbang{y}, \grdcon{|True|}{t_3}$} [2]]]
\end{forest}
\\
Here we use a graphical syntax for guard trees, also defined in \Cref{fig:syn}.
The first line says ``evaluate $x_1$; then match $x_1$ against $Just~ t_1$;
then evaluate $t_1$; then match $t_1$ against $(t_2,t_3)$; and so on''. If any
of those matches fail, we fall through into the second line.

More formally, matching a guard tree may \emph{succeed} (with some bindings for
the variables bound in the tree), \emph{fail}, or \emph{diverge}.  Matching is
defined as follows:
\begin{itemize}
\item Matching a guard tree $(\gdtrhs{n})$ succeeds.
\item Matching a guard tree $(\gdtseq{t_1}{t_2})$ means matching against $t_1$;
  if that succeeds, the overall match succeeds; if not, match against $t_2$.
\item Matching a guard tree $(\gdtguard{\grdbang{x}}{t})$ evaluates $x$;
  if that diverges the match diverges; if not match $t$.
\item Matching a guard tree $(\gdtguard{(\grdcon{|K|~ y_1 \ldots y_n}{x})}{t})$
  matches $x$ against constructor |K|. If the match succeeds, bind $y_1 \ldots
  y_n$ to the components, and match $t$; if the constructor match fails, then the
  entire match fails.
\item Matching a guard tree $(\gdtguard{(\grdlet{x}{e})}{t})$ binds $x$
  (lazily) to $e$, and matches $t$.
\end{itemize}
The desugaring algorithm, $\ds$, is given in \Cref{fig:desugar}.
It is a straightforward recursive descent over the source syntax, with a little
bit of administrative bureaucracy to account for renaming.
It also generates an abundance of fresh
temporary variables; in practice, the implementation of $\ds$ can be smarter
than this by looking at the pattern (which might be a variable match or
as-pattern) when choosing a name for a temporary variable.

% It is assumed that the top-level match variables
% $x_1$ through $x_n$ in the $clause$ cases have special, fixed names. All other
% variables that aren't bound in arguments to $\ds$ have fresh names.

Notice that both ``structural'' pattern-matching in the source language (e.g.
the match on |Nothing| in the second equation), and view patterns (e.g. |g -> True|)
can readily be compiled to a single form of matching in guard trees.
The same holds for pattern guards.  For example, consider this (stylistically contrived) definition
of |liftEq|, which is inexhaustive:
\begin{code}
liftEq Nothing  Nothing   =  True
liftEq mx       (Just y)  |  Just x <- mx, x == y  = True
                          |  otherwise             = False
\end{code}
\noindent
It desugars thus:

\begin{forest}
  grdtree
  [
    [{$\grdbang{mx},\, \grdcon{\mathtt{Nothing}}{mx},\, \grdbang{my},\, \grdcon{\mathtt{Nothing}}{my}$} [1]]
    [{$\grdbang{my},\, \grdcon{\mathtt{Just}\;y}{my}$}
     [{$ \grdbang{mx},\, \grdcon{\mathtt{Just}\;x}{mx},\, \grdlet{t}{|x == y|},\, \grdbang{t},\, \grdcon{\mathtt{True}}{t}$} [2]]
      [{$\grdbang{otherwise},\, \grdcon{\mathtt{True}}{otherwise}$} [3]]]]
\end{forest}

\noindent
Notice that the pattern guard |(Just x <- mx)| and the
boolean guard |(x == y)| have both turned into the same constructor-matching
construct in the guard tree.

In a way there is nothing very deep here, but it took us a surprisingly long
time to come up with the language of guard trees.  We recommend it!

%
% To understand what language we should desugar to, consider the following
% attempt at lifting equality over \hs{Maybe}:
%
% \begin{code}
% liftEq Nothing  Nothing  = True
% liftEq (Just x) (Just y)
%   | x == y          = True
%   | otherwise       = False
% \end{code}
% \noindent
% |liftEq| has two equations, the second of which defines two GRHSs.
% However, the definition is non-exhaustive:
% neither equation will match the call |liftEq (Just 1) Nothing|, leading to
% a crash.
% To see this, we can follow Haskell's top-to-bottom, left-to-right pattern match
% semantics. The first equation fails to match |Just 1| against |Nothing|, while
% the second equation successfully matches |1| with |x| but then fails trying to
% match |Nothing| against |Just y|. There is no third equation, and the
% \emph{uncovered} tuple of values |(Just 1) Nothing| that falls out at the
% bottom of this process will lead to a crash.
%
% Compare that to matching on |(Just 1) (Just 2)|: While matching against the first
% equation fails, the second matches |x| to |1| and |y| to |2|. Since there are
% multiple GRHSs, each of them in turn has to be tried in a top-to-bottom
% fashion. The first GRHS consists of a single boolean guard (in general we have
% to consider each of them in a left-to-right fashion) that will fail because |1
% /= 2|. The second GRHS is tried next, and because |otherwise| is a
% boolean guard that never fails, this successfully matches.
%
% Note how both the pattern matching per clause and the guard checking within a
% syntactic $match$ share top-to-bottom and left-to-right semantics. Having to
% make sense of both pattern and guard semantics seems like a waste of energy.
% Perhaps we can express \emph{all} pattern matching by (nested) pattern guards, thus:
% \begin{code}
% liftEq mx my
%   | Nothing <- mx, Nothing <- my              = True
%   | Just x <- mx,  Just y <- my  | x == y     = True
%                                  | otherwise  = False
% \end{code}
% Transforming the first clause with its single GRHS is easy. But the second
% clause already has two GRHSs, so we need to use \emph{nested} pattern guards.
% This is not a feature that Haskell offers (yet), but it allows a very
% convenient uniformity for our purposes: after the successful match on the first
% two guards left-to-right, we try to match each of the GRHSs in turn,
% top-to-bottom (and their individual guards left-to-right).
%
% Hence \lyg desugars the source syntax to the following \emph{guard
% tree} (see \cref{fig:syn} for the syntax):
%
% \begin{forest}
%   grdtree
%   [
%     [{$\grdbang{mx},\, \grdcon{\mathtt{Nothing}}{mx},\, \grdbang{my},\, \grdcon{\mathtt{Nothing}}{my}$} [1]]
%     [{$\grdbang{mx},\, \grdcon{\mathtt{Just}\;x}{mx},\, \grdbang{my},\, \grdcon{\mathtt{Just}\;y}{my}$}
%       [{$\grdlet{t}{|x == y|},\, \grdbang{t},\, \grdcon{\mathtt{True}}{t}$} [2]]
%       [{$\grdbang{otherwise},\, \grdcon{\mathtt{True}}{otherwise}$} [3]]]]
% \end{forest}
%
% This representation is much more explicit than the original program. For
% one thing, every source-level pattern guard is implicitly strict in its scrutinee,
% whereas that is made explicit in the guard tree by \emph{bang guards}, e.g. $\grdbang{mx}$.
% The bang guard $\grdbang{mx}$ evaluates $mx$ to WHNF, and will
% either succeed or diverge. Moreover, the pattern guards in $\Grd$ only
% scrutinise variables, and only one level deep, so the comparison in the
% boolean guard's scrutinee had to be bound to an auxiliary variable in a let
% binding.
%
% % \ryan{|otherwise| was introduced earlier, so commenting this out.}
% % Note that |otherwise| is an external identifier which we can assume to
% % be bound to |True|, which is in fact how it defined.
%
% Pattern guards in $\Grd$ are the only guards that can possibly fail to match,
% in which case the value of the scrutinee was not of the shape of the
% constructor application it was matched against. The $\Gdt$ tree language
% determines how to cope with a failed guard. Left-to-right matching semantics is
% captured by $\gdtguard{}{\hspace{-0.6em}}$, whereas top-to-bottom backtracking
% is expressed by sequence ($\gdtseq{}{}$). The leaves in a guard tree each
% correspond to a GRHS.

\subsection{Checking guard trees} \label{sec:check}

\begin{figure}
\[ \textbf{Operations on $\Theta$} \]
\[
\begin{array}{lcl}
\reft{\Gamma}{\Phi} \andtheta \varphi &=& \reft{\Gamma}{\Phi \wedge \varphi} \\
\reft{\Gamma}{\Phi_1} \uniontheta \reft{\Gamma}{\Phi_2} &=& \reft{\Gamma}{\Phi_1 \vee \Phi_2} \\
\end{array}
\]

\[ \textbf{Checking guard trees} \]
\[ \ruleform{ \unc(\Theta, t) = \Theta } \]
\[
\begin{array}{lcl}
\unc(\reft{\Gamma}{\Phi}, \gdtrhs{n}) &=& \reft{\Gamma}{\false} \\
\unc(\Theta, \gdtseq{t_1}{t_2}) &=& \unc(\unc(\Theta, t_1), t_2) \\
\unc(\Theta, \gdtguard{(\grdbang{x})}{t}) &=& \unc(\Theta \andtheta (x \ntermeq \bot), t) \\
\unc(\Theta, \gdtguard{(\grdlet{x}{e})}{t}) &=& \unc(\Theta \andtheta (\ctlet{x}{e}), t) \\
\unc(\Theta, \gdtguard{(\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{t}) &=& (\Theta \andtheta (x \ntermeq K)) \uniontheta \unc(\Theta \andtheta (\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}), t) \\
\end{array}
\]
\[ \ruleform{ \ann(\Theta, t) = u } \]
\[
\begin{array}{lcl}
\ann(\Theta,\gdtrhs{n}) &=& \antrhs{\Theta}{n} \\
\ann(\Theta, (\gdtseq{t_1}{t_2})) &=& \antseq{\ann(\Theta, t_1)}{\ann(\unc(\Theta, t_1), t_2)} \\
\ann(\Theta, \gdtguard{(\grdbang{x})}{t}) &=& \antbang{(\Theta \andtheta (x \termeq \bot))}{\ann(\Theta \andtheta (x \ntermeq \bot), t)} \\
\ann(\Theta, \gdtguard{(\grdlet{x}{e})}{t}) &=& \ann(\Theta \andtheta (\ctlet{x}{e}), t) \\
\ann(\Theta, \gdtguard{(\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{t}) &=& \ann(\Theta \andtheta (\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}), t) \\
\end{array}
\]

\caption{Coverage checking}
\label{fig:check}
\end{figure}

In the next step, we transform the guard tree into an \emph{annotated tree}, $\Ant$, and
an \emph{uncovered set}, $\Theta$.

Taking the latter first, the uncovered set describes all the input
values of the match that are not covered by the match.  We use the
language of \emph{refinement types} to describe this set (see \Cref{fig:syn}).
The refinement type $\Theta = \reft{x_1{:}\tau_1, \ldots, x_n{:}\tau_n}{\Phi}$
denotes the vector of values $x_1 \ldots x_n$ that satisfy the predicate $\Phi$.
For example:
$$
\begin{array}{rcl}
  \reft{ x{:}|Bool|}{ \true } & \text{denotes} & \{ \bot, |True|, |False| \} \\
  \reft{ x{:}|Bool|}{ x \ntermeq \bot } & \text{denotes} & \{ |True|, |False| \} \\
  \reft{ x{:}|Bool|}{ \ctcon{|True|}{x} } & \text{denotes} & \{ |True| \} \\
  \reft{ mx{:}|Maybe Bool|}{ \ctcon{|Just x|}{mx}, x \ntermeq \bot } & \text{denotes} & \{ |Just True|, |Just False| \} \\
\end{array}
$$
The syntax of $\Phi$ is given in \Cref{fig:syn}. It consists of a collection
of literals $\varphi$, combined with conjunction and disjunction.
Unconventionally, however, a literal may bind one or more variables, and those
bindings are in scope in conjunctions to the right. This can readily be formalised
by giving a type system for $\Phi$, but we omit that here. \simon{It would be nice to add it.}
The literal $\true$ means ``true'', as illustrated above; while
$\false$ means ``false'', so that $\reft{\Gamma}{\false}$ denotes $\emptyset$.

The uncovered set function $\unc(\Theta, t)$, defined in \Cref{fig:check},
computes a refinement type describing the values in $\Theta$ that are not
covered by the guard tree $t$.  It is defined by a simple recursive descent
over the guard tree, using the operation $\Theta \andtheta \varphi$ (also
defined in \Cref{fig:check}) to extend $\Theta$ with an extra literal
$\varphi$.

While $\unc$ finds a refinement type describing values that are \emph{not} matched by a
guard tree, the function $\ann$ finds refinements describing values that
\emph{are} matched by a guard tree, or that cause matching to diverge.
It does so by producing an \emph{annotated tree}, whose syntax is given in \Cref{fig:syn}.
An annotated tree has the same general structure as the guard tree from whence it came:
in particular the top-to-bottom compositions ``;'' are in the same places.  But
in an annotated tree, each \texttt{Rhs} leaf is annotated with a refinement type
describing the input values that will lead to that right-hand side; and each
$\antbang{}{\hspace{-0.6em}}$ node is annotated with a refinement type that describes
the input values on which matching will diverge.  Once again, $\ann$ can
be defined by a simple recursive descent over the guard tree (\Cref{fig:check}), but note
that the second equation uses $\unc$ as an auxiliary function\footnote{
Our implementation avoids this duplicated work -- see \Cref{ssec:interleaving}
-- but the formulation in \Cref{fig:check} emphasises clarity over efficiency.}.

% Coverage checking works by gradually refining the set of reaching values
% \ryan{Did you mean to write ``reachable values'' here? ``Reaching values''
% reads strangely to me.}
% \sg{I was thinking ``reaching values'' as in ``reaching definitions'': The set
% of values that reach that particular piece of the guard tree.}
% as they flow through the guard tree until it produces two outputs.
% One output is the set of uncovered values that wasn't covered by any clause,
% and the other output is an annotated guard tree skeleton
% $\Ant$ with the same shape as the guard tree to check, capturing redundancy and
% divergence information.
%
% For the example of |liftEq|'s guard tree $t_|liftEq|$, we represent the set of
% values reaching the first clause by the \emph{refinement type} $\Theta_0 = \reft{(mx :
% |Maybe a|, my : |Maybe a|)}{\true}$.   Refinement types are described in \cref{fig:syn}.
% This type  is gradually refined until finally we have $\Theta_{|liftEq|} :=
% \reft{(mx : |Maybe a|, my : |Maybe a|)}{\Phi}$ as the uncovered set, where the
% predicate $\Phi$ is semantically equivalent to:
% \[
% \begin{array}{cl}
%          & (mx \ntermeq \bot \wedge (mx \ntermeq \mathtt{Nothing} \vee (\ctcon{\mathtt{Nothing}}{mx} \wedge my \ntermeq \bot \wedge my \ntermeq \mathtt{Nothing}))) \\
%   \wedge & (mx \ntermeq \bot \wedge (mx \ntermeq \mathtt{Just} \vee (\ctcon{\mathtt{Just}\;x}{mx} \wedge my \ntermeq \bot \wedge (my \ntermeq \mathtt{Just})))) \\
% \end{array}
% \]
%
% Every $\vee$ disjunct corresponds to one way in which a pattern guard in the
% tree could fail. It is not easy for humans to read off inhabitants
% from this representation, but we will give an intuitive treatment of how
% to do so in the next subsection.
%
% The annotated guard tree skeleton corresponding to $t_|liftEq|$ looks like
% this:
%
% \begin{forest}
%   anttree
%   [
%     [{\lightning}
%       [1]
%       [{\lightning}
%         [{\lightning} [2]]
%         [{\lightning} [3]]]]]
% \end{forest}
%
% A GRHS is deemed accessible (\checked{}) whenever there is a non-empty set of
% values reaching it. For the first GRHS, the set that reaches it looks
% like $\{ (mx, my) \mid mx \ntermeq \bot, \grdcon{\mathtt{Nothing}}{mx}, my
% \ntermeq \bot, \grdcon{\mathtt{Nothing}}{my} \}$, which is inhabited by
% $(\mathtt{Nothing}, \mathtt{Nothing})$. Similarly, we can find inhabitants for
% the other two clauses.
%
% A \lightning{} denotes possible divergence in one of the bang guards and
% involves testing the set of reaching values for compatibility with \ie $mx
% \termeq \bot$. We cannot know in advance whether $mx$, $my$ or $t$ are
% $\bot$ (hence the three uses of
% \lightning{}), but we can certainly rule out $otherwise \termeq \bot$ simply by
% knowing that it is defined as |True|. But since all GRHSs are accessible,
% there is nothing to report in terms of redundancy and the \lightning{}
% decorators are irrelevant.
%
% Perhaps surprisingly and most importantly, $\Grd$ with its three primitive
% guards, combined with left-to-right or top-to-bottom semantics in $\Gdt$, is
% expressive enough to express all pattern matching in Haskell (cf. the
% desugaring function $\ds$ in \cref{fig:desugar})! We have yet to find a
% language extension that does not fit into this framework.

%%%%%%%%
%% Ryan: commented out since this now exists in a different form earlier in the paper
%% (see sssec:inaccessibility)
%%%%%%%%
%
% \subsubsection{Why do we not report redundant GRHSs directly?}
%
% Why not compute the redundant GRHSs directly instead of building up a whole new
% tree? Because determining inaccessibility \vs redundancy is a non-local
% problem. Consider this example and its corresponding annotated tree after
% checking:
% \sg{I think this kind of detail should be motivated in a prior section and then
% referenced here for its solution.}
%
% \begin{minipage}{\textwidth}
% \begin{minipage}{0.22\textwidth}
% \centering
% \begin{code}
% g :: () -> Int
% g ()   | False   = 1
%        | True    = 2
% g _              = 3
% \end{code}
% \end{minipage}%
% \begin{minipage}{0.05\textwidth}
% \centering
% \[ \leadsto \]
% \end{minipage}%
% \begin{minipage}{0.2\textwidth}
% \centering
% \begin{forest}
%   anttree
%   [
%     [{\lightning}
%       [1]
%       [2]]
%     [3]]
% \end{forest}
% \end{minipage}
% \end{minipage}
%
% Is the first GRHS just inaccessible or even redundant? Although the match on
% |()| forces the argument, we can delete the first GRHS without changing program
% semantics, so clearly it is redundant.
% But that wouldn't be true if the second GRHS wasn't there to ``keep alive'' the
% |()| pattern!
%
% In general, at least one GRHS under a \lightning{} may not be flagged as
% redundant ($\times$).
% Thus the checking algorithm can't decide which GRHSs are redundant (\vs just
% inaccessible) when it reaches a particular GRHS.

\subsection{Reporting errors} \label{sec:inhabitants}


\begin{figure}
\centering
\[ \textbf{Collect accessible $(\overline{k})$, inaccessible $(\overline{n})$ and redundant $(\overline{m})$ GRHSs} \]
\[ \ruleform{ \red(u) = (\overline{k}, \overline{n}, \overline{m}) } \]
\[
\begin{array}{lcl}
\red(\antrhs{\Theta}{n}) &=& \begin{cases}
    (\epsilon, \epsilon, n), & \text{if $\generate(\Theta) = \emptyset$} \\
    (n, \epsilon, \epsilon), & \text{otherwise} \\
  \end{cases} \\
\red(\antseq{t}{u}) &=& (\overline{k}\,\overline{k'}, \overline{n}\,\overline{n'}, \overline{m}\,\overline{m'}) \hspace{0.5em} \text{where} \begin{array}{l@@{\,}c@@{\,}l}
    (\overline{k}, \overline{n}, \overline{m}) &=& \red(t) \\
    (\overline{k'}, \overline{n'}, \overline{m'}) &=& \red(u) \\
  \end{array} \\
\red(\antbang{\Theta}{t}) &=& \begin{cases}
    (\epsilon, m, \overline{m'}), & \text{if $\generate(\Theta) \not= \emptyset$ and $\red(t) = (\epsilon, \epsilon, m\,\overline{m'})$} \\
    \red(t), & \text{otherwise} \\
  \end{cases} \\
\end{array}
\]

\[ \textbf{Normalised refinement type syntax} \]
\[
\begin{array}{rcll}
  \nabla &\Coloneqq& \false \mid \nreft{\Gamma}{\Delta} & \text{Normalised refinement type} \\
  \Delta &\Coloneqq& \varnothing \mid \Delta,\delta & \text{Set of constraints} \\
  \delta &\Coloneqq& \gamma \mid x \termeq \deltaconapp{K}{a}{y} \mid x \ntermeq K \mid x \termeq \bot \mid x \ntermeq \bot \mid x \termeq y & \text{Constraints} \\
\end{array}
\]

\[ \textbf{Generate inhabitants of $\Theta$} \]
\[ \ruleform{ \generate(\Theta) = \mathcal{P}(\overline{p}) } \]
\[
\begin{array}{c}
   \generate(\reft{\Gamma}{\Phi}) = \left\{ \expand(\nabla, \mathsf{dom}(\Gamma)) \mid \nabla \in \construct(\nreft{\Gamma}{\varnothing}, \Phi) \right\}
\end{array}
\]

\[ \textbf{Construct inhabited $\nabla$s from $\Phi$} \]
\[ \ruleform{ \construct(\nabla, \Phi) = \mathcal{P}(\nabla) } \]
\[
\begin{array}{lcl}

  \construct(\nabla, \varphi) &=& \begin{cases}
    \left\{ \nreft{\Gamma'}{\Delta'} \right\} & \text{where $\nreft{\Gamma'}{\Delta'} = \nabla \addphi \varphi$} \\
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
  \expand(\nreft{\Gamma}{\Delta}, x_1 ... x_n) &=& \begin{cases}
    (K \; q_1 ... q_m) \, p_2 ... p_n & \parbox[t]{0.5\textwidth}{if $\rep{\Delta}{x_1} \termeq \deltaconapp{K}{a}{y} \in \Delta$\\ and $(q_1 ... q_m \, p_2 ... p_n) = \expand(\nreft{\Gamma}{\Delta}, y_1 ... y_m x_2 ... x_n)$} \\
    \_ \; p_2 ... p_n & \text{where $(p_2 ... p_n) = \expand(\nreft{\Gamma}{\Delta}, x_2 ... x_n)$} \\
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

The final step is to report errors.  First, let us focus on reporting
missing equations.  Consider the following definition
\begin{code}
  data T = A | B | C
  f (Just A) = True
\end{code}
If $t$ is the guard tree obtained from $f$, the expression
$\unc(\reft{x:|Maybe T|}{\true},t)$ will produce this refinement type
describing values that are not matched:
$$
\Theta_f = \reft{ x{:}|Maybe T| }
  { x \ntermeq \bot \wedge (x \ntermeq |Just| \vee (\ctcon{|Just y|}{x} \wedge |y| \ntermeq \bot \wedge (|y| \ntermeq |A| \vee (\ctcon{|A|}{|y|} \wedge \false)))) }
$$

But this is not very helpful to report to the user. It would be far preferable
to produce one or more concrete \emph{inhabitants} of $\Theta_f$ to report, something like this:
\begin{Verbatim}
    Missing equations for function 'f':
      f Nothing  = ...
      f (Just B) = ...
      f (Just C) = ...
\end{Verbatim}
Producing these inhabitants is done by $\generate(\Theta)$ in \Cref{fig:gen},
which we discuss next in \Cref{sec:generate}.
But before doing so, notice that the very same function $\generate$ allows
us to report accessible, inaccessible, and redundant GRHSs.  The function $\red$,
also defined in \Cref{fig:gen} does exactly this, returning a
triple of (accessible, inaccessible, redundant) GRHSs:
\begin{itemize}
\item Having reached a leaf $\antrhs{\Theta}{n}$, if the refinement type $\Theta$ is
  uninhabited ($\generate(\Theta) = \emptyset$), then no input values can cause execution to reach this right-hand side,
  and it is redundant.
\item Having reached a node $\antbang{\Theta}{t}$, if $\Theta$ is inhabited there is a possibility of
  divergence. Now suppose that all the GRHSs in $t$ are redundant.  Then we should pick the first
  of them and mark it as inaccessible.
\item The case for $\red(t;u)$ is trivial: just combine the classifications of $t$ and $u$.
\end{itemize}
To illustrate the second case consider |u'| from \cref{sssec:inaccessibility} and its annotated tree:

\begin{minipage}{\textwidth}
\begin{minipage}{0.22\textwidth}
\centering
\begin{code}
  u' ()  | False  = 1
         | False  = 2
  u' _            = 3
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
    [{$\Theta_1$\,\lightning}
      [{$\Theta_2$\,1}]
      [{$\Theta_3$\,2}]]
    [{$\Theta_4$\,3}]]
\end{forest}
\end{minipage}
\end{minipage}

$\Theta_2$ and $\Theta_3$ are uninhabited (because of the
|False| guards). But we cannot delete both GRHSs as redundant,
because that would make the call |u' bot| return 3 rather
than diverging.  Rather, we want to report the first GRHSs as
inaccessible, leaving all the others as redundant.

\subsection{Generating inhabitants of a refinement type} \label{sec:generate}

Thus far, all our functions have been very simple, syntax-directed
transformations, but they all ultimately depend on the single function
$\generate$, which does the real work.  That is our new focus.
As \Cref{fig:gen} shows, $\generate(\Theta)$ takes a refinement
type $\Theta = \reft{\Gamma}{\Phi}$
and returns a (possibly-empty) set of patterns $\overline{p}$ (syntax in \Cref{fig:syn})
that give the shape of values that inhabit $\Theta$.
We do this in two steps:
\begin{itemize}
\item Flatten $\Theta$ into a set of \emph{normalised refinement types} $\nabla$,
  by the call $\construct(\nreft{\Gamma}{\varnothing}, \Phi)$; see \Cref{sec:normalise}.
\item For each such $\nabla$, expand $\Gamma$ into a list of patterns, by the call
  $\expand(\nabla, \mathsf{dom}(\Gamma))$; see \Cref{sec:expand}.
\end{itemize}
A normalised refinement type $\nabla$ is either empty ($\false$) or of the form
$\nreft{\Gamma}{\Delta}$. It is similar to a refinement type $\Theta =
\reft{\Gamma}{\Phi}$, but is in a much more restricted form:
\begin{itemize}
\item $\Delta$ is simply a conjunction of literals $\delta$; there are no disjunctions.
  Instead, disjunction reflects in the fact that $\construct$ returns a \emph{set} of normalised refinement types.
\end{itemize}
Beyond these syntactic differences, we enforce the following semantic invariants on a $\nabla = \nreft{\Gamma}{\Delta}$:
\begin{enumerate}
  \item[\inv{1}] \emph{Mutual compatibility}: No two constraints in $\Delta$
    should \emph{conflict} with each other, where $x \termeq \bot$ conflicts with
    $x \ntermeq \bot$ and $x \termeq K \; \mathunderscore \; \mathunderscore$
    conflicts with $x \ntermeq K$ for all $x$.
  \item[\inv{2}] \emph{Triangular form}: A $x \termeq y$ constraint implies
    absence of any other constraints mentioning |x| in its left-hand side.
  \item[\inv{3}] \emph{Single solution}: There is at most one positive
    constructor constraint $x \termeq \deltaconapp{K}{a}{y}$ for a given |x|.
  \item[\inv{4}] \emph{Incompletely matched}: If $x{:}\tau \in \Gamma$ and $\tau$
  reduces to a data type under type constraints in $\Delta$, there must be at
  least one constructor $K$ (or $\bot$) which $x$ can be instantiated to without
  contradicting \inv{1}; see \Cref{sec:inhabitation}.
\end{enumerate}
\noindent
It is often helpful to think of a $\Delta$ as a partial function from |x| to
its \emph{solution}, informed by the single positive constraint $x \termeq
\deltaconapp{K}{a}{y} \in \Delta$, if it exists. For example, $x \termeq
|Nothing|$ can be understood as a function mapping |x| to |Nothing|. This
reasoning is justified by \inv{3}. Under this view, $\Delta$ looks like a
substitution. As we'll see in \cref{sec:normalise}, this view is
supported by a close correspondence with unification algorithms.

\inv{2} is actually a condition on the represented substitution. Whenever we
find out that $x \termeq y$, for example when matching a variable pattern |y|
against a match variable |x|, we have to merge all the other constraints on |x|
into |y|, and say that |y| is the representative of |x|'s equivalence class.
This is so that every new constraint we record on |y| also affects |x| and vice
versa. The process of finding the solution of |x| in $x \termeq y, y \termeq
|Nothing|$ then entails \emph{walking} the substitution, because we have to look
up constraints twice: The first lookup will find |x|'s representative |y|, the
second lookup on |y| will then find the solution |Nothing|.

We use $\Delta(x)$ to look up the representative of $x$ in $\Delta$ (see \Cref{fig:gen}).
Therefore, we can assert that |x| has |Nothing| as a solution simply by writing $\Delta(x)
\termeq |Nothing| \in \Delta$.

\subsection{Expanding a normalised refinement type to a pattern} \label{sec:expand}

Expanding a $\nabla$ to a pattern vector, by calling $\expand(\nabla)$ in \Cref{fig:gen},
is syntactically heavy, but straightforward.
When there is a solution like $\Delta(x) \termeq |Just y|$
in $\Delta$ for the head $x$ of the variable vector of interest, expand $y$ in
addition to the rest of the vector and wrap it in a |Just|. Invariant \inv{3}
guarantees that there is at most one such solution and $\expand$ is
well-defined.

\subsection{Normalising a refinement type} \label{sec:normalise}

\begin{figure}
\centering
\[ \textbf{Add a formula literal to $\nabla$} \quad
 \ruleform{ \nabla \addphi \varphi = \nabla } \]
\[
\begin{array}{r@@{\,}c@@{\,}lcll}

  \nabla &\addphi& \false &=& \false & (1)\\
  \nabla &\addphi& \true &=& \nabla & (2) \\
  \nreft{\Gamma}{\Delta} &\addphi& \ctcon{\genconapp{K}{a}{\gamma}{y{:}\tau}}{x} &=&
    \nreft{\Gamma,\overline{a},\overline{y{:}\tau}}{\Delta} \adddelta \overline{\gamma} \adddelta \overline{y' \ntermeq \bot} \adddelta x \termeq \deltaconapp{K}{a}{y} & (3) \\
  &&&& \quad \text{where $\overline{y'}$ bind strict fields} \\
  \nreft{\Gamma}{\Delta} &\addphi& \ctlet{x{:}\tau}{\genconapp{K}{\sigma}{\gamma}{e}} &=& \nreft{\Gamma,x{:}\tau,\overline{a}}{\Delta} \adddelta \overline{a \typeeq \sigma} \adddelta x \termeq \deltaconapp{K}{a}{y} \addphi \overline{\ctlet{y{:}\tau'}{e}} & (4) \\
  &&&& \quad \text{where $\overline{a}\,\overline{y} \freein \Gamma$, $\overline{e{:}\tau'}$} \\
  \nreft{\Gamma}{\Delta} &\addphi& \ctlet{x{:}\tau}{y} &=& \nreft{\Gamma,x{:}\tau}{\Delta} \adddelta x \termeq y & (5) \\
  \nreft{\Gamma}{\Delta} &\addphi& \ctlet{x{:}\tau}{e} &=& \nreft{\Gamma,x{:}\tau}{\Delta} & (6) \\
  % TODO: Somehow make the coercion from delta to phi less ambiguous
  \nreft{\Gamma}{\Delta} &\addphi& \varphi &=& \nreft{\Gamma}{\Delta} \adddelta \varphi & (7)

\end{array}
\]

\[ \textbf{Add a constraint to $\nabla$} \quad
 \ruleform{ \nabla \adddelta \delta = \nabla } \]
\[
\begin{array}{r@@{\,}c@@{\,}l@@{\;}c@@{\;}ll}

  \false &\adddelta& \delta &=& \false & (8)\\
  \nreft{\Gamma}{\Delta} &\adddelta& \gamma &=& \begin{cases}
    \nreft{\Gamma}{(\Delta,\gamma)} & \parbox[t]{6cm}{if type checker deems $\gamma$ compatible with $\Delta$ \\ and $\forall x \in \mathsf{dom}(\Gamma): \inhabited{\nreft{\Gamma}{(\Delta,\gamma)}}{\rep{\Delta}{x}}$} \\
    \false & \text{otherwise} \\
  \end{cases} & (9)\\
  \nreft{\Gamma}{\Delta} &\adddelta& x \termeq \deltaconapp{K}{a}{y} &=& \begin{cases}
    \nreft{\Gamma}{\Delta} \adddelta \overline{a \typeeq b} \adddelta \overline{y \termeq z} & \text{if $\rep{\Delta}{x} \termeq \deltaconapp{K}{b}{z} \in \Delta$ } \\
    \false & \text{if $\rep{\Delta}{x} \termeq \deltaconapp{K'}{b}{z} \in \Delta$ } \\
    \nreft{\Gamma}{(\Delta,\rep{\Delta}{x} \termeq \deltaconapp{K}{a}{y})} & \text{if $\rep{\Delta}{x} \ntermeq K \not\in \Delta$} \\
    \false & \text{otherwise} \\
  \end{cases} & (10) \\
  \nreft{\Gamma}{\Delta} &\adddelta& x \ntermeq K &=& \begin{cases}
    \false & \text{if $\rep{\Delta}{x} \termeq \deltaconapp{K}{a}{y} \in \Delta$} \\
    \false & \text{if not $\inhabited{\nreft{\Gamma}{(\Delta,\rep{\Delta}{x} \ntermeq K)}}{\rep{\Delta}{x}}$} \\
    \nreft{\Gamma}{(\Delta,\rep{\Delta}{x}\ntermeq K)} & \text{otherwise} \\
  \end{cases} & (11) \\
  \nreft{\Gamma}{\Delta} &\adddelta& x \termeq \bot &=& \begin{cases}
    \false & \text{if $\rep{\Delta}{x} \ntermeq \bot \in \Delta$} \\
    \nreft{\Gamma}{(\Delta,\rep{\Delta}{x}\termeq \bot)} & \text{otherwise} \\
  \end{cases} & (12) \\
  \nreft{\Gamma}{\Delta} &\adddelta& x \ntermeq \bot &=& \begin{cases}
    \false & \text{if $\rep{\Delta}{x} \termeq \bot \in \Delta$} \\
    \false & \text{if not $\inhabited{\nreft{\Gamma}{(\Delta,\rep{\Delta}{x}\ntermeq\bot)}}{\rep{\Delta}{x}}$} \\
    \nreft{\Gamma}{(\Delta,\rep{\Delta}{x} \ntermeq \bot)} & \text{otherwise} \\
  \end{cases} & (13) \\
  \nreft{\Gamma}{\Delta} &\adddelta& x \termeq y &=&
    \begin{cases}
      \nreft{\Gamma}{\Delta} & \text{if $x' = y'$} \\
      \nreft{\Gamma}{((\Delta\!\setminus\!x'), x'\!\termeq\!y')} \adddelta (\restrict{\Delta}{x'}[y' / x']
        & \text{otherwise} \\
    \end{cases} & (14)\\
  &&&&\text{where}~x' = \rep{\Delta}{x} \; \text{and} \; y' = \rep{\Delta}{y}
\end{array}
\]

\[
\begin{array}{cc}
\ruleform{ \Delta \setminus x = \Delta } & \ruleform{ \restrict{\Delta}{x} = \Delta } \\
\begin{array}{r@@{\,}c@@{\,}lcl}
  \varnothing &\setminus& x &=& \varnothing \\
  (\Delta,x \termeq \deltaconapp{K}{a}{y}) &\setminus& x &=& \Delta \setminus x \\
  (\Delta,x \ntermeq K) &\setminus& x &=& \Delta \setminus x \\
  (\Delta,x \termeq \bot) &\setminus& x &=& \Delta \setminus x \\
  (\Delta,x \ntermeq \bot) &\setminus& x &=& \Delta \setminus x \\
  (\Delta,\delta) &\setminus& x &=& (\Delta \setminus x),\delta \\
\end{array}&
\begin{array}{rcl}
  \restrict{\varnothing}{x} &=& \varnothing \\
  \restrict{(\Delta,x \termeq \deltaconapp{K}{a}{y})}{x} &=& \restrict{\Delta}{x},\, x \termeq \deltaconapp{K}{a}{y} \\
  \restrict{(\Delta,x \ntermeq K)}{x} &=& \restrict{\Delta}{x},\, x \ntermeq K \\
  \restrict{(\Delta,x \termeq \bot)}{x} &=& \restrict{\Delta}{x},\, x \termeq \bot \\
  \restrict{(\Delta,x \ntermeq \bot)}{x} &=& \restrict{\Delta}{x},\, x \ntermeq \bot \\
  \restrict{(\Delta,\delta)}{x} &=& \restrict{\Delta}{x} \\
\end{array}
\end{array}
\]

\caption{Adding a constraint to the normalised refinement type $\nabla$}
\label{fig:add}
\end{figure}

Normalisation, carried out by $\construct$ in \Cref{fig:gen},
is largely a matter of repeatedly adding a literal $\varphi$ to a
normalised type, thus $\nabla \addphi \varphi$.  This function
is where all the work is done, in \Cref{fig:add}.
%
It does so by expressing a $\varphi$ in terms of once again simpler constraints
$\delta$ and calling out to $\!\adddelta\!$. Specifically, in Equation (3)
a pattern guard extends the context and
adds suitable type constraints and a positive constructor constraint
arising from the binding. Equation (4) of $\!\addphi\!$ performs
some limited, but important reasoning about let bindings: it flattens
possibly nested constructor applications, such as $\ctlet{|x|}{|Just True|}$.
Note that equation (6) simply discards let bindings that cannot be expressed
in $\nabla$; we'll see an extension in \cref{ssec:extviewpat} that avoids
this information loss.
% The last case of $\!\addphi\!$
% turns the syntactically and semantically identical subset of $\varphi$ into
% $\delta$ and adds that constraint via $\!\adddelta\!$.

That brings us to the prime unification procedure, $\!\adddelta\!$.
When adding $x \termeq |Just y|$, equation (10), the unification procedure will first look for
a solution for $x$ with \emph{that same constructor}. Let's say there is
$\Delta(x) \termeq |Just u| \in \Delta$. Then $\!\adddelta\!$ operates on the
transitively implied equality $|Just y| \termeq |Just u|$ by equating type and
term variables with new constraints, \ie $|y| \termeq |u|$. The original
constraint, although not conflicting, is not added to the normalised refinement
type because of \inv{2}.

If there is a solution involving a different constructor like $\Delta(x)
\termeq |Nothing|$ or if there was a negative constructor constraint $\Delta(x)
\ntermeq |Just|$, the new constraint is incompatible with the
existing solution. Otherwise, the constraint is compatible and is added to
$\Delta$.

Adding a negative constructor constraint $x \ntermeq Just$ is quite similar (equation (11)),
except that we have to make sure that $x$ still satisfies \inv{4}, which is
checked by the $\inhabited{\nabla}{\Delta(x)}$ judgment (\cf \cref{sec:test})
in \cref{fig:inh}. Handling positive and negative constraints involving $\bot$
is analogous.

Adding a type constraint $\gamma$ (equation (9)) entails calling out to the type checker to
assert that the constraint is consistent with existing type constraints.
Afterwards, we have to ensure \inv{4} is upheld for \emph{all} variables in the
domain of $\Gamma$, because the new type constraint could have rendered a type
empty. To demonstrate why this is necessary, imagine we have $\nreft{x : a}{x
\ntermeq \bot}$ and try to add $a \typeeq |Void|$. Although the type constraint
is consistent, $x$ in $\nreft{x : a}{x \ntermeq \bot, a \typeeq |Void|}$ is no
longer inhabited. There is room for being smart about which variables we have
to re-check: For example, we can exclude variables whose type is a non-GADT
data type.

Equation (14) of $\!\adddelta\!$ equates two variables ($x \termeq y$) by
merging their equivalence classes. Consider the case where $x$ and $y$ aren't
in the same equivalence class. Then $\Delta(y)$ is arbitrarily chosen to be the
new representative of the merged equivalence class. To uphold \inv{2}, all
constraints mentioning $\Delta(x)$ have to be removed and renamed in terms of
$\Delta(y)$ and then re-added to $\Delta$, one of which in turn might uncover a
contradiction.

% The predicate literals $\varphi$ of refinement types look quite similar to the
% original $\Grd$ language, so how is checking them for emptiness an improvement
% over reasoning about about guard trees directly? To appreciate the transition,
% it is important to realise that semantics of $\Grd$s are \emph{highly
% non-local}! Left-to-right and top-to-bottom match semantics means that it is
% hard to view $\Grd$s in isolation; we always have to reason about whole
% $\Gdt$s. By contrast, refinement types are self-contained, which means the
% process of generating inhabitants can be treated separately from the process
% of coverage checking.
%
% Apart from generating inhabitants of the final uncovered set for non-exhaustive
% match warnings, there are two points at which we have to check whether
% a refinement type has become empty: To determine whether a right-hand side is
% inaccessible and whether a particular bang guard may lead to divergence and
% requires us to wrap a \lightning{}.
%
% Take the final uncovered set $\Theta_{|liftEq|}$ after checking |liftEq| above
% as an example. A bit of eyeballing |liftEq|'s definition reveals that |Nothing
% (Just _)| is an uncovered pattern, but eyeballing the constraint formula of
% $\Theta_{|liftEq|}$ seems impossible in comparison. A more systematic approach
% is to adopt a generate-and-test scheme: Enumerate possible values of the data
% types for each variable involved (the pattern variables |mx| and |my|, but also
% possibly the guard-bound |x|, |y| and |t|) and test them for compatibility with
% the recorded constraints.
%
% Starting from |mx my|, we enumerate all possibilities for the shape of |mx|,
% and similarly for |my|. The obvious first candidate in a lazy language is
% $\bot$! But that is a contradicting assignment for both |mx| and |my|
% indepedently. Refining to |Nothing Nothing| contradicts with the left part
% of the top-level $\wedge$. Trying |Just y| (|y| fresh) instead as the shape for
% |my| yields our first inhabitant! Note that |y| is unconstrained, so $\bot$ is
% a trivial inhabitant. Similarly for |(Just _) Nothing| and |(Just _) (Just _)|.
%
% Why do we have to test guard-bound variables in addition to the pattern
% variables? It is because of empty data types and strict fields. For example,
% |v| from \cref{ssec:strictness} does not have any uncovered patterns. And our
% approach should see that by looking at its uncovered set $\reft{x : |Maybe
% Void|}{x \ntermeq \bot \wedge x \ntermeq \mathtt{Nothing}}$. Specifically, the
% candidate |SJust y| (for fresh |y|) for |x| should be rejected, because there
% is no inhabitant for |y|! $\bot$ is ruled out by the strict field and |Void|
% has no data constructors with which to instantiate |y|. Hence it is important
% to test guard-bound variables for inhabitants, too.

\subsection{Testing for inhabitation} \label{sec:test} \label{sec:inhabitation}

\begin{figure}
\centering
\[ \textbf{Test if $x$ is inhabited considering $\nabla$} \quad
 \ruleform{ \inhabited{\nabla}{x} } \]
\[
\begin{array}{c}

  \prooftree
    (\nreft{\Gamma}{\Delta} \adddelta x \termeq \bot) \not= \false
  \justifies
    \inhabited{\nreft{\Gamma}{\Delta}}{x}
  \using
    \inhabitedbot
  \endprooftree

  \qquad

  \prooftree
    {x:\tau \in \Gamma \quad \cons(\nreft{\Gamma}{\Delta}, \tau) = \bot}
  \justifies
    \inhabited{\nreft{\Gamma}{\Delta}}{x}
  \using
    \inhabitednocpl
  \endprooftree

  \\
  \\

  \prooftree
    \Shortstack{{x:\tau \in \Gamma \quad K \in \cons(\nreft{\Gamma}{\Delta}, \tau)}
                {\inst(\nreft{\Gamma}{\Delta}, x, K) \not= \false}}
  \justifies
    \inhabited{\nreft{\Gamma}{\Delta}}{x}
  \using
    \inhabitedinst
  \endprooftree

\end{array}
\]

\[ \textbf{Find data constructors of $\tau$} \quad
 \ruleform{ \cons(\nreft{\Gamma}{\Delta}, \tau) = \overline{K}} \]
\[
\begin{array}{c}

  \cons(\nreft{\Gamma}{\Delta}, \tau) = \begin{cases}
    \overline{K} & \parbox[t]{0.8\textwidth}{$\tau = T \; \overline{\sigma}$ and $T$ data type with constructors $\overline{K}$ \\ (after normalisation according to the type constraints in $\Delta$)} \\
    % TODO: We'd need a cosntraint like \delta's \false here... Or maybe we
    % just omit this case and accept that the function is partial
    \bot & \text{otherwise} \\
  \end{cases} \\

\end{array}
\]

% This is mkOneConFull
\[ \textbf{Instantiate $x$ to data constructor $K$} \quad
 \ruleform{ \inst(\nabla, x, K) = \nabla } \]
\[
\begin{array}{c}

  \inst(\nreft{\Gamma}{\Delta}, x, K) =
    \nreft{\Gamma,\overline{a},\overline{y:\sigma}}{\Delta}
      \adddelta \tau_x \typeeq \tau
      \adddelta \overline{\gamma}
      \adddelta x \termeq \deltaconapp{K}{a}{y}
      \adddelta \overline{y' \ntermeq \bot} \\
  \qquad \qquad
    \text{where $K : \forall \overline{a}. \overline{\gamma} \Rightarrow \overline{\sigma} \rightarrow \tau$, $\overline{a}\,\overline{y} \freein \Gamma$, $x:\tau_x \in \Gamma$, $\overline{y'}$ bind strict fields} \\

\end{array}
\]

\caption{Testing for inhabitation}
\label{fig:inh}
\end{figure}

The process for adding a constraint to a normalised type above (which turned
out to be a unification procedure in disguise) makes use of an
\emph{inhabitation test} $\inhabited{\nabla}{x}$, depicted in \cref{fig:inh}.
This tests whether there are any values of $x$ that satisfy $\nabla$. If not,
$\nabla$ does not uphold \inv{4}.
For example, the conjunction
$x \ntermeq Just, x \ntermeq Nothing, x \ntermeq \bot$ does not satisfy \inv{4},
because no value of $x$ satisfies all those constraints.

The \inhabitedbot judgment of $\inhabited{\nabla}{x}$ tries to instantiate $x$ to
$\bot$ to conclude that $x$ is inhabited. \inhabitedinst instantiates $x$ to one
of its data constructors. That will only work if its type ultimately reduces to
a data type under the type constraints in $\nabla$. Rule \inhabitednocpl will
accept unconditionally when its type is not a data type, \ie for $x : |Int ->
Int|$.

Note that the outlined approach is complete in the sense that
$\inhabited{\nabla}{x}$ is derivable (if and) only if |x| is actually inhabited
in $\nabla$, because that means we don't have any $\nabla$s floating around in
the checking process that actually aren't inhabited and trigger false positive
warnings. But that also means that the $\inhabited{}{}$ relation is
undecidable! Consider the following example:
\begin{code}
data T = MkT !!T
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

% \section{Formalism} \label{sec:formalism}
%
% \simon{This entire section is scheduled for deletion, once we have moved out everything we need}
%
% The previous section gave insights into how we represent coverage checking
% problems as guard trees and provided an intuition for how to check them for
% exhaustiveness and redundancy. This section formalises these intuitions in
% terms of the syntax (\cf \cref{fig:syn}) we introduced earlier.
%
% As in the previous section, we divide this section into three main parts:
% desugaring, coverage checking, and finding inhabitants of the resulting
% refinement types. The latter subtask proves challenging enough to warrant two
% additional subsections.
%
% \sg{We should talk about why ``constructor applications'' in $\Expr, \Grd,
% \varphi$ and $\delta$ have different number of arguments. Not sure where.}
%
% \subsection{Desugaring to guard trees}
%
% \simon{I think this section has nothing useful left}
%
% \Cref{fig:desugar} outlines the desugaring step from source Haskell to our
% guard tree language $\Gdt$. It is assumed that the top-level match variables
% $x_1$ through $x_n$ in the $clause$ cases have special, fixed names. All other
% variables that aren't bound in arguments to $\ds$ have fresh names.
%
% Consider this example function:
%
% \begin{code}
% f (Just (!xs,_))  ys@Nothing   = 1
% f Nothing         (g -> True)  = 2
% \end{code}
%
% \noindent
% Under $\ds$, this desugars to
%
% \begin{forest}
%   grdtree,
%   [
%     [{$\grdbang{x_1}, \grdcon{|Just t_1|}{x_1}, \grdbang{t_1}, \grdcon{(t_2, t_3)}{t_1}, \grdbang{t_2}, \grdlet{xs}{t_2}, \grdlet{ys}{x_2}, \grdbang{ys}, \grdcon{|Nothing|}{ys}$} [1]]
%     [{$\grdbang{x_1}, \grdcon{|Nothing|}{x_1}, \grdlet{t_3}{|g x_2|}, \grdbang{y}, \grdcon{|True|}{t_3}$} [2]]]
% \end{forest}
%
% The definition of $\ds$ is straight-forward, but a little expansive because of
% the realistic source language. Its most intricate job is keeping track of all
% the renaming going on to resolve name mismatches. Other than that, the
% desugaring follows from the restrictions on the $\Grd$ language, such as the
% fact that source-level pattern guards also need to emit a bang guard on the
% variable representing the scrutinee.
%
% Note how our na{\"i}ve desugaring function generates an abundance of fresh
% temporary variables. In practice, the implementation of $\ds$ can be smarter
% than this by looking at the pattern (which might be a variable match or
% as-pattern) when choosing a name for a variable.
%
% \subsection{Checking guard trees}
%
% \simon{I think this section has nothing useful left}
%
% \Cref{fig:check} shows the two main functions for checking guard trees. $\unc$
% carries out exhaustiveness checking by computing the set of uncovered values
% for a particular guard tree, whereas $\ann$ computes the corresponding
% annotated tree, capturing redundancy information. $\red$ extracts a triple of
% accessible, inaccessible and redundant GRHS from such an annotated tree.
%
% Both $\unc$ and $\ann$ take as their second parameter the set of values
% \emph{reaching} the particular guard tree node. If no value reaches a
% particular tree node, that node is inaccessible. The definition of $\unc$
% follows the intuition we built up earlier: It refines the set of reaching
% values as a subset of it falls through from one clause to the next. This is
% most visible in the $\gdtseq{}{}$ case (top-to-bottom composition), where the
% set of values reaching the right (or bottom) child is exactly the set of values
% that were uncovered by the left (or top) child on the set of values reaching
% the whole node. A GRHS covers every reaching value. The left-to-right semantics
% of $\gdtguard{}{\hspace{-0.6em}}$ are respected by refining the set of values reaching the
% wrapped subtree, depending on the particular guard. Bang guards and let
% bindings don't do anything beyond that refinement, whereas pattern guards
% additionally account for the possibility of a failed pattern match. Note that
% a failing pattern guard is the \emph{only} way in which the uncovered set
% can become non-empty!
%
% When $\ann$ hits a GRHS, it asks $\generate$ for inhabitants of $\Theta$
% to decide whether the GRHS is accessible or not. Since $\ann$ needs to compute
% and maintain the set of reaching values just the same as $\unc$, it has to call
% out to $\unc$ for the $\gdtseq{}{}$ case. Out of the three guard cases, the one
% handling bang guards is the only one doing more than just refining the set of
% reaching values for the subtree (thus respecting left-to-right semantics). A
% bang guard $\grdbang{x}$ is handled by testing whether the set of reaching
% values $\Theta$ is compatible with the assignment $x \termeq \bot$, which again
% is done by asking $\generate$ for concrete inhabitants of the resulting
% refinement type. If it \emph{is} inhabited, then the bang guard might diverge
% and we need to wrap the annotated subtree in a \lightning{}.
%
% Pattern guard semantics are important for $\unc$ and bang guard semantics are
% important for $\ann$. But what about let bindings? They are in fact completely
% uninteresting to the checking process, but making sense of them is important
% for the precision of the emptiness check involving $\generate$. Of course,
% ``making sense'' of an expression is an open-ended endeavour, but we'll
% see a few reasonable ways to improve precision considerably at almost no cost,
% both in \cref{ssec:extinert} and \cref{ssec:extviewpat}.
%
%
% \subsection{Generating inhabitants of a refinement type}
% \label{ssec:gen}
%
% The key function for the emptiness test is $\generate$ in \cref{fig:gen}, which
% generates a set of patterns which inhabit a given refinement type $\Theta$.
% There might be multiple inhabitants, and $\construct$ will construct multiple
% $\nabla$s, each representing at least one inhabiting assignment of the
% refinement predicate $\Phi$. Each such assignment corresponds to a pattern
% vector, so $\expand$ expands the assignments in a $\nabla$ into multiple
% pattern vectors.
%
% But what \emph{is} $\nabla$? It's a pair of a type context $\Gamma$ and a
% $\Delta$, a set of mutually compatible constraints $\delta$, or a proven
% incomatibility $\false$ between such a set of constraints. $\construct$ will
% arrange it that every constructed $\nabla$ satisfies a number of
% well-formedness constraints:
%
% \begin{enumerate}
%   \item[\inv{1}] \emph{Mutual compatibility}: No two constraints in $\nabla$
%     should conflict with each other.
%   \item[\inv{2}] \emph{Triangular form}: A $x \termeq y$ constraint implies
%     absence of any other constraints mentioning |x| in its left-hand side.
%   \item[\inv{3}] \emph{Single solution}: There is at most one positive
%     constructor constraint $x \termeq \deltaconapp{K}{a}{y}$ for a given |x|.
% \end{enumerate}
%
% \noindent
% We refer to such a $\nabla$ as an \emph{inert set}, in the sense that its
% constraints are of canonical form and already checked for mutual compatibility
% (\inv{1}), in analogy to a typechecker's implementation.
%
% It is helpful at times to think of a $\Delta$ as a partial function from |x| to
% its \emph{solution}, informed by the single positive constraint $x \termeq
% \deltaconapp{K}{a}{y} \in \Delta$, if it exists. For example, $x \termeq
% |Nothing|$ can be understood as a function mapping |x| to |Nothing|. This
% reasoning is justified by \inv{3}. Under this view, $\Delta$ looks like a
% substitution. As we'll see later in \cref{ssec:extinert}, this view is
% supported by immense overlap with unification algorithms.
%
% \inv{2} is actually a condition on the represented substitution. Whenever we
% find out that $x \termeq y$, for example when matching a variable pattern |y|
% against a match variable |x|, we have to merge all the other constraints on |x|
% into |y| and say that |y| is the representative of |x|'s equivalence class.
% This is so that every new constraint we record on |y| also affects |x| and vice
% versa. The process of finding the solution of |x| in $x \termeq y, y \termeq
% |Nothing|$ then entails \emph{walking} the substitution, because we have to look
% up (in the sense of understanding $\Delta$ as a partial function) twice: The
% first lookup will find |x|'s representative |y|, the second lookup on |y| will
% then find the solution |Nothing|.
%
% In denoting looking up the representative by $\Delta(x)$ (\cf \cref{fig:gen}),
% we can assert that |x| has |Nothing| as a solution simply by writing $\Delta(x)
% \termeq |Nothing| \in \Delta$.
%
% Each $\Delta$ is one of possibly many valid variable assignments of the particular $\Phi$ it is
% constructed for. In contrast to $\Phi$, there is no disjunction in $\Delta$,
% which makes it easy to check if a new constraint is compatible with the
% existing ones without any backtracking. Another fundamental difference is that
% $\delta$ has no binding constructs (so every variable has to be bound in the
% $\Gamma$ part of $\nabla$), whereas pattern bindings in $\varphi$ bind
% constructor arguments.
%
% Expanding a $\nabla$ to a pattern vector in $\expand$ is syntactically heavy,
% but straightforward: When there is a solution like $\Delta(x) \termeq |Just y|$
% in $\Delta$ for the head $x$ of the variable vector of interest, expand $y$ in
% addition to the rest of the vector and wrap it in a |Just|. \inv{3}
% guarantees that there is at most one such solution and $\expand$ is
% well-defined.
%
% \subsection{Extending the inert set}
% \label{ssec:extinert}
%
%
% $\construct$ is the function that breaks down a $\Phi$ into multiple $\nabla$s,
% maintaining the invariant that no such $\nabla$ is $\false$.
% At the heart of $\construct$ is adding a $\varphi$ literal to the $\nabla$
% under construction via $\!\addphi\!$ and filtering out any unsuccessful
% attempts (via intercepting the $\false$ failure mode of $\!\addphi\!$) to do
% so. Conjunction is handled by the equivalent of a |concatMap|, whereas a
% disjunction corresponds to a plain union.
%
% After tearing down abstraction after abstraction in the previous sections we
% are nearly at the heart of \lyg: \Cref{fig:add} depicts how to add a
% $\varphi$ constraint to an inert set $\nabla$.
%
% It does so by expressing a $\varphi$ in terms of once again simpler constraints
% $\delta$ and calling out to $\!\adddelta\!$. Specifically, for a lack of
% binding constructs in $\delta$, pattern bindings extend the context and
% disperse into separate type constraints and a positive constructor constraint
% arising from the binding. The fourth case of $\!\adddelta\!$ finally performs
% some limited, but important reasoning about let bindings: In case the
% right-hand side was a constructor application (which is not to be confused with
% a pattern binding, if only for the difference in binding semantics!), we add
% appropriate positive constructor and type constraints, as well as recurse into
% the field expressions, which might in turn contain nested constructor
% applications. All other let bindings are simply discarded. We'll see an
% extension in \cref{ssec:extviewpat} which will expand here. The last case of
% $\!\addphi\!$ turns the syntactically and semantically identical subset of
% $\varphi$ into $\delta$ and adds that constraint via $\!\adddelta\!$.
%
% Which brings us to the prime unification procedure, $\!\adddelta\!$.
% Consider adding a positive constructor constraint like $x \termeq |Just y|$:
% The unification procedure will first look for any positive constructor constraint
% involving the representative of $x$ with \emph{that same constructor}. Let's say
% there is $\Delta(x) = z$ and $z \termeq |Just u| \in \Delta$. Then
% $\!\adddelta\!$ decomposes the new constraint just like a classic unification
% algorithm operating on the transitively implied equality $|Just y| \termeq
% |Just u|$, by equating type and term variables with new constraints, \ie $|y|
% \termeq |u|$. The original constraint, although not conflicting (thus maintaining
% wellformed-ness condition \inv{1}), is not added to the inert set because of
% \inv{2}.
%
% If there was no positive constructor constraint with the same constructor, it
% will look for such a constraint involving a different constructor, like $x
% \termeq |Nothing|$, in which case the new constraint is incompatible with the
% existing solution. There are two other ways in which the constraint can be
% incompatible: If there was a negative constructor constraint $x \ntermeq
% |Just|$ or if any of the fields were not inhabited, which is checked by the
% $\inhabited{\nabla}{x}$ judgment in \cref{fig:inh}. Otherwise, the constraint
% is compatible and is added to $\Delta$.
%
% Adding a negative constructor constraint $x \ntermeq Just$ is quite
% similar, as is handling of positive and negative constraints involving $\bot$.
% The idea is that whenever we add a negative constraint that doesn't
% contradict with positive constraints, we still have to test if there are any
% inhabitants left.
%
% Adding a type constraint $\gamma$ drives this paranoia to a maximum: After
% calling out to the type checker (the logic of which we do not and would not
% replicate in this paper or our implementation) to assert that the constraint is
% consistent with the inert set, we have to test \emph{all} variables in the
% domain of $\Gamma$ for inhabitants, because the new type constraint could have
% rendered a type empty. To demonstrate why this is necessary, imagine we have
% $\nreft{x : a}{x \ntermeq \bot}$ and try to add $a \typeeq |Void|$. Although the
% type constraint is consistent, $x$ in $\nreft{x : a}{x \ntermeq \bot, a \typeeq
% |Void|}$ is no longer inhabited. There is room for being smart about which
% variables we have to re-check: For example, we can exclude variables whose type
% is a non-GADT data type.
%
% The last case of $\!\adddelta\!$ equates two variables ($x \termeq y$) by
% merging their equivalence classes. Consider the case where $x$ and $y$ don't
% already belong to the same equivalence class and thus have different representatives
% $\Delta(x)$ and $\Delta(y)$. $\Delta(y)$ is arbitrarily chosen to be the new
% representative of the merged equivalence class. Now, to uphold the
% well-formedness condition \inv{2}, all constraints mentioning $\Delta(x)$
% have to be removed and renamed in terms of $\Delta(y)$ and then re-added to
% $\Delta$. That might fail, because $\Delta(x)$ might have a constraint that
% conflicts with constraints on $\Delta(y)$, so it is better to use $\!\adddelta\!$ rather
% than to add it blindly to $\Delta$.
%
%
% \subsection{Inhabitation test}
%
% \begin{figure}
% \centering
% \[ \textbf{Test if $x$ is inhabited considering $\nabla$} \]
% \[ \ruleform{ \inhabited{\nabla}{x} } \]
% \[
% \begin{array}{c}
%
%   \prooftree
%     (\nreft{\Gamma}{\Delta} \adddelta x \termeq \bot) \not= \false
%   \justifies
%     \inhabited{\nreft{\Gamma}{\Delta}}{x}
%   \using
%     \inhabitedbot
%   \endprooftree
%
%   \qquad
%
%   \prooftree
%     {x:\tau \in \Gamma \quad \cons(\nreft{\Gamma}{\Delta}, \tau) = \bot}
%   \justifies
%     \inhabited{\nreft{\Gamma}{\Delta}}{x}
%   \using
%     \inhabitednocpl
%   \endprooftree
%
%   \\
%   \\
%
%   \prooftree
%     \Shortstack{{x:\tau \in \Gamma \quad K \in \cons(\nreft{\Gamma}{\Delta}, \tau)}
%                 {\inst(\nreft{\Gamma}{\Delta}, x, K) \not= \false}}
%   \justifies
%     \inhabited{\nreft{\Gamma}{\Delta}}{x}
%   \using
%     \inhabitedinst
%   \endprooftree
%
% \end{array}
% \]
%
% \[ \textbf{Find data constructors of $\tau$} \]
% \[ \ruleform{ \cons(\nreft{\Gamma}{\Delta}, \tau) = \overline{K}} \]
% \[
% \begin{array}{c}
%
%   \cons(\nreft{\Gamma}{\Delta}, \tau) = \begin{cases}
%     \overline{K} & \parbox[t]{0.8\textwidth}{$\tau = T \; \overline{\sigma}$ and $T$ data type with constructors $\overline{K}$ \\ (after normalisation according to the type constraints in $\Delta$)} \\
%     % TODO: We'd need a cosntraint like \delta's \false here... Or maybe we
%     % just omit this case and accept that the function is partial
%     \bot & \text{otherwise} \\
%   \end{cases} \\
%
% \end{array}
% \]
%
% % This is mkOneConFull
% \[ \textbf{Instantiate $x$ to data constructor $K$} \]
% \[ \ruleform{ \inst(\nabla, x, K) = \nabla } \]
% \[
% \begin{array}{c}
%
%   \inst(\nreft{\Gamma}{\Delta}, x, K) =
%     \nreft{\Gamma,\overline{a},\overline{y:\sigma}}{\Delta}
%       \adddelta \tau_x \typeeq \tau
%       \adddelta \overline{\gamma}
%       \adddelta x \termeq \deltaconapp{K}{a}{y}
%       \adddelta \overline{y' \ntermeq \bot} \\
%   \qquad \qquad
%     \text{where $K : \forall \overline{a}. \overline{\gamma} \Rightarrow \overline{\sigma} \rightarrow \tau$, $\overline{a}\,\overline{y} \freein \Gamma$, $x:\tau_x \in \Gamma$, $\overline{y'}$ bind strict fields} \\
%
% \end{array}
% \]
%
% \caption{Inhabitance test}
% \label{fig:inh}
% \end{figure}
%
% \sg{We should find better subsection titles that clearly distinguish
% "Testing ($\Theta$) for Emptiness" from "Inhabitation Test(ing a
% particular variable in $\nabla$)".}
% The process for adding a constraint to an inert set above (which turned out to
% be a unification procedure in disguise) frequently made use of an
% \emph{inhabitation test} $\inhabited{\nabla}{x}$, depicted in \cref{fig:inh}.
% In contrast to the emptiness test in \cref{fig:gen}, this one focuses on a
% particular variable and works on a $\nabla$ rather than a much higher-level
% $\Theta$.
%
% The \inhabitedbot judgment of $\inhabited{\nabla}{x}$ tries to instantiate $x$ to
% $\bot$ to conclude that $x$ is inhabited. \inhabitedinst instantiates $x$ to one
% of its data constructors. That will only work if its type ultimately reduces to
% a data type under the type constraints in $\nabla$. Rule \inhabitednocpl will
% accept unconditionally when its type is not a data type, \ie for $x : |Int ->
% Int|$.
%
% Note that the outlined approach is complete in the sense that
% $\inhabited{\nabla}{x}$ is derivable (if and) only if |x| is actually inhabited
% in $\nabla$, because that means we don't have any $\nabla$s floating around
% in the checking process that actually aren't inhabited and trigger false
% positive warnings. But that also means that the $\inhabited{}{}$ relation is
% undecidable! Consider the following example:
% \begin{code}
% data T = MkT !T
% f :: SMaybe T -> ()
% f SNothing = ()
% \end{code}
%
% \noindent
% This is exhaustive, because |T| is an uninhabited type. Upon adding the constraint
% $x \ntermeq |SNothing|$ on the match variable |x| via $\!\adddelta\!$, we
% perform an inhabitation test, which tries to instantiate the $|SJust|$ constructor
% via \inhabitedinst. That implies adding (via $\!\adddelta\!$) the constraints
% $x \termeq |SJust y|, y \ntermeq \bot$, the latter of which leads to an
% inhabitation test on |y|. That leads to instantiation of the |MkT| constructor,
% which leads to constraints $y \termeq |MkT z|, z \ntermeq \bot$, and so on for
% |z| \etc. An infinite chain of fruitless instantiation attempts!
%
% In practice, we implement a fuel-based approach that conservatively assumes
% that a variable is inhabited after $n$ such iterations and consider
% supplementing that with a simple termination analysis in the future.


\section{Possible extensions} \label{sec:extensions}

\lyg is well equipped to handle the fragment of Haskell it was designed to
handle. But GHC (and other languages, for that matter) extends Haskell in
non-trivial ways. This section exemplifies easy accommodation of new language
features and measures to increase precision of the checking process,
demonstrating the modularity and extensibility of our approach.

\subsection{Long-distance information}
\label{ssec:ldi}

Coverage checking should also work for |case| expressions and nested function
definitions, like
\begin{code}
f True  = 1
f x     = ... (case x of{ False -> 2; True -> 3 }) ...
\end{code}

\noindent
\lyg as is will not produce any warnings for this definition. But the
reader can easily make the ``long distance connection'' that the last GRHS of
the |case| expression is redundant! That simply follows by context-sensitive
reasoning, knowing that |x| was already matched against |True|.

In terms of \lyg, the input values of the second GRHS $\Theta_{2}$ (which
determine whether the GRHS is accessible) encode the information we are after.
We just have to start checking the |case| expression starting from $\Theta_{2}$
as the initial set of reaching values instead of $\reft{x:|Bool|}{\true}$.

\subsection{Empty case}

As can be seen in \cref{fig:srcsyn}, Haskell function definitions need to have
at least one clause. That leads to an awkward situation when pattern matching
on empty data types, like |Void|:

\begin{minipage}{0.2\textwidth}
\begin{code}
absurd1 _   = undefined
absurd2 !_  = undefined
\end{code}
\end{minipage}%
\begin{minipage}{0.5\textwidth}
\begin{code}
absurd1, absurd2, absurd3 :: Void -> a
absurd3 x = case x of {}
\end{code}
\end{minipage}%

\noindent
|absurd1| returns |undefined| when called with $\bot$, thus masking the original $\bot$
with the error thrown by |undefined|. |absurd2| would diverge alright, but
\lyg will report its RHS as inaccessible! Hence GHC provides an extension,
called \extension{EmptyCase}, that allows the definition of |absurd3| above.
Such a |case| expression without any alternatives evaluates its argument to
WHNF and crashes when evaluation returns.

It is quite easy to see that $\Gdt$ lacks expressive power to desugar
\extension{EmptyCase} into, since all leaves in a guard tree need to have
corresponding RHSs. Therefore, we need to introduce $\gdtempty$ to $\Gdt$ and
$\antempty$ to $\Ant$. This is how they affect the checking process:
\[
\begin{array}{cc}
\unc(\Theta, \gdtempty) = \Theta
\quad&\quad
\ann(\Theta, \gdtempty) = \antempty
\end{array}
\]

Since \extension{EmptyCase}, unlike regular |case|, evaluates its scrutinee
to WHNF \emph{before} matching any of the patterns, the set of reaching
values is refined with a $x \ntermeq \bot$ constraint \emph{before} traversing
the guard tree, thus $\unc(\reft{\Gamma}{x \ntermeq \bot}, \gdtempty)$.

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

As far as \lyg is concerned, the matches on both |y_1| and |y_2| are
non-exhaustive. But that's actually too conservative: Both bind the same value!
By making the connection between |y_1| and |y_2|, the checker could infer that
the match was exhaustive.

This can be fixed by maintaining equivalence classes of semantically equivalent
expressions in $\Delta$, similar to what we already do for variables. We simply extend
the syntax of $\delta$ and change the last |let| case of $\!\addphi\!$. Then we can
handle the new constraint in $\adddelta$, as follows:
\[
\begin{array}{c}
\begin{array}{cc}
\begin{array}{c}
  \delta = ... \mid \highlight{e \termeq x}
\end{array}&
\begin{array}{c}
  \nreft{\Gamma}{\Delta} \addphi \ctlet{x:\tau}{e} = \highlight{\nreft{\Gamma,x:\tau}{\Delta} \adddelta e \termeq x}
\end{array}
\end{array} \\[0.5em]
\begin{array}{c}
  \highlight{\nreft{\Gamma}{\Delta} \adddelta e \termeq x = \begin{cases}
    \nreft{\Gamma}{\Delta} \adddelta x \termeq |y|, & \text{if $e' \termeq |y| \in \Delta$ and $e \equiv_{\Delta} e'$} \\
    \nreft{\Gamma}{\Delta, e \termeq \Delta(x)}, & \text{otherwise}
  \end{cases}}
\end{array}
\end{array}
\]

Where $\equiv_{\Delta}$ is (an approximation to) semantic equivalence modulo
substitution under $\Delta$. A clever data structure is needed to answer
queries of the form $e \termeq \mathunderscore \in \Delta$, efficiently. In our
implementation, we use a trie to index expressions rapidly and sacrifice
reasoning modulo $\Delta$ in doing so. Plugging in an SMT solver to decide
$\equiv_{\Delta}$ would be more precise, but certainly less efficient.

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

% \sg{For coverage checking purposes, we assume that pattern synonym matches
% are strict, just like data constructor matches. This is not generally true, but
% \ticket{17357} has a discussion of why being conservative is too disruptive to
% be worth the trouble. Should we talk about that? It concerns the definition of
% $\ds$, namely whether to add a $\grdbang{x}$ on the match var or not. Maybe a
% footnote?}

Assuming every definition encountered so far is changed to handle ConLikes $C$
now instead of data constructors $K$, everything should work almost fine. Why
then introduce the new syntactic variant in the first place? Consider
\begin{code}
pattern P = ()
pattern Q = ()
n = case P of Q -> 1; P -> 2
\end{code}

Knowing that the definitions of |P| and |Q| completely overlap, we can see that
the match on |Q| will cover all values that could reach |P|, so clearly |P| is
redundant. A sound approximation to that would be not to warn at all. And
that's reasonable, after all we established in \cref{ssec:patsyn} that
reasoning about pattern synonym definitions is undesirable.

But equipped with long-distance information from the scrutinee expression, the
checker would mark the \emph{first case alternative} as redundant, which
clearly is unsound! Deleting the first alternative would change its semantics
from returning 1 to returning 2. In general, we cannot assume that arbitrary
pattern synonym definitions are disjoint, in stark contrast to data
constructors.

The solution is to tweak the clause of $\!\adddelta\!$ dealing with positive
ConLike constraints $x \termeq \deltaconapp{C}{a}{y}$:
\[
\begin{array}{r@@{\,}c@@{\,}lcl}
\nreft{\Gamma}{\Delta} &\adddelta& x \termeq \deltaconapp{C}{a}{y} &=& \begin{cases}
    \nreft{\Gamma}{\Delta} \adddelta \overline{a \typeeq b} \adddelta \overline{y \termeq z} & \text{if $\rep{\Delta}{x} \termeq \deltaconapp{C}{b}{z} \in \Delta$ } \\
    \false & \text{if $\rep{\Delta}{x} \termeq \deltaconapp{C'}{b}{z} \in \Delta$ \highlight{\text{and $C \cap C' = \emptyset$}}} \\
    \nreft{\Gamma}{(\Delta,\rep{\Delta}{x} \termeq \deltaconapp{C}{a}{y})} & \text{if $\rep{\Delta}{x} \ntermeq C \not\in \Delta$ and $\overline{\inhabited{\nreft{\Gamma}{\Delta}}{\Delta(y)}}$} \\
    \false & \text{otherwise} \\
  \end{cases} \\
\end{array}
\]

Where the suggestive notation $C \cap C' = \emptyset$ is only true if $C$ and
$C'$ don't overlap, if both are data constructors, for example.

\sg{Omit this paragraph?}
Note that the slight relaxation means that the constructed $\nabla$ might
violate $\inv{3}$, specifically when $C \cap C' \not= \emptyset$. In practice
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
    (\nreft{\Gamma}{\Delta} \adddelta x \termeq \bot) \not= \false
  \justifies
    \inhabited{\nreft{\Gamma}{\Delta}}{x}
  \using
    \inhabitedbot
  \endprooftree

  &

  \prooftree
    \Shortstack{{x:\tau \in \Gamma \quad \cons(\nreft{\Gamma}{\Delta}, \tau)=\highlight{\overline{C_1,...,C_{n_i}}^i}}
                {\highlight{\overline{\inst(\nreft{\Gamma}{\Delta}, x, C_j) \not= \false}^i}}}
  \justifies
    \inhabited{\nreft{\Gamma}{\Delta}}{x}
  \using
    \inhabitedinst
  \endprooftree
\end{array}
\]
\[
\begin{array}{c}
  \cons(\nreft{\Gamma}{\Delta}, \tau) = \begin{cases}
    \highlight{\overline{C_1,...,C_{n_i}}^i} & \parbox[t]{0.8\textwidth}{$\tau = T \; \overline{\sigma}$ and $T$ \highlight{\text{type constructor with \extension{COMPLETE} sets $\overline{C_1,...,C_{n_i}}^i$}} \\ (after normalisation according to the type constraints in $\Delta$)} \\
    \highlight{\epsilon} & \text{otherwise} \\
  \end{cases}
\end{array}
\]

$\cons$ was changed to return a list of all available \extension{COMPLETE} sets,
and \inhabitedinst tries to find an inhabiting ConLike in each one of them in
turn. Note that \inhabitednocpl is gone, because it coincides with
\inhabitedinst for the case where the list returned by $\cons$ was empty. The
judgment has become simpler and and more general at the same time! Note that
checking against multiple \extension{COMPLETE} sets so frequently is
computationally intractable. We will worry about that in \cref{sec:impl}.

\subsection{Other extensions}

We consider further extensions, including overloaded literals, newtypes,
and a strict-by-default source syntax, in Appendix A.

\section{Implementation}
\label{sec:impl}

The implementation of \lyg in GHC accumulates quite a few tricks that
go beyond the pure formalism. This section is dedicated to describing these.

\sg{Delete this paragraph?}
Warning messages need to reference source syntax in order to be comprehensible
by the user. At the same time, coverage checks involving GADTs need a
type checked program, so the only reasonable design is to run the coverage checker
between type checking and desugaring to GHC Core, a typed intermediate
representation lacking the connection to source syntax. We perform coverage
checking in the same tree traversal as desugaring.

\subsection{Interleaving $\unc$ and $\ann$}
\label{ssec:interleaving}

\begin{figure}
\[ \ruleform{ \overline{\nabla} \addphiv \varphi = \overline{\nabla} } \]
\[
\begin{array}{r@@{\,}c@@{\,}lcl}
\epsilon &\addphiv& \varphi &=& \epsilon \\
(\nabla_1\,...\,\nabla_n) &\addphiv& \varphi &=& \begin{cases}
    (\nreft{\Gamma}{\Delta}) \, (\nabla_2\,...\,\nabla_n \addphiv \varphi) & \text{if $\nreft{\Gamma}{\Delta} = \nabla \addphi \varphi$} \\
    (\nabla_2\,...\,\nabla_n) \addphiv \varphi & \text{otherwise} \\
  \end{cases} \\
\end{array}
\]
\[ \ruleform{ \uncann(\overline{\nabla}, t) = (\overline{\nabla}, \Ant) } \]
\[
\begin{array}{lcl}
\uncann(\overline{\nabla}, \gdtrhs{n}) &=& (\epsilon, \antrhs{\overline{\nabla}}{n}) \\
\uncann(\overline{\nabla}, \gdtseq{t_1}{t_2}) &=& (\overline{\nabla}_2, \antseq{u_1}{u_2}) \hspace{0.5em} \text{where} \begin{array}{l@@{\,}c@@{\,}l}
    (\overline{\nabla}_1, u_1) &=& \uncann(\overline{\nabla}, t_1) \\
    (\overline{\nabla}_2, u_2) &=& \uncann(\overline{\nabla}_1, t_2)
  \end{array} \\
\uncann(\overline{\nabla}, \gdtguard{(\grdbang{x})}{t}) &=& \antbang{(\overline{\nabla} \addphiv (x \termeq \bot))}{u} \\
  && \quad \text{where } (\overline{\nabla}', u) = \uncann(\overline{\nabla} \addphiv (x \ntermeq \bot), t) \\
\uncann(\overline{\nabla}, \gdtguard{(\grdlet{x}{e})}{t}) &=& \uncann(\overline{\nabla} \addphiv (\ctlet{x}{e}), t) \\
\uncann(\overline{\nabla}, \gdtguard{(\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{t}) &=& ((\overline{\nabla} \addphiv (x \ntermeq K)) \, \overline{\nabla}', u) \\
  && \quad \text{where } (\overline{\nabla}', u) = \uncann(\overline{\nabla} \addphiv (\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}), t) \\
\end{array}
\]

\caption{Fast coverage checking}
\label{fig:fastcheck}
\end{figure}

The set of reaching values is an argument to both $\unc$ and $\ann$. Given a
particular set of input values and a guard tree, one can see by a simple
inductive argument that both $\unc$ and $\ann$ are always called at the same
arguments! Hence for an implementation it makes sense to compute both results
together, if only for not having to recompute the results of $\unc$ again in
$\ann$.

But there's more: Looking at the last clause of $\unc$ in \cref{fig:check},
we can see that we syntactically duplicate $\Theta$ every time we have a
pattern guard. That can amount to exponential growth of the refinement
predicate in the worst case and for the time to prove it empty!

% Clearly, the space usage won't actually grow exponentially due to sharing in
% the implementation, but the problems for runtime performance remain.
What we really want is to summarise a $\Theta$ into a more compact canonical
form before doing these kinds of \emph{splits}. But that's exactly what
$\nabla$ is! Therefore, in our implementation we don't pass around
and annotate refinement types, but the result of calling $\construct$ on them
directly.

You can see the resulting definition in \cref{fig:fastcheck}. The readability
is clouded by unwrapping of pairs. $\uncann$ requires that each $\nabla$
individually is non-empty, \ie not $\false$. This invariant is maintained by
adding $\varphi$ constraints through $\addphiv$, which filters out any $\nabla$
that would become empty.

\subsection{Throttling for graceful degradation} \label{ssec:throttling}

Even with the tweaks from \cref{ssec:interleaving}, checking certain pattern
matches remains NP-hard \citep{adaptivepm}. Naturally, there will be cases
where we have to conservatively approximate in order not to slow down
compilation too much. Consider the following example and its corresponding
guard tree:
\\
\begin{minipage}[b]{0.32\textwidth}
\begin{code}
data T = A | B; f1, f2 :: Int -> T
g _
  | A <- f1 1,  A <- f2 1  = ()
  | A <- f1 2,  A <- f2 2  = ()
  ...
  | A <- f1 N,  A <- f2 N  = ()
\end{code}
\end{minipage}%
\begin{minipage}[b]{0.68\textwidth}
\scalebox{0.95}{
\begin{forest}
  grdtree,
  [
    [{$\grdlet{a_1}{|f1 1|}, \grdbang{a_1}, \grdcon{|A|}{a_1}, \grdlet{b_1}{|f2 1|}, \grdbang{b_1}, \grdcon{|A|}{b_1}$} [1]]
    [{$\grdlet{a_2}{|f1 2|}, \grdbang{a_2}, \grdcon{|A|}{a_2}, \grdlet{b_2}{|f2 2|}, \grdbang{b_2}, \grdcon{|A|}{b_2}$} [2]]
    [... [...]]
    [{$\grdlet{a_{N}}{|f1 N|}, \grdbang{a_{N}}, \grdcon{|A|}{a_{N}}, \grdlet{b_{N}}{|f2 N|}, \grdbang{b_{N}}, \grdcon{|A|}{b_{N}}$} [N]]]
\end{forest}}
\end{minipage}

Each of the $N$ GRHS can fall through in two distinct ways: By failure of
either pattern guard involving |f1| or |f2|. Initially, we start out with
a single input $\nabla$. After the first equation it will split into two
sub-$\nabla$s, after the second into four, and so on. This exponential pattern
repeats $N$ times, and leads to horrible performance!

Instead of \emph{refining} $\nabla$ with the pattern guard, leading to a split,
we could just continue with the original $\nabla$, thus forgetting about the
$a_1 \ntermeq |A|$ or $b_1 \ntermeq |A|$ constraints. In terms of the modeled
refinement type, $\nabla$ is still a superset of both refinements, and thus a
sound overapproximation.

% Another realisation is that each of the temporary variables binding the pattern
% guard expressions are only scrutinised once, within the particular branch they
% are bound. That makes one wonder why we record a fact like $a_1 \ntermeq
% |A|$ in the first place. Some smart "garbage collection" process might get
% rid of this additional information when falling through to the next equation,
% where the variable is out of scope and can't be accessed. The same procedure
% could even find out that in the particular case of the split that the $\nabla$
% falling through from the |f1| match models a superset of the $\nabla$ falling
% through from the |f2| match (which could additionally diverge when calling
% |f2|). This approach seemed far to complicated for us to pursue.

In our implementation, we call this \emph{throttling}: We limit the number of
reaching $\nabla$s to a constant. Whenever a split would exceed this limit, we
continue with the original input $\nabla$s, a conservative estimate, instead.
Intuitively, throttling corresponds to \emph{forgetting} what we matched on in
that particular subtree. Throttling is refreshingly easy to implement! Only the
last clause of $\uncann$, where splitting is performed, needs to change:
\[
\begin{array}{r@@{\,}c@@{\,}lcl}
\uncann(\overline{\nabla}, \gdtguard{(\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{t}) &=& (\throttle{\overline{\nabla}}{(\overline{\nabla} \addphiv (x \ntermeq K)) \, \overline{\nabla}'}, u) \\
  && \quad \text{where } (\overline{\nabla}', u) = \uncann(\overline{\nabla} \addphiv (\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}), t)
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

% For the sake of our above example we'll use 4 as the limit. The initial $\nabla$
% will be split by the first equation in two, which in turn results in 4 $\nabla$s
% reaching the third equation. Here, splitting would result in 8 $\nabla$s, so
% we throttle, so that the same four $\nabla$s reaching the third equation also
% reach the fourth equation, and so on. Basically, every equation is checked for
% overlaps \emph{as if} it was the third equation, because we keep on forgetting
% what was matched beyond that.

\subsection{Maintaining residual \extension{COMPLETE} sets}
\label{ssec:residual-complete}

Our implementation tries hard to make the inhabitation test as efficient as
possible. For example, we represent $\Delta$s by a mapping from variables to
their positive and negative constraints for easier indexing. But there are also
asymptotical improvements. Consider the following function:
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
f A1     = 1
f A2     = 2
...
f A1000  = 1000
\end{code}
\end{minipage}
\end{minipage}

|f| is exhaustively defined. To see that we need to perform an inhabitation
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

\subsection{Reporting uncovered patterns}

The expansion function $\expand$ in \cref{fig:gen} exists purely for presenting
uncovered patterns to the user. It is very simple and doesn't account for
negative information, leading to surprising warnings. Consider a definition
like |f True = ()|. The computed uncovered set of |f| is the refinement type
$\reft{x:|Bool|}{x \ntermeq \bot, x \ntermeq |True|}$, which crucially
contains no positive information! As a result, expanding the resulting $\nabla$
(which looks quite similar) with $\expand$ just unhelpfully reports |_| as an
uncovered pattern. Our implementation thus splits the $\nabla$ into (possibly
multiple) sub-$\nabla$s with positive information on variables we have negative
information on before handing off to $\expand$.

\section{Evaluation}
\label{sec:eval}

We have implemented \lyg in a to-be-released version of GHC.
To put the new coverage checker to the
test, we performed a survey of real-world Haskell code using the
\texttt{head.hackage} repository
\footnote{\url{https://gitlab.haskell.org/ghc/head.hackage/commit/30a310fd8033629e1cbb5a9696250b22db5f7045}}.
\texttt{head.hackage} contains a sizable collection of libraries and minimal
patches necessary to make them build with a development version of GHC.
We identified those libraries which compiled without coverage warnings using
GHC 8.8.3 (which uses \gmtm as its checking algorithm) but emitted warnings
when compiled using our \lyg version of GHC.

Of the 361 libraries in \texttt{head.hackage}, seven of them revealed coverage
issues that only \lyg warned about. Two of the libraries, \texttt{pandoc} and
\texttt{pandoc-types}, have cases that
were flagged as redundant due to \lyg's improved treatment of guards and
term equalities. One library, \texttt{geniplate-mirror}, has a case that was
redundant by way of long-distance information. Another library,
\texttt{generic-data}, has a case that is redundant due to bang patterns.

The last three libraries---\texttt{Cabal}, \texttt{HsYAML}, and
\texttt{network}---were the most
interesting. \texttt{HsYAML} in particular defines this function:

\begin{code}
go' _ _ _ xs | False = error (show xs)
go' _ _ _ xs = err xs
\end{code}

The first clause is clearly unreachable, and \lyg now flags it as such.
However, the authors of \texttt{HsYAML} likely left in this clause because it is
useful for debugging purposes. One can comment out the second clause and remove
the |False| guard to quickly try out a code path that prints a more detailed
error message. Moreover, leaving the first clause in the code ensures that it
is typechecked and less susceptible to bitrotting over time.

We may consider
adding a primitive function |keepAlive| such that
|keepAlive False| does not get marked as redundant in order to support use
cases like \texttt{HsYAML}'s. The unreachable code in \texttt{Cabal} and
\texttt{network} is of a
similar caliber and would also benefit from |keepAlive|.

\subsection{Performance tests}

{\floatstyle{plain}
\restylefloat{figure}
\begin{figure}

\begin{tabular}{c || r r r || r r r ||}
\cline{2-7}
\textbf{}                                  & \multicolumn{3}{c||}{\textbf{Time (milliseconds)}} & \multicolumn{3}{c||}{\textbf{Megabytes allocated}} \\ \cline{2-7}
\textbf{}                                  & \multicolumn{1}{c||}{8.8.3} & \multicolumn{1}{c||}{HEAD} & \multicolumn{1}{c||}{\% change}
                                           & \multicolumn{1}{c||}{8.8.3} & \multicolumn{1}{c||}{HEAD} & \multicolumn{1}{c||}{\% change} \\ \hline
\multicolumn{1}{||c||}{\texttt{T11276}}    &  1.16 & 1.69 &  45.7\% &   1.86 & 2.39 &  28.6\% \\
\multicolumn{1}{||c||}{\texttt{T11303}}    &  28.1 & 18.0 & -36.0\% &   60.2 & 39.9 & -33.8\% \\
\multicolumn{1}{||c||}{\texttt{T11303b}}   &  1.15 & 0.39 & -65.8\% &   1.65 & 0.47 & -71.8\% \\
\multicolumn{1}{||c||}{\texttt{T11374}}    &  4.62 & 3.00 & -35.0\% &   6.16 & 3.20 & -48.1\% \\
\multicolumn{1}{||c||}{\texttt{T11822}}    & 1,060 & 16.0 & -98.5\% &  2,010 & 27.9 & -98.6\% \\
\multicolumn{1}{||c||}{\texttt{T11195}}    & 2,680 & 22.3 & -99.2\% &  3,080 & 39.5 & -98.7\% \\
\multicolumn{1}{||c||}{\texttt{T17096}}    & 7,470 & 16.6 & -99.8\% & 17,300 & 35.4 & -99.8\% \\
\multicolumn{1}{||c||}{\texttt{PmSeriesS}} &  44.5 & 2.58 & -94.2\% &   52.9 & 6.19 & -88.3\% \\
\multicolumn{1}{||c||}{\texttt{PmSeriesT}} &  48.3 & 6.86 & -85.8\% &   61.4 & 17.6 & -71.4\% \\
\multicolumn{1}{||c||}{\texttt{PmSeriesV}} &   131 & 4.54 & -96.5\% &    139 & 9.53 & -93.2\% \\ \hline
\end{tabular}

\caption{The relative compile-time performance of GHC 8.8.3 (which implements \gmtm) and HEAD
         (which implements \lyg) on test cases designed to stress-test coverage checking.}
\label{fig:perf}
\end{figure}
}

To compare the efficiency of \gmtm and \lyg quantitatively, we
collected a series of test cases from GHC's test suite that are designed to test
the compile-time performance of coverage checking. \Cref{fig:perf} lists each of these 11 test
cases. Test cases with a \texttt{T} prefix are taken from user-submitted bug reports
about the poor performance of \gmtm. Test cases with a
\texttt{PmSeries} prefix are adapted from \citet{maranget:warnings},
which presents several test cases that caused GHC to exhibit exponential running times
during coverage checking.

We compiled each test case with GHC 8.8.3, which uses \gmtm as its checking
algorithm, and GHC HEAD, which uses \lyg. We measured (1) the time spent in the
desugarer, the phase of compilation in which coverage checking occurs, and (2)
how many megabytes were allocated during desugaring. \Cref{fig:perf} shows
these figures as well as the percent change going from 8.8.3 to HEAD. Most
cases exhibit a noticeable improvement under \lyg, with the exception of
\texttt{T11276}. Investigating \texttt{T11276} suggests that the performance
of GHC's equality constraint solver has become more expensive in HEAD
~\cite{gitlab:17891}, and these extra costs outweigh the performance benefits
of using \lyg.

\subsection{GHC issues} \label{sec:ghc-issues}

Implementing \lyg in GHC has fixed over 30 bug reports related
to coverage checking. These include:

\begin{itemize}
  \item
    Better compile-time performance
    \cite{gitlab:11195,gitlab:11528,gitlab:17096,gitlab:17264}

  \item
    More accurate warnings for empty |case| expressions
    \cite{gitlab:10746,gitlab:13717,gitlab:14813,gitlab:15450,gitlab:17376}

  \item
    More accurate warnings due to \lyg's desugaring
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
handles many of the subtleties of GADTs, guards, and laziness mentioned in
\cref{sec:problem}. Despite this, the \gmtm algorithm still gives incorrect
warnings in many cases.

\subsubsection{\gmtm does not consider laziness in its full glory}

The formalism in \citet{gadtpm} incorporates strictness constraints, but
these constraints can only arise from matching against data constructors.
\gmtm does not consider strict matches that arise from strict fields of
data constructors or bang patterns. A consequence of this is that \gmtm
would incorrectly warn that |v| (\cref{ssec:strictness}) is missing a case for
|SJust|, even though such a case is unreachable. \lyg, on the other hand,
more thoroughly tracks strictness when desugaring Haskell programs.

\subsubsection{\gmtm's treatment of guards is shallow}

\gmtm can only reason about guards through an abstract term oracle. Although
the algorithm is parametric over the choice of oracle, in practice the
implementation of \gmtm in GHC uses an extremely simple oracle that can only
reason about guards in a limited fashion. More sophisticated uses of guards,
such as in this variation of the |safeLast| function from \cref{sssec:viewpat},
will cause \gmtm to emit erroneous warnings:

\begin{code}
safeLast2 xs
  | (x : _)  <- reverse xs = Just x
  | []       <- reverse xs = Nothing
\end{code}

While \gmtm's term oracle is customisable, it is not as simple to customize
as one might hope. The formalism in \citet{gadtpm} represents all guards as
|p <- e|, where |p| is a pattern and |e| is an expression. This is a
straightforward, syntactic representation, but it also makes it more difficult to
analyse when |e| is a complicated expression. This is one of the reasons why
it is difficult for \gmtm to accurately give warnings for the |safeLast|
function, since it would require recognizing that both clauses scrutinise
the same expression in their view patterns.

\lyg makes analysing term equalities simpler by first desugaring guards
from the surface syntax to guard trees. The $\addphi$ function, which is
roughly a counterpart to \gmtm's term oracle, can then reason
about terms arising from patterns. While $\addphi$ is already more powerful
than a trivial term oracle, its real strength lies in the fact that it can
easily be extended, as \lyg's treatment of view patterns
(\cref{ssec:extviewpat}) demonstrates. While \gmtm's term oracle could be
improved to accomplish the same thing, it is unlikely to be as
straightforward of a process as extending $\addphi$.

\subsection{Comparison with similar coverage checkers}

\subsubsection{Structural and semantic pattern matching analysis in Haskell}

\citet{kalvoda2019structural} implement a variation of \gmtm that leverages an
SMT solver to give more accurate coverage warnings for programs that use
guards. For instance, their implementation can conclude that
the |signum| function from \cref{ssec:guards} is exhaustive. This is something
that \lyg cannot do out of the box, although it would be possible to
extend $\addphi$ with SMT-like reasoning about booleans and linear integer arithmetic.
% \ryan{Sebastian: is this the thing that would need to be extended?}
% \sg{Yes, I imagine that $\addphi$ would match on arithmetic expressions and then
% add some kind of new $\delta$ constraint to $\Delta$. $\adddelta$ would then
% have to do the actual linear arithmetic reasoning, \eg conclude from
% $x \not< e, x \ntermeq e, x \not> e$ (and $x \ntermeq \bot$) that $x$ is not
% inhabited, quite similar to a \extension{COMPLETE} set.}

\subsubsection{Warnings for pattern matching}
\label{ssec:maranget}

\citet{maranget:warnings} presents a coverage checking algorithm for OCaml. While
OCaml is a strict language, the algorithm claims to be general enough to handle
languages with non-strict semantics such as Haskell. That claim however builds on
a broken understanding of laziness. Given the following definition:
\begin{code}
f True  = 1
f _     = 2
\end{code}

\noindent
\citeauthor{maranget:warnings} implies that |f bot| evaluates to 2, which is of
course incorrect. Also, replacing the wild card by a match on |False| would no
longer be a complete match according to their formalism.

\subsubsection{Elaborating dependent (co)pattern matching}

\citet{dependent-copattern} design a coverage checking algorithm for a dependently
typed language with both pattern matching and \emph{copattern} matching, which is
a feature that GHC lacks. While the source language for their algorithm is much more
sophisticated than GHC's, their algorithm is similar to \lyg in that it first
desugars definitions by clauses to \emph{case trees}. Case trees present a simplified
form of pattern matching that is easier to check for coverage, much like guard trees
in \lyg. Guard trees could take inspiration from case trees should a future
version of GHC add dependent types or copatterns.

\subsection{Positive and negative information}
\label{ssec:negative-information}

\lyg's use of positive and negative constructor constraints is inspired by
\citet{sestoft1996ml}, which uses positive and negative information to
implement a pattern-match compiler for ML. Sestoft utilises positive and
negative information to generate decision trees that avoid scrutinizing the
same terms repeatedly. This insight is equally applicable to coverage checking
and is one of the primary reasons for \lyg's efficiency.

Besides efficiency, the accuracy of redundancy warnings involving \extension{COMPLETE} sets hinge
on negative constraints. To see why this isn't possible in other checkers that
only track positive information, such as those of
\citet{gadtpm} (\cref{ssec:gmtm})
and
\citet{maranget:warnings} (\cref{ssec:maranget}),
consider the following example:

\begin{minipage}{\textwidth}
\begin{minipage}{0.4\textwidth}
\centering
\begin{code}
pattern True' = True
{-# COMPLETE True', False #-}
\end{code}
\end{minipage} %
\begin{minipage}{0.4\textwidth}
\centering
\begin{code}
f False  = 1
f True'  = 2
f True   = 3
\end{code}
\end{minipage}
\end{minipage}

\noindent
\gmtm would have to commit to a particular \extension{COMPLETE} set when
encountering the match on |False|, without any semantic considerations.
Choosing $\{|True'|,|False|\}$ here will mark the third GRHS as redundant,
while choosing $\{|True|,|False|\}$ won't. GHC's implementation used to try
each \extension{COMPLETE} set in turn and would disambiguate using a
complicated metric based on the number and kinds of warnings the choice of each set would generate
\cite{complete-users-guide},
which was broken still \cite{gitlab:13363}.

Negative constraints make \lyg efficient in other places too, such as in this example:

\begin{minipage}{\textwidth}
\begin{minipage}{0.4\textwidth}
\centering
\begin{code}
data T = A1 | ... | A1000
\end{code}
\end{minipage} %
\begin{minipage}{0.4\textwidth}
\centering
\begin{code}
h A1  _   = 1
h _   A1  = 2
\end{code}
\end{minipage}
\end{minipage}

\noindent
In |h|, \gmtm would split the value vector (which is like \lyg's
$\Delta$s without negative constructor constraints) into 1000 alternatives over
the first match variable, and then \emph{each} of the 999 value vectors reaching
the second GRHS into another 1000 alternatives over the second match variable.
Negative constraints allow \lyg to compress the 999 value vectors falling through
into a single one indicating that the match variable can no longer be |A1|.
\citeauthor{maranget:warnings} detects wildcard matches to prevent blowup, but
only can find a subset of all uncovered patterns in doing so
(\cref{ssec:maranget}).

\subsection{Strict fields in inhabitation testing}
\label{ssec:strict-fields}

To our knowledge, the $\mathsf{Inst}$ function in \cref{fig:inh} is the first
inhabitation test in a coverage checking algorithm to take strict fields into
account. This is essential in order to conclude that the |v| function from
\cref{ssec:strictness} is exhaustive, which is something that even coverage
checkers for call-by-value languages get wrong. For example, we ported |v|
to OCaml and Idris
\footnote{Idris has separate compile-time and runtime semantics, the latter
of which is call by value.}:

\begin{minipage}{\textwidth}
\begin{minipage}{0.4\textwidth}
\centering
\begin{code}
type void;;
let v (None : void option) : int = 0;;
\end{code}
\end{minipage} %
\begin{minipage}{0.4\textwidth}
\centering
\begin{code}
v : Maybe Void -> Int
v Nothing = 0
\end{code}
\end{minipage}
\end{minipage}

OCaml 4.07.1 incorrectly warns that |v| is missing a case on |Some _|.
Idris 1.3.2 does not warn,
but if one adds an extra |v (Just _) = 1| clause, it will not warn that the extra
clause is redundant.

\subsection{Refinement types in coverage checking}

In addition to \lyg, Liquid Haskell uses refinement types to perform a limited form of
exhaustivity checking \cite{liquidhaskell,refinement-reflection}.
While exhaustiveness checks are optional in ordinary
Haskell, they are mandatory for Liquid Haskell, as proofs written in Liquid
Haskell require user-defined functions to be total (and therefore exhaustive)
in order to be sound.
For example, consider this non-exhaustive function:

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

As a result, attempting to use |fibPartial| in a proof will fail to verify
unless the user can prove that |fibPartial| is only ever invoked with the
arguments |0| or |1|.

\section{Conclusion}

In this paper, we describe Lower Your Guards, a coverage checking algorithm that
distills rich pattern matching into simple guard trees. Guard trees are
amenable to analyses that are not easily expressible in coverage checkers
that work over structural pattern matches. This allows \lyg to report more
accurate warnings while also avoiding performance issues when checking
complex programs. Moreover, \lyg is extensible, and we anticipate that this will
streamline the process of checking new forms of patterns in the future.

\bibliography{references}

\else % \ifdefined\MAIN
% Appendix
\appendix
\section{Appendix}\label{sec:appendix}
\input{appendix}
\fi

\end{document}
