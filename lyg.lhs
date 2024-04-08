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
\documentclass[acmsmall,screen]{acmart}\settopmatter{}

%\documentclass[acmsmall,review,anonymous]{acmart}\settopmatter{printfolios=true,printccs=false,printacmref=false}

%include custom.fmt

%% Journal information
%% The following is specific to ICFP '20 and the paper
%% 'Lower Your Guards'
%% by Sebastian Graf, Simon Peyton Jones, and Ryan G. Scott.
%%
\setcopyright{rightsretained}
\acmPrice{}
\acmDOI{10.1145/3408989}
\acmYear{2020}
\copyrightyear{2020}
\acmSubmissionID{icfp20main-p57-p}
\acmJournal{PACMPL}
\acmVolume{4}
\acmNumber{ICFP}
\acmArticle{107}
\acmMonth{8}

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

\usepackage{mathpartir} % For derivation trees
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

\usepackage{hyperref}
\usepackage[nameinlink]{cleveref}

\input{macros}

\clubpenalty = 1000000
\widowpenalty = 1000000
\displaywidowpenalty = 1000000

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
A compiler should warn if a function defined by pattern matching
does not cover its inputs---that is, if there are missing or redundant
patterns. Generating such warnings accurately is difficult
for modern languages due to the myriad of language features
that interact with pattern matching. This is especially true in Haskell, a language with
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
       <concept_id>10011007.10011006.10011073</concept_id>
       <concept_desc>Software and its engineering~Software maintenance tools</concept_desc>
       <concept_significance>300</concept_significance>
       </concept>
   <concept>
       <concept_id>10011007.10011006.10011008.10011024.10011035</concept_id>
       <concept_desc>Software and its engineering~Procedures, functions and subroutines</concept_desc>
       <concept_significance>100</concept_significance>
       </concept>
   <concept>
       <concept_id>10011007.10011006.10011008.10011024.10011032</concept_id>
       <concept_desc>Software and its engineering~Constraints</concept_desc>
       <concept_significance>300</concept_significance>
       </concept>
   <concept>
       <concept_id>10011007.10011006.10011008.10011009.10011012</concept_id>
       <concept_desc>Software and its engineering~Functional languages</concept_desc>
       <concept_significance>300</concept_significance>
       </concept>
   <concept>
       <concept_id>10011007.10011006.10011008.10011009.10011021</concept_id>
       <concept_desc>Software and its engineering~Multiparadigm languages</concept_desc>
       <concept_significance>300</concept_significance>
       </concept>
 </ccs2012>
\end{CCSXML}

\ccsdesc[500]{Software and its engineering~Compilers}
\ccsdesc[300]{Software and its engineering~Software maintenance tools}
\ccsdesc[100]{Software and its engineering~Procedures, functions and subroutines}
\ccsdesc[300]{Software and its engineering~Constraints}
\ccsdesc[300]{Software and its engineering~Functional languages}
\ccsdesc[300]{Software and its engineering~Multiparadigm languages}
%% End of generated code


%% Keywords
%% comma separated list
\keywords{Haskell, pattern matching, guards, strictness}  %% \keywords are mandatory in final camera-ready submission

\maketitle

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
Particularly tricky are: \emph{Generalised Algebraic Datatypes} (\emph{GADTs}) where the \emph{type} of a match can determine
what \emph{values} can possibly appear \citep{recdatac}; and \emph{local type-equality constraints} brought into
scope by pattern matching \citep{outsideinx}.

% If coverage checking catches mistakes in pattern matches, then who checks for
% mistakes in the coverage checker itself? It is a surprisingly frequent
% occurrence for coverage checkers to contain bugs that impact correctness.
% This is especially true in Haskell, which has a rich pattern language, and the
% Glasgow Haskell Compiler (GHC) complicates the story further by adding
% pattern-related language extensions. Designing a coverage checker that can cope
% with all of these features is no small task.

The current state of the art for coverage checking in a richer language of this
sort is \emph{GADTs Meet Their Match} \citep{gadtpm}, or \gmtm{} for short. It
presents an algorithm that handles the intricacies of checking GADTs, lazy
patterns, and pattern guards. However \gmtm{} is monolithic and does not
account for a number of important language features; it gives incorrect results
in certain cases; its formulation in terms of structural pattern matching makes
it hard to avoid some serious performance problems; and its implementation in
GHC, while a big step forward over its predecessors, has proved complex and
hard to maintain.

In this paper we propose a new, compositional coverage-checking algorithm,
called Lower Your Guards (\lyg), that is simpler, more modular, \emph{and}
more powerful than \gmtm (see \Cref{ssec:gmtm}). Moreover, it avoids \gmtm's
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

\item
  The evaluation against a large number of Haskell packages
  (\Cref{sec:eval}) provides evidence that \lyg is sound.
  In order to discuss soundness formally in \Cref{sec:soundness}, we turn the
  informal semantics of guard trees and refinement types in \Cref{sec:overview}
  into formal semantics.
  We also list mechanisms that render \lyg incomplete in order to guarantee good
  performance.

\item
  We discuss the wealth of related work in \Cref{sec:related}.
\end{itemize}

% Contributions from our call:
% \begin{itemize}
% \item Things we do that weren't done in GADTs meet their match
%   \begin{itemize}
%     \item Strictness, including bang patterns, data structures with strict fields.
% \item 	COMPLETE pragmas
% \item	newtype pattern matching
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


\section{The Problem We Want to Solve} \label{sec:problem}

What makes coverage checking so difficult in a language like Haskell? At first
glance, implementing a coverage checking algorithm might appear simple: just
check that every function matches on every possible combination of data
constructors exactly once. A function must match on every possible combination
of constructors in order to be exhaustive, and it must match on them exactly
once to avoid redundant matches.

This algorithm, while concise, leaves out many nuances. What constitutes a
``match''? Haskell has multiple matching constructs, including function definitions,
|case| expressions, and guards. How does one count the
number of possible combinations of data constructors? This is not a simple exercise
since term and type constraints can make some combinations of constructors
unreachable if matched on, and some combinations of data constructors can
overlap others. Moreover, what constitutes a ``data constructor''?
In addition to traditional data constructors, GHC features \emph{pattern synonyms}
~\citep{patsyns},
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
guardDemo c1 c2  | c1 == 'a'                            = 0
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
The next line illustrates that each GRHS may have multiple guards,
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
\noindent
Intuitively, |signum| is exhaustive since the combination of |(>)|, |(==)|, and
|(<)| covers all possible |Int|s. This is hard for a machine to check,
because doing so requires knowledge about the properties of |Int|
inequalities. Clearly, coverage checking for guards is
undecidable in general. However, while we cannot accurately check \emph{all} uses of guards,
we can at least give decent warnings for some common cases.
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

\subsection{Programmable Patterns}

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
% \sg{Fun fact: I think this desugaring + GVN from \Cref{ssec:extviewpat} would
% be enough to handle this desugaring of overloaded literals. I think it's still
% worthwhile to handle them similarly to PatSyns for efficiency and similarity
% reasons. But it renders the point we are trying to make here somewhat moot.}
% For instance, if the |isZero n = False| clause were omitted,
% concluding that |isZero| is non-exhaustive would require reasoning about
% properties of the |Eq| and |Num| classes. For this reason, it can be worthwhile
% to have special checking treatment for common numeric types such as |Int| or
% |Double|. In general, however, coverage checking patterns with overloaded
% literals is undecidable.

\subsubsection{View Patterns}
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
prove that the |safeLast| function is exhaustive:
\begin{code}
safeLast :: [a] -> Maybe a
safeLast (reverse -> [])       = Nothing
safeLast (reverse -> (x : _))  = Just x
\end{code}

\subsubsection{Pattern Synonyms}
\label{ssec:patsyn}

Pattern synonyms~\citep{patsyns} allow abstraction over patterns themselves.
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
\noindent
The pattern synonym |Nil| matches precisely when the view pattern
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
\citep{complete-users-guide}.
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
reachable or not.
Consider:

\begin{code}
f :: Bool -> Bool -> Int
f _     False  = 1
f True  False  = 2
f _     _      = 3
\end{code}

\noindent
Is the second clause redundant?
In a strict language such as OCaml or Lean the answer is ``Yes'', but
in lazy Haskell the answer is ``No''.
To see that, consider the call |f (error "boom") True|, an expression that in
a strict language would immediately evaluate the error in the argument |(error
"boom")| by-value before making the call.

In Haskell, however, the second argument is not evaluated until it is needed.
Concretely, after falling through the first clause that does not match in the
second argument, the second clause will evaluate the first argument in order to
match against |True|.
Doing so forces the error, to much the same effect as in a strict language, and we
see that |f (error "boom") True| evaluates to |error "boom"|.
However, if we \emph{remove} the second clause, |f (error "boom") True|
would evaluate to |3|, because the first argument is never needed during
pattern-matching.
Since removing the clause changes the semantics of the function, it
cannot be redundant, but its right-hand side is \emph{inaccessible} still
(\Cref{sssec:inaccessibility}).

We could have used a different error such as |undefined| or a non-terminating
expression such as |loop = loop| in the example above.
The Haskell Language Report~\citep{haskell2010} does not distinguish between
these different kinds of divergence, referring to them as $\bot$, and we do the
same here.
There are a number of language features which interact with $\bot$ in the
context of pattern-matching.

\subsubsection{Redundancy versus Inaccessibility}
\label{sssec:inaccessibility}

The example function |f| above demonstrates that when reporting unreachable
equations, we must distinguish between \emph{redundant} and \emph{inaccessible}
cases.
A redundant equation can be removed from a function without changing its
semantics, whereas an inaccessible equation cannot, even though its right-hand
side is unreachable.
The examples below illustrate the challenges for \lyg in more detail:

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
\noindent
Within |u|, the equations that return |1| and |3| could be deleted without
changing the semantics of |u|, so they are classified as \emph{redundant}.
Within |u'|, the right-hand sides of the equations that return |1| and |2|
are inaccessible, but they cannot both be redundant because their clause
evaluates the parameter; $|u'|~\bot~|=|~\bot$.
As a result, \lyg picks the first equation in |u'| as inaccessible to keep
alive the pattern-match on the parameter, and the second equation as redundant.
Inaccessibility suggests to the programmer that |u'| might benefit from a
refactor to render the first equation redundant as well (e.g., |u' () = 3|).

Observe that |u| and |u'| have completely different warnings, but the
only difference between the two functions is whether the second equation uses |True| or |False| in its guard.
Moreover, this second equation affects the warnings for \emph{other} equations.
This demonstrates that determining whether code is redundant or inaccessible
is a non-local problem.
Inaccessibility may seem like a corner case, but GHC's users have
reported many bugs of this sort (\Cref{sec:ghc-issues}).

\subsubsection{Strict Fields}

Just like Haskell function parameters, fields of data constructors may hide
arbitrary computations as well.
However, Haskell programmers can opt into extra strict evaluation by giving a
data type strict fields, such as in this example:

\begin{code}
data Void -- No data constructors; only inhabitant is bottom
data SMaybe a = SJust !!a | SNothing

v :: SMaybe Void -> Int
v SNothing   = 0
v (SJust _)  = 1   -- Redundant!
\end{code}

\noindent
The ``!'' in the definition of |SJust| makes the constructor strict, so
|(SJust bot) = bot| semantically, in contrast to the regular lazy |Just|
constructor.

Curiously, the strict field semantics of |SJust| makes the second equation of
$v$ redundant!
Since $\bot$ is the only inhabitant of type |Void|, the only inhabitants of
|SMaybe Void| are |SNothing| and $\bot$.  The former will match on the first equation;
the latter will make the first equation diverge.  In neither case will execution
flow to the second equation, so it is redundant and can be deleted.

\subsubsection{Bang Patterns}

Strict data-constructor fields are one mechanism for adding extra strictness in ordinary Haskell, but
GHC adds another in the form of \emph{bang patterns}. When a value |v| is matched
against a bang pattern |!pat|, first |v| is evaluated to weak-head normal form (WHNF),
a step that might diverge, and then |v| is matched against |pat|.
Here is a variant of $v$, this time using the standard, lazy |Maybe| data type:

\begin{code}
v' :: Maybe Void -> Int
v' Nothing = 0
v' (Just !_) = 1    -- Not redundant, but GRHS is inaccessible
\end{code}
The inhabitants of the type |Maybe Void| are $\bot$, |Nothing|, and $(|Just bot|)$.
The input $\bot$ makes the first equation diverge; |Nothing| matches on the first equation;
and $(|Just bot|)$ makes the second equation diverge because of the bang pattern.
Therefore, none of the three inhabitants will result in the right-hand side of
the second equation being reached. Note that the second equation is inaccessible, but not redundant
(\Cref{sssec:inaccessibility}).

\subsection{Type-Equality Constraints}

Besides strictness, another way for pattern matches to be rendered unreachable
is by way of \emph{type equality constraints}. A popular method for introducing
equalities between types is matching on GADTs \citep{recdatac}. The following examples
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
\noindent
When |g1| matches against |T1|, the |b| in the type |T Int b| is known to be a |Bool|,
which is why matching the second argument against |False| or |True| will typecheck.
Phrased differently, matching against
|T1| brings into scope an \emph{equality constraint} between the types
|b| and |Bool|. GHC has a powerful type inference engine that is equipped to
reason about type equalities of this sort \citep{outsideinx}.

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
Besides GHC's current coverage checker \citep{gadtpm}, there are a variety of
other coverage checking algorithms that account for GADTs,
including those for OCaml \citep{ocamlgadts},
Dependent ML \citep{deadcodexi,xithesis,dependentxi}, and
Stardust \citep{dunfieldthesis}.
% \lyg continues this tradition---see
% \ryan{What section?}\sg{It's a little implicit at the moment, because it just works. Not sure what to reference here.} for \lyg's take on GADTs.


\section{Lower Your Guards: A New Coverage Checker}
\label{sec:overview}

\begin{figure}
\includegraphics{pipeline.pdf}
\caption{Bird's eye view of pattern match checking}
\label{fig:pipeline}
\end{figure}

\begin{figure}
\centering
\[
\begin{array}{cc}
\textbf{Meta variables} & \textbf{Pattern syntax} \\
\begin{array}{rl}
  x,y,z,f,g,h   &\text{Term variables} \\
  a,b,c         &\text{Type variables} \\
  K             &\text{Data constructors} \\
  P             &\text{Pattern synonyms} \\
  T             &\text{Type constructors} \\
  l             &\text{Literal} \\
  \mathit{expr} &\text{Expressions} \\
\end{array} &
\begin{array}{rcl}
  \mathit{defn}   &\Coloneqq& \overline{clause} \\
  \mathit{clause} &\Coloneqq&  f \; \overline{\mathit{pat}} \; \mathit{match} \\
  \mathit{pat}    &\Coloneqq& x \mid |_| \mid K \; \overline{\mathit{pat}} \mid x|@|\mathit{pat} \mid |!|\mathit{pat} \mid \mathit{expr} \rightarrow \mathit{pat} \\
  \mathit{match}  &\Coloneqq& \mathtt{=} \; \mathit{expr} \mid \overline{\mathit{grhs}} \\
  \mathit{grhs}   &\Coloneqq& \mathtt{\mid} \; \overline{guard} \; \mathtt{=} \; \mathit{expr} \\
  \mathit{guard}  &\Coloneqq& \mathit{pat} \leftarrow \mathit{expr} \mid \mathit{expr} \mid \mathtt{let} \; x \; \mathtt{=} \; \mathit{expr} \\
\end{array}
\end{array}
\]

\caption{Source syntax: A desugared Haskell}
\label{fig:srcsyn}
\end{figure}

\begin{figure}
\centering
\[ \textbf{Guard syntax} \]
\[
\begin{array}{cc}
\arraycolsep=2pt
\begin{array}{rclcl}
  k,n,m       & \in &\mathbb{N}&    & \\
  K           & \in &\Con &         & \\
  x,y,a,b     & \in &\Var &         & \\
  \tau,\sigma & \in &\Type&\Coloneqq& a \mid ... \\
  e           & \in &\Expr&\Coloneqq& x \mid  \genconapp{K}{\tau}{\gamma}{e} \mid ... \\
\end{array} &
\arraycolsep=2pt
\begin{array}{rclcl}
  \gamma & \in    &\TyCt&\Coloneqq& \tau_1 \typeeq \tau_2 \mid ... \\

  p      & \in    &\Pat &\Coloneqq& \_ \mid K \; \overline{p} \mid ... \\ % used in 3.4 when we generate inhabiting patterns

  g      & \in    &\Grd &\Coloneqq& \grdlet{x:\tau}{e} \\
         &        &     &\mid     & \grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x} \\
         &        &     &\mid     & \grdbang{x} \\
\end{array}
\end{array}
\]

\[ \textbf{Clause tree syntax} \]
\[
\arraycolsep=2pt
\begin{array}{rclcll}
  t & \in & \Gdt &\Coloneqq& \gdtrhs{k} \mid \gdtpar{t_1}{t_2} \mid \gdtguard{g}{t}         \\
  u & \in & \Ant &\Coloneqq& \antrhs{\Theta}{k} \mid \antpar{u_1}{u_2} \mid \antbang{\Theta}{u} \\
\end{array}
\]

\[ \textbf{Refinement type syntax} \]
\[
\arraycolsep=2pt
\begin{array}{rcl@@{\quad}l}
  \Gamma &\Coloneqq& \varnothing \mid \Gamma, x:\tau \mid \Gamma, a & \text{Context} \\
  \varphi &\Coloneqq& \true \mid \false \mid \ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x} \mid x \ntermeq K \mid x \termeq \bot \mid x \ntermeq \bot \mid \ctlet{x}{e} & \text{Literals} \\
  \Phi &\Coloneqq& \varphi \mid \Phi \wedge \Phi \mid \Phi \vee \Phi & \text{Formula} \\
  \Theta &\Coloneqq& \reft{\Gamma}{\Phi} & \text{Refinement type} \\
\end{array}
\]

\caption{IR syntax}
\label{fig:syn}
\end{figure}

In this section, we describe our new coverage checking algorithm, \lyg.
\Cref{fig:pipeline} depicts a high-level overview, which divides into three steps:
\begin{itemize}
\item First, we desugar the complex source Haskell syntax (\cf \Cref{fig:srcsyn})
  into a \textbf{guard tree} $t \in \Gdt$ (\Cref{sec:desugar}).
  The language of guard trees is tiny but expressive, and allows the subsequent passes to be entirely
  independent of the source syntax.
  \lyg{} can readily be adapted to other languages simply by changing the desugaring
    algorithm.
\item Next, the resulting guard
  tree is then processed by two different functions (\Cref{sec:check}).   The function $\ann(t)$ produces
  an \textbf{annotated tree} $u \in \Ant$, which has the same general branching structure as $t$ but
  describes which clauses are accessible, inaccessible, or redundant.
  The function $\unc(t)$, on the other hand, returns a \emph{refinement type} $\Theta$
  \citep{rushby1998subtypes,boundschecking}
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
    Achieving modularity by clearly separating the source syntax (\Cref{fig:srcsyn})
    from the intermediate language (\Cref{fig:syn}).

  \item
    Correctly accounting for strictness in identifying redundant and inaccessible
    code (\Cref{ssec:strict-fields}).

  \item
    Using detailed term-level reasoning
    (\Cref{fig:gen,fig:add,fig:inh}),
    which \gmtm does not.

  \item
    Using \emph{negative information} to sidestep serious performance issues in
    \gmtm without changing the worst-case complexity (\Cref{ssec:negative-information}).
    This also enables
    graceful degradation (\Cref{ssec:throttling})
    and the ability to handle \extension{COMPLETE}
    sets properly (\Cref{ssec:residual-complete}).

  \item
    Fixing various bugs present in \gmtm, both in the paper \citep{gadtpm} and
    in GHC's implementation thereof (\Cref{sec:ghc-issues}).

\end{itemize}


\subsection{Desugaring to Guard Trees} \label{sec:desugar}

\begin{figure}

  \[ \ruleform{\begin{array}{c}
      \ds(\mathit{defn}) = \Gdt,\quad \ds(clause) = \Gdt,\quad \ds(\mathit{grhs}) = \Gdt \\
      k_{\mathit{rhs}} \; \text{is the index of the right hand side}\; \mathit{rhs}
      \end{array}} \]
\[
\begin{array}{l}
\begin{array}{lcl}

\ds(\mathit{clause}_1\,...\,\mathit{clause}_n) &=&
  \raisebox{3px}{\begin{forest}
    baseline,
    grdtree,
    grhs/.style={tier=rhs,edge={-}},
    [ [{$\ds(\mathit{clause}_1)$}] [...] [{$\ds(\mathit{clause}_n)$}] ] ]
  \end{forest}} \\
\\
\ds(f \; \mathit{pat}_1\,...\,\mathit{pat}_n \; \mathtt{=} \; \mathit{rhs}) &=&
  \raisebox{3px}{\begin{forest}
    baseline,
    grdtree,
    [ [{$\ds(x_1, \mathit{pat}_1)\,...\,\ds(x_n, \mathit{pat}_n)$} [{$k_{\mathit{rhs}}$}] ] ]
  \end{forest}} \\
\ds(f \; \mathit{pat}_1\,...\,\mathit{pat}_n \; grhs_1\,...\,grhs_m) &=&
  \raisebox{3px}{\begin{forest}
    baseline,
    grdtree,
    grhs/.style={tier=rhs,edge={-}},
    [ [{$\ds(x_1, \mathit{pat}_1)\,...\,\ds(x_n, \mathit{pat}_n)$} [{$\ds(grhs_1)$}] [...] [{$\ds(grhs_m)$}] ] ]
  \end{forest}} \\
\ds(\mathtt{\mid} \; guard_1\,...\,guard_n \; \mathtt{=} \; \mathit{rhs}) &=&
  \raisebox{3px}{\begin{forest}
    baseline,
    grdtree,
    [ [{$\ds(guard_1)\,...\,\ds(guard_n)$} [{$k_{\mathit{rhs}}$}] ] ]
  \end{forest}} \\
\end{array} \\ \\
\multicolumn{1}{c}{\ruleform{ \ds(guard) = \overline{\Grd},\quad \ds(x, \mathit{pat}) = \overline{\Grd} }} \\[2mm]
\begin{array}{lcl@@{\hspace{5mm}}l}
\ds(\mathit{pat} \leftarrow \mathit{expr}) &=& \grdlet{x}{\mathit{expr}}, \ds(x, \mathit{pat})
   & x \, \text{fresh} \\
\ds(\mathit{expr}) &=& \grdlet{y}{\mathit{expr}}, \ds(y, |True|)
   & y \, \text{fresh} \\
\ds(\mathtt{let} \; x \; \mathtt{=} \; \mathit{expr}) &=& \grdlet{x}{\mathit{expr}} \\
\end{array} \\ \\
\begin{array}{lcl@@{\hspace{5mm}}l}
\ds(x, y) &=& \grdlet{y}{x} \\
\ds(x, |_|) &=& \epsilon \\
\ds(x, K \; \mathit{pat}_1\,...\,\mathit{pat}_n) &=& \grdbang{x}, \grdcon{K \; y_1\,...\,y_n}{x}, \ds(y_1, \mathit{pat}_1), ..., \ds(y_n, \mathit{pat}_n)
   & y_i \, \text{fresh}\;(\dagger) \\
\ds(x, y|@|\mathit{pat}) &=& \grdlet{y}{x}, \ds(y, \mathit{pat}) \\
\ds(x, |!|\mathit{pat}) &=& \grdbang{x}, \ds(x, \mathit{pat}) \\
\ds(x, \mathit{expr} \rightarrow \mathit{pat}) &=& \grdlet{y}{\mathit{expr} \; x}, \ds(y, \mathit{pat})
   & y \, \text{fresh}
\end{array}
\end{array}
\]
\caption{$\ds$esugaring from source language to $\Gdt$}
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

The language of guard trees $\Gdt$ is much smaller; its graphical syntax is
given in \Cref{fig:syn}. All of the syntactic redundancy of the source language
is translated into a minimal form very similar to pattern guards.  We start
with an example:

\begin{code}
f (Just (!xs,_))  ys@Nothing   = True
f Nothing         (g -> True)  = False
\end{code}

\noindent
This desugars to the following guard tree (where the $x_i$ represent |f|'s arguments):

\begin{forest}
  grdtree,
  [
    [{$\grdbang{x_1}, \grdcon{|Just t1|}{x_1}, \grdbang{t_1}, \grdcon{(t_2, t_3)}{t_1}, \grdbang{t_2}, \grdlet{xs}{t_2}, \grdlet{ys}{x_2}, \grdbang{ys}, \grdcon{|Nothing|}{ys}$} [1]]
    [{$\grdbang{x_1}, \grdcon{|Nothing|}{x_1}, \grdlet{t_4}{|g x2|}, \grdbang{t_4}, \grdcon{|True|}{t_4}$} [2]]]
\end{forest}
\\
The first line says ``evaluate $x_1$; then match $x_1$ against |Just t1|;
then evaluate $t_1$; then match $t_1$ against $(t_2,t_3)$'' and so on. If any
of those matches fail, we fall through into the second line. Note that we write
$\gdtguard{g_1, ..., g_n}{t}$ instead of
$\vcenter{\hbox{\begin{forest}
    grdtree,
    grhs/.style={tier=rhs,edge={-}},
    [[{$g_1$} [... [{$g_n$} [{$t$}]]]]]
  \end{forest}}}$
for notational convenience.

Informally, matching a guard tree may \emph{succeed} (binding
the variables bound in the tree), \emph{fail}, or \emph{diverge}.
Referring to the syntax of guard trees in \Cref{fig:syn}, matching is
defined as follows:
\begin{itemize}
\item Matching a guard tree $\gdtrhs{k}$ succeeds, and selects the $k$'th right
  hand side of the pattern match group.
\item Matching a guard tree $\gdtpar{t_1}{t_2}$ means matching against $t_1$;
  if that succeeds, the overall match succeeds; if not, match against $t_2$.
\item Matching a guard tree $\gdtguard{\grdbang{x}}{t}$ evaluates $x$;
  if that diverges the match diverges; if not match $t$.
\item Matching a guard tree
  $\gdtguard{\grdcon{\genconapp{K}{a}{\gamma}{y}}{x}}{t}$ matches $x$ against
  constructor |K|. If the match succeeds, bind $\overline{a}$ to the type
  components, $\overline{\gamma}$ to the constraint components and
  $\overline{y}$ to the term components, then match $t$. If the constructor
  match fails, then the entire match fails.
\item Matching a guard tree $\gdtguard{\grdlet{x}{e}}{t}$ binds $x$
  (lazily) to $e$, and matches $t$.
\end{itemize}
See \Cref{ssec:sem} for a formal account of this semantics.
The desugaring algorithm, $\ds$, is given in \Cref{fig:desugar}.
It is a straightforward recursive descent over the source syntax, with a little
bit of administrative bureaucracy to account for renaming.
It also generates an abundance of fresh
temporary variables; in practice, the implementation of $\ds$ can be smarter
than this by looking at the pattern (which might be a variable match or
as-pattern) when choosing a name for a temporary variable.
In that case, it is important that every binder in the source language has
a unique name.

% It is assumed that the top-level match variables
% $x_1$ through $x_n$ in the $clause$ cases have special, fixed names. All other
% variables that aren't bound in arguments to $\ds$ have fresh names.

Notice that both ``structural'' pattern-matching in the source language (e.g.
the match on |Nothing| in the second equation), and view patterns (e.g. |g -> True|)
can straightforwardly translated into a single form of matching in guard trees.
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
    [{$\grdbang{mx},\, \grdcon{|Nothing|}{mx},\, \grdbang{my},\, \grdcon{|Nothing|}{my}$} [1]]
    [{$\grdbang{my},\, \grdcon{|Just y|}{my}$}
     [{$ \grdbang{mx},\, \grdcon{|Just x|}{mx},\, \grdlet{t}{|x == y|},\, \grdbang{t},\, \grdcon{|True|}{t}$} [2]]
      [{$\grdbang{otherwise},\, \grdcon{|True|}{otherwise}$} [3]]]]
\end{forest}

\noindent
Notice that the pattern guard |(Just x <- mx)| and the
boolean guard |(x == y)| have both turned into the same constructor-matching
construct in the guard tree.

In equation $(\dagger)$ of \Cref{fig:desugar} we generate an explicit
bang guard $!x$ to reflect the fact that pattern matching against a data constructor
requires evaluation.  However, Haskell's |newtype| declarations introduce data
constructors that are \emph{not} strict, so their desugaring is just like $(\dagger)$ but
with no $!x$ (\Cref{ssec:newtypes}).
From this point onwards, then, strictness is expressed \emph{only} through bang
guards $!x$, while constructor guards $\grdcon{|K a b|}{y}$ are not considered
strict.

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
% tree} (see \Cref{fig:syn} for the syntax):
%
% \begin{forest}
%   grdtree
%   [
%     [{$\grdbang{mx},\, \grdcon{|Nothing|}{mx},\, \grdbang{my},\, \grdcon{|Nothing|}{my}$} [1]]
%     [{$\grdbang{mx},\, \grdcon{|Just x|}{mx},\, \grdbang{my},\, \grdcon{|Just y|}{my}$}
%       [{$\grdlet{t}{|x == y|},\, \grdbang{t},\, \grdcon{|True|}{t}$} [2]]
%       [{$\grdbang{otherwise},\, \grdcon{|True|}{otherwise}$} [3]]]]
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
% is expressed by sequence ($\gdtpar{}{}$). The leaves in a guard tree each
% correspond to a GRHS.

\subsection{Checking Guard Trees} \label{sec:check}

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
\unc(\Theta, \gdtpar{t_1}{t_2}) &=& \unc(\unc(\Theta, t_1), t_2) \\
\unc(\Theta, \gdtguard{\grdbang{x}}{t}) &=& \unc(\Theta \andtheta (x \ntermeq \bot), t) \\
\unc(\Theta, \gdtguard{\grdlet{x}{e}}{t}) &=& \unc(\Theta \andtheta (\ctlet{x}{e}), t) \\
\unc(\Theta, \gdtguard{\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}}{t}) &=& (\Theta \andtheta (x \ntermeq K)) \uniontheta \unc(\Theta \andtheta (\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}), t) \\
\end{array}
\]
\[ \ruleform{ \ann(\Theta, t) = u } \]
\[
\begin{array}{lcl}
\ann(\Theta,\gdtrhs{n}) &=& \antrhs{\Theta}{n} \\
\ann(\Theta, \gdtpar{t_1}{t_2}) &=& \antpar{\ann(\Theta, t_1)}{\ann(\unc(\Theta, t_1), t_2)} \\
\ann(\Theta, \gdtguard{\grdbang{x}}{t}) &=& \antbang{\Theta \andtheta (x \termeq \bot)}{\ann(\Theta \andtheta (x \ntermeq \bot), t)} \\
\ann(\Theta, \gdtguard{\grdlet{x}{e}}{t}) &=& \ann(\Theta \andtheta (\ctlet{x}{e}), t) \\
\ann(\Theta, \gdtguard{\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}}{t}) &=& \ann(\Theta \andtheta (\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}), t) \\
\end{array}
\]

\caption{Coverage checking}
\label{fig:check}
\end{figure}

The next step in \Cref{fig:pipeline} is to transform the guard tree into an \emph{annotated tree}, $\Ant$, and
an \emph{uncovered set}, $\Theta$.
Taking the latter first, the uncovered set describes all the input
values of the match that are not covered by the match.  We use the
language of \emph{refinement types} to describe this set (see \Cref{fig:syn}).
A refinement type $\Theta = \reft{x_1{:}\tau_1, \ldots, x_n{:}\tau_n}{\Phi}$
denotes the vector of values $x_1 \ldots x_n$ that satisfy the predicate $\Phi$.
For example:
$$
\begin{array}{rcl}
  \reft{ x{:}|Bool|}{ \true } & \text{denotes} & \{ \bot, |True|, |False| \} \\
  \reft{ x{:}|Bool|}{ x \ntermeq \bot } & \text{denotes} & \{ |True|, |False| \} \\
  \reft{ x{:}|Bool|}{ x \ntermeq \bot \wedge \ctcon{|True|}{x} } & \text{denotes} & \{ |True| \} \\
  \reft{ mx{:}|Maybe Bool|}{ mx \ntermeq \bot \wedge \ctcon{|Just x|}{mx} \wedge x \ntermeq \bot } & \text{denotes} & \{ |Just True|, |Just False| \} \\
\end{array}
$$
The syntax of $\Phi$ is given in \Cref{fig:syn}. It consists of a collection
of \emph{literals} $\varphi$, combined with conjunction and disjunction.
Unconventionally, however, a literal may bind one or more variables, and those
bindings are in scope in conjunctions to the right. This can readily be formalised
by giving a type system for $\Phi$, and we do so in \Cref{ssec:sem}, where we
define satisfiability of $\Phi$ in formal detail.
The literal $\true$ means ``true'', as illustrated above; while
$\false$ means ``false'', so that $\reft{\Gamma}{\false}$ denotes the empty set $\emptyset$.

The uncovered set function $\unc(\Theta, t)$, defined in \Cref{fig:check},
computes a refinement type describing the values in $\Theta$ that are not
covered by the guard tree $t$.  It is defined by a simple recursive descent
over the guard tree, using the operation $\Theta \andtheta \varphi$ (also
defined in \Cref{fig:check}) to extend $\Theta$ with an extra literal
$\varphi$.

While $\unc$ finds a refinement type describing values that are \emph{not}
matched by a guard tree (its set of $\unc$ncovered values), the function $\ann$
finds refinements describing values that \emph{are} matched by a guard tree, or
that cause matching to diverge. It does so by producing an \emph{annotated
tree} (hence $\ann$nnotate), whose syntax is given in \Cref{fig:syn}. An
annotated tree has the same general structure as the guard tree from whence it
came: in particular the top-to-bottom compositions $\gdtpar{}{}$ are in the same
places.  But in an annotated tree, each $\antrhs{\Theta}{k}$ leaf is annotated with a
refinement type $\Theta$ describing the input values that will lead to that right-hand
side; and each $\antbang{\Theta}{\hspace{-0.6em}}$ node is annotated with a
refinement type that describes the input values on which matching will diverge.
Once again, $\ann$ can be defined by a simple recursive descent over the guard
tree (\Cref{fig:check}), but note that the second equation uses $\unc$ as an
auxiliary function\footnote{ Our implementation avoids this duplicated work --
see \Cref{ssec:interleaving} -- but the formulation in \Cref{fig:check}
emphasises clarity over efficiency.}.

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
% |Maybe a|, my : |Maybe a|)}{\true}$.   Refinement types are described in \Cref{fig:syn}.
% This type  is gradually refined until finally we have $\Theta_{|liftEq|} :=
% \reft{(mx : |Maybe a|, my : |Maybe a|)}{\Phi}$ as the uncovered set, where the
% predicate $\Phi$ is semantically equivalent to:
% \[
% \begin{array}{cl}
%          & (mx \ntermeq \bot \wedge (mx \ntermeq |Nothing| \vee (\ctcon{|Nothing|}{mx} \wedge my \ntermeq \bot \wedge my \ntermeq |Nothing|))) \\
%   \wedge & (mx \ntermeq \bot \wedge (mx \ntermeq |Just| \vee (\ctcon{|Just x|}{mx} \wedge my \ntermeq \bot \wedge (my \ntermeq |Just|)))) \\
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
% like $\{ (mx, my) \mid mx \ntermeq \bot, \grdcon{|Nothing|}{mx}, my
% \ntermeq \bot, \grdcon{|Nothing|}{my} \}$, which is inhabited by
% $(|Nothing|, |Nothing|)$. Similarly, we can find inhabitants for
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
% desugaring function $\ds$ in \Cref{fig:desugar})! We have yet to find a
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

\subsection{Reporting Errors} \label{sec:inhabitants}


\begin{figure}
\centering
\[ \textbf{Collect accessible $(\overline{k})$, inaccessible $(\overline{n})$ and $\red$edundant $(\overline{m})$ GRHSs} \]
\[ \ruleform{ \red(u) = (\overline{k}, \overline{n}, \overline{m}) } \]
\[
\begin{array}{lcl}
\red(\antrhs{\Theta}{n}) &=& \begin{cases}
    (\epsilon, \epsilon, n), & \text{if $\generate(\Theta) = \emptyset$} \\
    (n, \epsilon, \epsilon), & \text{otherwise} \\
  \end{cases} \\
\red(\antpar{t}{u}) &=& (\overline{k}\,\overline{k'}, \overline{n}\,\overline{n'}, \overline{m}\,\overline{m'}) \hspace{0.5em} \text{where} \begin{array}{l@@{\,}c@@{\,}l}
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

\[ \textbf{$\generate$enerate inhabitants of $\Theta$} \]
\[ \ruleform{ \generate(\Theta) = \mathcal{P}(\overline{p}) } \]
\[
\begin{array}{c}
   \generate(\reft{\Gamma}{\Phi}) = \left\{ \expand(\nabla, \mathsf{dom}(\Gamma)) \mid \nabla \in \normalise(\nreft{\Gamma}{\varnothing}, \Phi) \right\}
\end{array}
\]

\[ \textbf{$\normalise$ormalise $\Phi$ into $\nabla$s} \]
\[ \ruleform{ \normalise(\nabla, \Phi) = \mathcal{P}(\nabla) } \]
\[
\begin{array}{lcl}

  \normalise(\nabla, \varphi) &=& \begin{cases}
    \left\{ \nreft{\Gamma'}{\Delta'} \right\} & \text{where $\nreft{\Gamma'}{\Delta'} = \nabla \addphi \varphi$} \\
    \emptyset & \text{otherwise} \\
  \end{cases} \\
  \normalise(\nabla, \Phi_1 \wedge \Phi_2) &=& \bigcup \left\{ \normalise(\nabla', \Phi_2) \mid \nabla' \in \normalise(\nabla, \Phi_1) \right\} \\
  \normalise(\nabla, \Phi_1 \vee \Phi_2) &=& \normalise(\nabla, \Phi_1) \cup \normalise(\nabla, \Phi_2)

\end{array}
\]

\[ \textbf{$\expand$xpand variables to $\Pat$ with $\nabla$} \]
\[ \ruleform{ \expand(\nabla, x) = p, \quad \expand(\nabla, \overline{x}) = \overline{p} } \]
\[
\begin{array}{lcl}

  \expand(\nabla, \overline{x}) &=& \overline{\expand(\nabla, x)} \\
  \expand(\nreft{\Gamma}{\Delta}, x) &=& \begin{cases}
    K \; \expand(\nreft{\Gamma}{\Delta}, \overline{y}) & \text{if $\rep{\Delta}{x} \termeq \deltaconapp{K}{a}{y} \in \Delta$} \\
    \_ & \text{otherwise} \\
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

The final step in \Cref{fig:pipeline} is to report errors.  First, let us focus on reporting
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
\noindent
This is not very helpful to report to the user. It would be far preferable
to produce one or more concrete \emph{inhabitants} of $\Theta_f$ to report, something like this:
\begin{Verbatim}
    Missing equations for function 'f':
      f Nothing  = ...
      f (Just B) = ...
      f (Just C) = ...
\end{Verbatim}
$\generate$enerating these inhabitants is the main technical challenge in this
work.
It is done by $\generate(\Theta)$ in \Cref{fig:gen},
which we discuss next in \Cref{sec:generate}.
But first notice that, by calling the very same function $\generate$,
we can readily define the function $\red$, which reports a triple
of (accessible, inaccessible, $\red$edundant) GRHSs,
as needed in our overall pipeline (\Cref{fig:pipeline}).
$\red$ is defined in \Cref{fig:gen}:
\begin{itemize}
\item Having reached a leaf $\antrhs{\Theta}{k}$, if the refinement type $\Theta$ is
  uninhabited ($\generate(\Theta) = \emptyset$), then no input values can cause
  execution to reach the right-hand side $k$, and it is redundant.
\item Having reached a node $\antbang{\Theta}{t}$, if $\Theta$ is inhabited there is a possibility of
  divergence. Now suppose that all the GRHSs in $t$ are redundant.  Then we should pick the first
  of them and mark it as inaccessible.
\item The case for $\antpar{t}{u}$ follows by congruence: just combine the classifications of $t$ and $u$.
\end{itemize}
To illustrate the second case, consider |u'| from \Cref{sssec:inaccessibility} and its annotated tree:

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
$\leadsto$
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

Refinement types $\Theta_2$ and $\Theta_3$ are uninhabited (because of the
|False| guards). But we cannot delete both GRHSs as redundant,
because that would make the call |u' bot| return 3 rather
than diverging.  Rather, we want to report the first GRHSs as
inaccessible, leaving all the others as redundant.

\subsection{Generating Inhabitants of a Refinement Type} \label{sec:generate}

Thus far, all our functions have been very simple, syntax-directed
transformations, but they all ultimately depend on the single function
$\generate$, which does the real work.  That is our new focus.
As \Cref{fig:gen} shows, $\generate(\Theta)$ takes a refinement
type $\Theta = \reft{\Gamma}{\Phi}$
and returns a (possibly-empty) set of patterns $\overline{p}$ (syntax in \Cref{fig:syn})
that give the shape of values that inhabit $\Theta$.
We do this in two steps:
\begin{itemize}
\item Flatten $\Theta$ into a disjunctive union of \emph{normalised refinement types} $\nabla$,
  by the call $\normalise(\nreft{\Gamma}{\varnothing}, \Phi)$; see \Cref{sec:normalise}.
\item For each such $\nabla$, expand $\Gamma$ into a list of patterns, by the call
  $\expand(\nabla, \mathsf{dom}(\Gamma))$; see \Cref{sec:expand}.
\end{itemize}
A normalised refinement type $\nabla$ is either empty ($\false$) or of the form
$\nreft{\Gamma}{\Delta}$. It is similar to a refinement type $\Theta =
\reft{\Gamma}{\Phi}$, but it takes a much more restricted form (\Cref{fig:gen}):
$\Delta$ is simply a conjunction of literals $\delta$; there are no disjunctions
as in $\varphi$.
Instead, disjunction reflects in the fact that $\normalise$ returns a \emph{set}
of normalised refinement types.

Beyond these syntactic differences, we enforce the following
invariants on a $\nabla = \nreft{\Gamma}{\Delta}$:
\begin{enumerate}
  \item[\inv{1}] \emph{Mutual compatibility}: No two constraints in $\Delta$
    should \emph{conflict} with each other, where $x \termeq \bot$ conflicts with
    $x \ntermeq \bot$, and $x \termeq K \; \mathunderscore \; \mathunderscore$
    conflicts with $x \ntermeq K$, for all $x$.
  \item[\inv{2}] \emph{Inhabitation}: If $x{:}\tau \in \Gamma$ and $\tau$
  reduces to a data type under type constraints in $\Delta$, there must be at
  least one constructor $K$ (or $\bot$) which $x$ can be instantiated to without
  contradicting \inv{1}; see \Cref{sec:inhabitation}.
  \item[\inv{3}] \emph{Triangular form}: A $x \termeq y$ constraint implies
    absence of any other constraint mentioning |x| in its left-hand side.
  \item[\inv{4}] \emph{Single solution}: There is at most one positive
    constructor constraint $x \termeq \deltaconapp{K}{a}{y}$ for a given |x|.
\end{enumerate}
\noindent
Invariants \inv{1} and \inv{2} prevent $\Delta$ being self-contradictory,
so that $\nabla$ (which denotes a set of values) is uninhabited.
We use $\nabla = \false$ to represent an uninhabited refinement type, canonically.
Invariants \inv{3} and \inv{4} require $\Delta$ to be in solved form,
from which it is easy to ``read off'' a value that inhabits it --- this
reading-off step is performed by $\expand$ (\Cref{sec:expand}).

The setup here is directly analogous to the setup of standard unification
algorithms. In unification, we start with a set of equalities between types
(analogous to $\Theta$) and, by unification, normalise it to a substitution
(analogous to $\nabla$).  That substitution can itself be regarded as a set of
equalities, but in a restricted form.  And indeed our normalisation algorithm
(described in \Cref{sec:normalise}) is a form of generalised unification.

Notice that we allow $\Delta$ to contain variable/variable equalities
$x \termeq y$, providing a function $\Delta(x)$ (defined in
\Cref{fig:gen}) that follows these indirections to find the
``representative'' of $x$ in $\Delta$.  A perfectly viable alternative
would be to omit such indirections from $\Delta$ and instead
aggressively substitute them away.

% It is often helpful to think of a $\Delta$ as a partial function from |x| to
% its \emph{solution}, informed by the single positive constraint $x \termeq
% \deltaconapp{K}{a}{y} \in \Delta$, if it exists. For example, $x \termeq
% |Nothing|$ can be understood as a function mapping |x| to |Nothing|. This
% reasoning is justified by \inv{4}. Under this view, $\Delta$ looks like a
% substitution. As we'll see in \Cref{sec:normalise}, this view is
% supported by a close correspondence with unification algorithms.
%
% \inv{3} is actually a condition on the represented substitution. Whenever we
% find out that $x \termeq y$, for example when matching a variable pattern |y|
% against a match variable |x|, we have to merge all the other constraints on |x|
% into |y|, and say that |y| is the representative of |x|'s equivalence class.
% This is so that every new constraint we record on |y| also affects |x| and vice
% versa. The process of finding the solution of |x| in $x \termeq y, y \termeq
% |Nothing|$ then entails \emph{walking} the substitution, because we have to look
% up constraints twice: The first lookup will find |x|'s representative |y|, the
% second lookup on |y| will then find the solution |Nothing|.
%
% We use $\Delta(x)$ to look up the representative of $x$ in $\Delta$ (see \Cref{fig:gen}).
% Therefore, we can assert that |x| has |Nothing| as a solution simply by writing $\Delta(x)
% \termeq |Nothing| \in \Delta$.

\subsection{Expanding a Normalised Refinement Type to a Pattern} \label{sec:expand}

$\expand$xpanding a match variable $x$ under $\nabla$ to a pattern, by calling
$\expand$ in \Cref{fig:gen}, is straightforward and overloaded to operate
similarly on multiple match variables. When there is a solution like $\Delta(x)
\termeq |Just y|$ in $\Delta$ for the match variable $x$ of interest,
recursively expand |y| and wrap it in a |Just|. Invariant \inv{4} guarantees
that there is at most one such solution and $\expand$ is well-defined. When
there is no solution for $x$, return $\_$. See \Cref{ssec:report} for how we
improve on that in the implementation by taking negative
information into account.

\subsection{Normalising a Refinement Type} \label{sec:normalise}

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
  &&&& \quad \text{where $\overline{y'} \subseteq \overline{y}$ bind strict fields} \\
  \nreft{\Gamma}{\Delta} &\addphi& \ctlet{x{:}\tau}{\genconapp{K}{\sigma}{\gamma}{e}} &=& \nreft{\Gamma,x{:}\tau,\overline{a}}{\Delta} \adddelta \overline{a \typeeq \sigma} \adddelta x \ntermeq \bot \adddelta x \termeq \deltaconapp{K}{a}{y} & (4) \\
  &&&& \quad \addphi \overline{\ctlet{y{:}\tau'}{e}} \qquad \text{where $\overline{a}\,\overline{y}$ fresh, $\overline{e{:}\tau'}$} \\
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
    \nreft{\Gamma}{(\Delta,\gamma)} & \parbox[t]{6cm}{if type checker deems $\gamma$ compatible with $\Delta$ \\ and $\forall x \in \mathsf{dom}(\Gamma): \inhabited{\nreft{\Gamma}{(\Delta,\gamma)}}{x}$} \\
    \false & \text{otherwise} \\
  \end{cases} & (9)\\
  \nreft{\Gamma}{\Delta} &\adddelta& x \termeq \deltaconapp{K}{a}{y} &=& \begin{cases}
    \nreft{\Gamma}{\Delta} \adddelta \overline{a \typeeq b} \adddelta \overline{y \termeq z} & \text{if $\rep{\Delta}{x} \termeq \deltaconapp{K}{b}{z} \in \Delta$ } \\
    \false & \text{if $\rep{\Delta}{x} \termeq \deltaconapp{K'}{b}{z} \in \Delta$ and $K \not= K'$} \\
    \false & \text{if $\rep{\Delta}{x} \ntermeq K \in \Delta$} \\
    \nreft{\Gamma}{(\Delta,\rep{\Delta}{x} \termeq \deltaconapp{K}{a}{y})} & \text{otherwise} \\
  \end{cases} & (10) \\
  \nreft{\Gamma}{\Delta} &\adddelta& x \ntermeq K &=& \begin{cases}
    \false & \text{if $\rep{\Delta}{x} \termeq \deltaconapp{K}{a}{y} \in \Delta$} \\
    \false & \text{if not $\inhabited{\nreft{\Gamma}{(\Delta,\rep{\Delta}{x} \ntermeq K)}}{x}$} \\
    \nreft{\Gamma}{(\Delta,\rep{\Delta}{x}\ntermeq K)} & \text{otherwise} \\
  \end{cases} & (11) \\
  \nreft{\Gamma}{\Delta} &\adddelta& x \termeq \bot &=& \begin{cases}
    \false & \text{if $\rep{\Delta}{x} \ntermeq \bot \in \Delta$} \\
    \nreft{\Gamma}{(\Delta,\rep{\Delta}{x}\termeq \bot)} & \text{otherwise} \\
  \end{cases} & (12) \\
  \nreft{\Gamma}{\Delta} &\adddelta& x \ntermeq \bot &=& \begin{cases}
    \false & \text{if $\rep{\Delta}{x} \termeq \bot \in \Delta$} \\
    \false & \text{if not $\inhabited{\nreft{\Gamma}{(\Delta,\rep{\Delta}{x}\ntermeq\bot)}}{x}$} \\
    \nreft{\Gamma}{(\Delta,\rep{\Delta}{x} \ntermeq \bot)} & \text{otherwise} \\
  \end{cases} & (13) \\
  \nreft{\Gamma}{\Delta} &\adddelta& x \termeq y &=&
    \begin{cases}
      \nreft{\Gamma}{\Delta} & \text{if $x' = y'$} \\
      \nreft{\Gamma}{((\Delta\!\setminus\!x'), x'\!\termeq\!y')} \adddelta (\restrict{\Delta}{x'}[y' / x'])
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

$\normalise$ormalisation, carried out by $\normalise$ in \Cref{fig:gen},
is largely a matter of repeatedly adding a literal $\varphi$ to a
normalised type, thus $\nabla \addphi \varphi$.  This function
is where all the work is done, in \Cref{fig:add}.
%
It does so by expressing a literal $\varphi$ in terms of simpler constraints
$\delta$, and calling out to $\!\adddelta\!$ to add the simpler constraints to $\nabla$.
$\normalise$, $\addphi$ and $\adddelta$ all work on the principle that if the
incoming $\nabla$ satisfies the Invariants \inv{1} to \inv{4} from
\Cref{sec:generate}, then either the resulting $\nabla$ is $\false$ or it
satisfies \inv{1} to \inv{4}.

In Equation (3), a pattern guard extends the context and adds suitable type
constraints and a positive constructor constraint arising from the binding.
Equation (4) of $\!\addphi\!$ performs some limited, but important reasoning
about let bindings: it flattens possibly nested constructor applications, such
as $\ctlet{|x|}{|Just True|}$, and asserts that such constructor applications
cannot be $\bot$. Note that Equation (6) simply discards let bindings that
cannot be expressed in $\nabla$; we will see an extension in
\Cref{ssec:extviewpat} that avoids this information loss.
% The last case of $\!\addphi\!$
% turns the syntactically and semantically identical subset of $\varphi$ into
% $\delta$ and adds that constraint via $\!\adddelta\!$.

That brings us to the prime unification procedure, $\!\adddelta\!$.
When adding $x \termeq |Just y|$, Equation (10), the unification procedure will first look for
a solution for $x$ with \emph{that same constructor}. Let's say there is
$\Delta(x) \termeq |Just u| \in \Delta$. Then $\!\adddelta\!$ operates on the
transitively implied equality $|Just y| \termeq |Just u|$ by equating type and
term variables with new constraints, \ie $|y| \termeq |u|$. The original
constraint, although not conflicting, is not added to the normalised refinement
type because of \inv{3}.

If there is a solution involving a different constructor like $\Delta(x)
\termeq |Nothing|$ or if there was a negative constructor constraint $\Delta(x)
\ntermeq |Just|$, the new constraint is incompatible with the
existing solution. Otherwise, the constraint is compatible and is added to
$\Delta$.

Adding a negative constructor constraint $x \ntermeq |Just|$ is quite similar (Equation (11)),
except that we have to make sure that $x$ still satisfies \inv{2}, which is
checked by the $\inhabited{\nabla}{\Delta(x)}$ judgment (\cf \Cref{sec:test})
in \Cref{fig:inh}. Handling positive and negative constraints involving $\bot$
is analogous.

Adding a type constraint $\gamma$ (Equation (9)) entails calling out to the type checker to
assert that the constraint is consistent with existing type constraints.
Afterwards, we have to ensure \inv{2} is upheld for \emph{all} variables in the
domain of $\Gamma$, because the new type constraint could have rendered a type
empty. To demonstrate why this is necessary, imagine we have $\nreft{x : a}{x
\ntermeq \bot}$ and try to add $a \typeeq |Void|$. Although the type constraint
is consistent, $x$ in $\nreft{x : a}{x \ntermeq \bot, a \typeeq |Void|}$ is no
longer inhabited. There is room for being smart about which variables we have
to re-check: For example, we can exclude variables whose type is a non-GADT
data type.

Equation (14) of $\!\adddelta\!$ equates two variables ($x \termeq y$) by
merging their equivalence classes. Consider the case where $x$ and $y$ are not
in the same equivalence class. Then $\Delta(y)$ is arbitrarily chosen to be the
new representative of the merged equivalence class. To uphold \inv{3}, all
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
% |v| from \Cref{ssec:strictness} does not have any uncovered patterns. And our
% approach should see that by looking at its uncovered set $\reft{x : |Maybe
% Void|}{x \ntermeq \bot \wedge x \ntermeq |Nothing|}$. Specifically, the
% candidate |SJust y| (for fresh |y|) for |x| should be rejected, because there
% is no inhabitant for |y|! $\bot$ is ruled out by the strict field and |Void|
% has no data constructors with which to instantiate |y|. Hence it is important
% to test guard-bound variables for inhabitants, too.

\subsection{Testing for Inhabitation} \label{sec:test} \label{sec:inhabitation}

\begin{figure}
\centering
\[ \textbf{Test if $x$ is inhabited considering $\nabla$} \quad
 \ruleform{ \inhabited{\nabla}{x} } \]
\[
\begin{array}{c}

  \inferrule*[right=\inhabitedbot]{
    (\nreft{\Gamma}{\Delta} \adddelta x \termeq \bot) \not= \false
  }{
    \inhabited{\nreft{\Gamma}{\Delta}}{x}
  }

  \qquad

  \inferrule*[right=\inhabitednocpl]{
    {x:\tau \in \Gamma \quad \cons(\nreft{\Gamma}{\Delta}, \tau) = \bot}
  }{
    \inhabited{\nreft{\Gamma}{\Delta}}{x}
  }

  \\
  \\

  \inferrule*[right=\inhabitedinst]{
    {x:\tau \in \Gamma \quad K \in \cons(\nreft{\Gamma}{\Delta}, \tau)}
    \\\\
    {\inst(\nreft{\Gamma}{\Delta}, x, K) \not= \false}
  }{
    \inhabited{\nreft{\Gamma}{\Delta}}{x}
  }

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
    \text{where $K : \forall \overline{a}. \overline{\gamma} \Rightarrow \overline{\sigma} \rightarrow \tau$, $\overline{a}\,\overline{y}$ fresh, $x:\tau_x \in \Gamma$, $\overline{y'} \subseteq \overline{y}$ bind strict fields} \\

\end{array}
\]

\caption{Testing for inhabitation}
\label{fig:inh}
\end{figure}

The process for adding a constraint to a normalised type above (which turned
out to be a unification procedure in disguise) makes use of an
\emph{inhabitation test} $\inhabited{\nabla}{x}$, depicted in \Cref{fig:inh}.
This tests whether there are any values of $x$ that satisfy $\nabla$. If not,
$\nabla$ does not uphold \inv{2}.
For example, the conjunction
$x \ntermeq |Just|, x \ntermeq |Nothing|, x \ntermeq \bot$ does not satisfy \inv{2},
because no value of $x$ satisfies all those constraints.

The \inhabitedbot judgment of $\inhabited{\nabla}{x}$ tries to instantiate $x$ to
$\bot$ to conclude that $x$ is inhabited. \inhabitedinst instantiates $x$ to one
of its data constructors. That will only work if its type ultimately reduces to
a data type under the type constraints in $\nabla$. Rule \inhabitednocpl will
accept unconditionally when its type is not a data type, \ie for $x : |Int ->
Int|$.

Note that the outlined approach is complete in the sense that
$\inhabited{\nabla}{x}$ is derivable if and only if |x| is actually inhabited
in $\nabla$, because that means we do not have any $\nabla$s floating around in
the checking process that actually are not inhabited and trigger false positive
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
$x \termeq |SJust y|, |y| \ntermeq \bot$, the latter of which leads to an
inhabitation test on |y|. That leads to instantiation of the |MkT| constructor,
which leads to constraints $|y| \termeq |MkT z|, z \ntermeq \bot$, and so on for
|z| \etc. An infinite chain of fruitless instantiation attempts!

In practice, we implement a fuel-based approach that conservatively assumes
that a variable is inhabited after $n$ such iterations (we have $n=100$ for
list-like constructors and $n=1$ otherwise) and consider supplementing that
with a simple termination analysis to detect uninhabited data types like |T|
in the future.

\section{Extensions} \label{sec:extensions}

\lyg is well equipped to handle the fragment of Haskell it was designed to
handle. But GHC extends Haskell in non-trivial ways. This section exemplifies
easy accommodation of new language features and measures to increase precision
of the checking process, demonstrating the modularity and extensibility of our
approach.

\subsection{Long-Distance Information}
\label{ssec:ldi}

Coverage checking should also work for |case| expressions and nested function
definitions, like
\begin{code}
f True  = 1
f x     = ... ^^ (case x of{ False -> 2; True -> 3 }) ...
\end{code}

\noindent
\gmtm and unextended \lyg will not produce any warnings for this definition.
But the reader can easily make the ``long distance connection'' that the last
GRHS of the |case| expression is redundant! That follows by context-sensitive
reasoning, knowing that |x| was already matched against |True|.

In terms of \lyg, the input values of the second GRHS of |f|, described by
$\Theta_{2}=\reft{x:|Bool|}{x \ntermeq \bot, x \ntermeq |True|}$, encode the
information we are after: we just have to start checking the |case| expression
starting from $\Theta_{2}$ as the initial set of reaching values instead of
$\reft{x:|Bool|}{\true}$. We already need $\Theta_2$ to determine whether the
second GRHS of |f| is accessible, so long-distance information comes almost for
free.

\subsection{Empty Case}

As can be seen in \Cref{fig:srcsyn}, Haskell function definitions need to have
at least one clause. That leads to an awkward situation when pattern matching
on empty data types, like |Void|:

\begin{minipage}{0.4\textwidth}
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
\lyg will report its GRHS as inaccessible! Hence GHC provides an extension,
called \extension{EmptyCase}, that allows the definition of |absurd3| above.
Such a |case| expression without any alternatives evaluates its argument to
WHNF and crashes when evaluation returns.

It is quite easy to see that $\Gdt$ lacks expressive power to desugar
\extension{EmptyCase} into, since all leaves in a guard tree need to have
corresponding GRHSs. Therefore, we need to introduce empty alternatives
$\gdtempty$ to $\Gdt$ and $\antempty$ to $\Ant$. This is how they affect the
checking process:
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
the guard tree, thus checking starts starts with
$\unc(\reft{\Gamma}{x \ntermeq \bot}, \gdtempty)$.

\subsection{View Patterns}
\label{ssec:extviewpat}

Our source syntax had support for view patterns to start with (\cf
\Cref{fig:srcsyn}). And even the desugaring we gave as part of the definition
of $\ds$ in \Cref{fig:desugar} is accurate. But this desugaring alone is
insufficient for the checker to conclude that |safeLast| from
\Cref{sssec:viewpat} is an exhaustive definition! To see why, let us look at its
guard tree:

\begin{forest}
  grdtree,
  [
    [{$\grdlet{|y1|}{|reverse x1|}, \grdbang{|y1|}, \grdcon{|Nothing|}{|y1|}$} [1]]
    [{$\grdlet{|y2|}{|reverse x1|}, \grdbang{|y2|}, \grdcon{|Just t1|}{|y2|}, \grdbang{|t1|}, \grdcon{|(t2, t3)|}{|t1|}$} [2]]]
\end{forest}

As far as \lyg is concerned, the matches on both |y1| and |y2| are
non-exhaustive. But that's actually too conservative: Both bind the same value!
By making the connection between |y1| and |y2|, the checker could infer that
the match was exhaustive.

This can be fixed by maintaining equivalence classes of semantically equivalent
expressions in $\Delta$, similar to what we do for variables. We simply extend
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
implementation, we use a trie to index expressions rapidly~\citep{triemaps} and
sacrifice reasoning modulo $\Delta$ in doing so. Plugging in an SMT solver to
decide $\equiv_{\Delta}$ would be more precise, but certainly less efficient.

\subsection{Pattern Synonyms}
\label{ssec:extpatsyn}

To accommodate checking of pattern synonyms $P$, we first have to extend the
source syntax and IR syntax by adding the syntactic concept of a
\emph{ConLike}:
\[
\begin{array}{cc}
\begin{array}{rcl}
  cl     &\Coloneqq& K \mid P \\
  \mathit{pat}    &\Coloneqq& x \mid |_| \mid \highlight{cl} \; \overline{\mathit{pat}} \mid x|@|\mathit{pat} \mid ... \\
\end{array} &
\begin{array}{rlcl}
  P \in           &\PS \\
  C \in           &\CL  &\Coloneqq& K \mid P \\
  p \in           &\Pat &\Coloneqq& \_ \mid \highlight{C} \; \overline{p} \mid ... \\
\end{array}
\end{array}
\]

\noindent
Assuming every definition encountered so far is changed to handle ConLikes $C$
instead of data constructors $K$, everything should work fine. So why
introduce the new syntactic variant in the first place? Consider
\begin{code}
pattern P = ()
pattern Q = ()
n = case P of Q -> 1; P -> 2
\end{code}
\noindent
If |P| and |Q| were data constructors, the first alternative of the
|case| would be redundant, because |P| cannot match |Q|.  But pattern synonyms
are quite different: a value produced by |P| might match a pattern |Q|, as indeed
is the case in this example.

Our solution is a conservative one: we weaken the test that sends $\nabla$ to $\false$
of Equation (10) in the definition of $\!\adddelta\!$ dealing with positive
ConLike constraints $x \termeq \deltaconapp{C}{a}{y}$:
\[
\begin{array}{r@@{\,}c@@{\,}lcl}
  \nreft{\Gamma}{\Delta} &\adddelta& x \termeq \deltaconapp{C}{a}{y} &=& \begin{cases}
    \nreft{\Gamma}{\Delta} \adddelta \overline{a \typeeq b} \adddelta \overline{y \termeq z} & \text{if $\rep{\Delta}{x} \termeq \deltaconapp{C}{b}{z} \in \Delta$ } \\
    \false & \text{if $\rep{\Delta}{x} \termeq \deltaconapp{C'}{b}{z} \in \Delta$ and \highlight{C \cap C' = \emptyset}} \\
    \false & \text{if $\rep{\Delta}{x} \ntermeq C \in \Delta$} \\
    \nreft{\Gamma}{(\Delta,\rep{\Delta}{x} \termeq \deltaconapp{C}{a}{y})} & \text{otherwise} \\
  \end{cases}
\end{array}
\]
\noindent
where the suggestive notation $C \cap C' = \emptyset$ is only true iff $C$ and
$C'$ are distinct data constructors.

Note that the slight relaxation means that the constructed $\nabla$ might
violate $\inv{4}$, specifically when $C \cap C' \not= \emptyset$. In practice
that condition only matters for the well-definedness of $\expand$, which in
case of multiple solutions (\ie $x \termeq P, x\termeq Q$) has to commit to one
of them for the purposes of reporting warnings. Fixing that requires a bit of
boring engineering.

Another subtle point appears in rule $(\dagger)$ in \Cref{fig:desugar}: should
we or should we not add a bang guard for pattern synonyms?  There is no way to
know without breaking the abstraction offered by the synonym.  In effect, its
strictness or otherwise is part of its client-visible semantics.  In our implementation,
we have (thus far) compromised by assuming that all pattern synonyms are strict for the
purposes of coverage checking \citep{gitlab:17357}.

\subsection{\extension{COMPLETE} Pragmas}
\label{ssec:complete}

In a sense, every algebraic data type defines its own builtin
\extension{COMPLETE} set, consisting of all its data constructors, so the
coverage checker already manages a single \extension{COMPLETE} set.

We have \inhabitedinst from \Cref{fig:inh} currently making sure that this
\extension{COMPLETE} set is in fact inhabited. We also have \inhabitednocpl
that handles the case when we cannot find \emph{any} \extension{COMPLETE} set
for the given type (think |x :: Int -> Int|). The prudent way to generalise this
is by looking up all \extension{COMPLETE} sets attached to a type and check
that none of them is completely covered:
\[
\begin{array}{cc}
  \inferrule*[right=\inhabitedbot]{
    (\nreft{\Gamma}{\Delta} \adddelta x \termeq \bot) \not= \false
  }{
    \inhabited{\nreft{\Gamma}{\Delta}}{x}
  }

  &

  \inferrule*[right=\inhabitedinst]{
    {x:\tau \in \Gamma \quad \cons(\nreft{\Gamma}{\Delta}, \tau)=\highlight{\overline{C_1,...,C_{n_i}}^i}}
    \\\\
    {\highlight{\overline{\inst(\nreft{\Gamma}{\Delta}, x, C_j) \not= \false}^i}}
  }{
    \inhabited{\nreft{\Gamma}{\Delta}}{x}
  }
\end{array}
\]
\[
\begin{array}{c}
  \cons(\nreft{\Gamma}{\Delta},\tau) = \begin{cases}
    \highlight{\overline{C_1,...,C_{n_i}}^i} & \parbox[t]{0.8\textwidth}{$\tau = T \; \overline{\sigma}$; \, \highlight{$T$ \text{ type constructor with \extension{COMPLETE} sets $\overline{C_1,...,C_{n_i}}^i$}} \\ (after normalisation according to the type constraints in $\Delta$)} \\
    \highlight{\epsilon} & \text{otherwise} \\
  \end{cases}
\end{array}
\]

$\cons$ was changed to return a list of all available \extension{COMPLETE} sets,
and \inhabitedinst tries to find an inhabiting ConLike $C_j$ in each one of them
in turn. Note that \inhabitednocpl is gone, because it coincides with
\inhabitedinst for the case where the list returned by $\cons$ was empty. The
judgment has become simpler and and more general at the same time!
A worry is that checking against multiple \extension{COMPLETE} sets so
frequently is computationally intractable.
We will worry about that in \Cref{ssec:residual-complete}.

\subsection{Literals}

The source syntax in \Cref{fig:newtypes} deliberately left out literal
patterns $l$. Literals are very similar to nullary data constructors, with one
caveat: they do not come with a builtin \texttt{COMPLETE} set. Before
\Cref{ssec:complete}, that would have meant quite a bit of hand waving and
complication to the $\inhabited{}{}$ judgment. Now, literals can be handled like
disjoint pattern synonyms (\ie $l_1 \cap l_2 = \emptyset$ for any two literals
$l_1, l_2$) without a \texttt{COMPLETE} set!

Overloaded literals can be supported as well, but we will find ourselves in a
similar situation as with pattern synonyms:
\begin{code}
instance Num () where
  fromInteger _ = ()
n = case (0 :: ()) of 1 -> 1; 0 -> 2 -- returns 1
\end{code}

\noindent
Considering overloaded literals to be disjoint would mean marking the first
alternative as redundant, which is unsound. Hence overloaded literals are
regarded as possibly overlapping, so they behave exactly like nullary pattern
synonyms without a \extension{COMPLETE} set.

\subsection{Newtypes}
\label{ssec:newtypes}

\begin{figure}
\[
\begin{array}{cc}
\begin{array}{c}
  cl \Coloneqq K \mid \highlight{N} \\
\end{array} &
\begin{array}{rlcl}
  N  \in &\NT \\
  C  \in &K \mid \highlight{N} \\
\end{array}
\end{array}
\]
\[
  \ds(x, N \; \mathit{pat}_1\,...\,\mathit{pat}_n) = \grdcon{N \; y_1\,...\,y_n}{x}, \ds(y_1, \mathit{pat}_1), ..., \ds(y_n, \mathit{pat}_n)
\]

\[
\begin{array}{lcl}
  \repnt{\Delta}{x} &=& \begin{cases}
    \repnt{\Delta}{y} & x \termeq y \in \Delta \text{ or } x \termeq |N|\;\overline{a}\;y \in \Delta \\
    x & \text{otherwise} \\
  \end{cases} \\
\end{array}
\]

\[
\begin{array}{r@@{\,}c@@{\,}l@@{\;}c@@{\;}ll}
  \nreft{\Gamma}{\Delta} &\addphi& \ctlet{x{:}\tau}{\genconapp{K}{\sigma}{\gamma}{e}} &=& \ldots \text{as before} \ldots & (4a) \\
  \nreft{\Gamma}{\Delta} &\addphi& \ctlet{x{:}\tau}{\ntconapp{N}{\sigma}{e}} &=& \nreft{\Gamma,x{:}\tau,\overline{a}}{\Delta} \adddelta \overline{a \typeeq \sigma} \adddelta x \termeq \ntconapp{N}{a}{y} \addphi \ctlet{y{:}\tau'}{e} & (4b) \\
  &&&& \quad \text{where $\overline{a}\,y \freein \Gamma$, $e{:}\tau'$} \\
\end{array}
\]

\[
\begin{array}{r@@{\,}c@@{\,}l@@{\;}c@@{\;}ll}
  \nreft{\Gamma}{\Delta} &\adddelta& x \termeq  \deltaconapp{K}{a}{y} &=& \ldots \text{as before} \ldots & (10a) \\
  \nreft{\Gamma}{\Delta} &\adddelta& \highlight{x \termeq \ntconapp{N}{a}{y}} &=&
    \begin{cases}
      \nreft{\Gamma}{\Delta} \adddelta \overline{a \typeeq b} \adddelta y \termeq z & \text{if $x' \termeq \ntconapp{N}{b}{z} \in \Delta$} \\
      \nreft{\Gamma}{\Delta} & \text{if $x' = \repnt{\Delta}{y'}$} \\
      \nreft{\Gamma}{((\Delta\!\setminus\!x'), x'\!\termeq\!\ntconapp{N}{a}{y'})} \adddelta (\restrict{\Delta}{x'}\![y'\!/\!x'])
        & \text{otherwise} \\
    \end{cases} & (10b)\\
    &&&&\text{where}~x' = \rep{\Delta}{x} \; \text{and} \; y' = \rep{\Delta}{y} \\
  \nreft{\Gamma}{\Delta} &\adddelta& x \ntermeq |K| &=& \ldots \text{as before} \ldots & (11a) \\
  \nreft{\Gamma}{\Delta} &\adddelta& x \ntermeq |N| &=& \false & (11b) \\
  \nreft{\Gamma}{\Delta} &\adddelta& x \termeq \bot &=& \begin{cases}
    \false & \text{if $\highlight{\repnt{\Delta}{x}} \ntermeq \bot \in \Delta$} \\
    \nreft{\Gamma}{(\Delta,\highlight{\repnt{\Delta}{x}}\termeq \bot)} & \text{otherwise} \\
  \end{cases} & (12) \\
  \nreft{\Gamma}{\Delta} &\adddelta& x \ntermeq \bot &=& \begin{cases}
    \false & \text{if $\highlight{\repnt{\Delta}{x}} \termeq \bot \in \Delta$} \\
    \false & \text{if not $\inhabited{\nreft{\Gamma}{(\Delta,\highlight{\repnt{\Delta}{x}}\ntermeq\bot)}}{x}$} \\
    \nreft{\Gamma}{(\Delta,\highlight{\repnt{\Delta}{x}} \ntermeq \bot)} & \text{otherwise} \\
  \end{cases} & (13) \\

\end{array}
\]

\caption{Extending coverage checking to handle newtypes}
\label{fig:newtypes}
\end{figure}

In Haskell, a newtype declares a new type that is completely
isomorphic to, but distinct from, an existing type. For example:
\begin{code}
newtype NT a = MkNT [a]
dup :: NT a -> NT a
dup (MkNT xs) = MkNT (xs ++ xs)
\end{code}
Here the type |NT a| is isomorphic to |[a]|.  We convert to and fro
using the ``data constructor'' |MkNT|, either as in a term or in a pattern.

To a first approximation, programmers interact with a newtype
as if it was a data type with a single constructor with a single field.
But the pattern-matching semantics of newtypes are different!
Here are three key examples that distinguish newtypes from data types.
Functions |g1|, |g2| match on a \emph{newtype} |N|, while functions
|h1|, |h2| match on a \emph{data type} |D|:

\begin{minipage}{\textwidth}
\begin{minipage}[b]{0.5\textwidth}
\centering
\begin{code}
newtype N a = MkN a
g1 :: N Void -> Bool -> Int
g1 _        True   = 1
g1 (MkN _)  True   = 2  -- Redundant
g1 !_       True   = 3  -- Inaccessible
\end{code}
\end{minipage}%
\begin{minipage}[b]{0.5\textwidth}
\centering
\begin{code}
g2 :: N () -> Bool -> Int
g2 !!(MkN _)   True  = 1
g2   (MkN !_)  True  = 2  -- Redundant
g2         _   _     = 3
\end{code}
\end{minipage}
\begin{minipage}[b]{0.5\textwidth}
\centering
\begin{code}
data D a = MkD a
h1 :: D Void -> Bool -> Int
h1 _        True   = 1
h1 (MkD _)  True   = 2  -- Inaccessible
h1 !_       True   = 3  -- Redundant
\end{code}
\end{minipage}%
\begin{minipage}[b]{0.5\textwidth}
\centering
\begin{code}
h2 :: D () -> Bool -> Int
h2 !!(MkD _)   True  = 1
h2   (MkD !_)  True  = 2  -- Inaccessible
h2         _   _     = 3
\end{code}
\end{minipage}
\end{minipage}
\noindent
If the first equation of |h1| fails to match (because the second argument is |False|),
the second equation may diverge when matching against |(MkD _)|
or may fail (because of the |False|), so the equation is inaccessible.
The third equation is redundant.
But for a newtype, the second equation of |g1| will not evaluate the argument
when matching against |(MkN _)| and hence is redundant.
The third equation will evaluate the first argument, which is surely bottom,
so matching will diverge and the equation is inaccessible.
A perhaps surprising consequence is that the definition of |g1| is exhaustive,
because after |N Void| was deprived of its sole inhabitant |bot = MkN bot| by
the third GRHS, there is nothing left to match on (similarly for |h1|).
Analogous subtle reasoning justifies the difference in warnings for |g2| and
|h2|.

\Cref{fig:newtypes} outlines a solution that handles all these cases correctly:

\begin{itemize}

  \item A newtype pattern match $N \; \mathit{pat}_1\,...\,\mathit{pat}_n$ is lazy: it does not
  force evaluation. So, compared to data constructor matches, the desugaring
  function $\ds$ omits the $\grdbang{x}$. Additionally, Equation (4) of
  $\addphi$, responsible for reasoning about |let| bindings, has a special case
  for newtypes that omits the $x \ntermeq \bot$ constraint.

  \item Similar in spirit to $\rep{\Delta}{x}$, which chases variable equality
  constraints $x \termeq y$, we now also occasionally need to look through
  positive newtype constructor constraints $x \termeq \ntconapp{N}{a}{y}$ with
  $\repnt{\Delta}{x}$.

  \item The most important usage of $\repnt{\Delta}{x}$ is in the changed
  Equations (12) and (13) of $\adddelta$, where we now check
  $\bot$ constraints modulo $\repnt{\Delta}{x}$.

  \item Equation (10) (previously handling $x \termeq \deltaconapp{K}{a}{y}$)
  and Equation (11) (previously handling $x \ntermeq K$) have been split to
  account for newtype constructors.

  \item The first case of the new Equation $(10b)$ handles any existing
  positive newtype constructor constraints in $\Delta$, as with Equation (10).
  Take note that negative newtype constructor constraints may never occur in
  $\Delta$ because of Equation $(11b)$, as explained in the next paragraph. The
  remaining two cases are reminiscent of Equation (14) ($x \termeq y$).
  Provided there are neither positive nor negative newtype constructor
  constraints involving $x$, any remaining $\bot$ constraints are moved from
  $\rep{\Delta}{x}$ to the new representative $\repnt{\Delta'}{x}$, which will
  be $\repnt{\Delta'}{y}$ in the returned $\Delta'$.

  \item The new Equation $(11b)$ handles negative newtype constructor
  constraints by immediately rejecting. The reason it does not consider $\bot$
  as an inhabitant is that for $\bot$ to be an inhabitant, it must be an
  inhabitant of the newtype's field. For that, we must have $x \termeq |K y|$
  for some |y|, which contradicts with the very constraint we want to add!

\end{itemize}
\noindent
To see how these changes facilitate correct warnings for newtype matches, first
consider the changed invariant \inv{3} which ensures $\repnt{\Delta}{x}$ is a
well-defined function like $\rep{\Delta}{x}$:

\begin{enumerate}

  \item[\inv{3}] \emph{Triangular form}: Constraints of the form $x \termeq y$
  and $x \termeq \ntconapp{N}{a}{y}$ imply absence of any other constraint
  mentioning |x| in its left-hand side.

\end{enumerate}
\noindent
We want $\Delta$ to uphold the semantic equation $\bot \equiv N \bot$. In
particular, whenever we have $x \termeq \ntconapp{N}{a}{y}$, we want $x \termeq
\bot$ iff $y \termeq \bot$ (similarly for $x \ntermeq \bot$). Equations (10b),
(12) and (13) facilitate just that, modulo $\repnt{\Delta}{x}$.
Finally, a new invariant \inv{5} relates positive newtype constructor equalities to
$\bot$ constraints:

\begin{enumerate}

  \item[\inv{5}] \emph{Newtype erasure}: Whenever $x \termeq \ntconapp{N}{a}{y}
  \in \Delta$, we have $x \termeq \bot \in \Delta$ if and only if $y \termeq
  \bot \in \Delta$, and $x \ntermeq \bot \in \Delta$ if and only if $y \ntermeq
  \bot \in \Delta$.

\end{enumerate}
\noindent
An alternative design might take inspiration in the coercion semantics
of GHC Core, a typed intermediate language of GHC based on System F, and
compose coercions attached to $\termeq$. However, that would entail deep
changes to syntax as well as to the definition of $\expand$ to recover the
newtype constructor patterns visible in source syntax.

\subsection{Strictness, Divergence and Other Side-Effects}

Instead of extending the source language, let us discuss ripping out a language
feature for a change! So far, we have focused on Haskell as the source
language, which is lazy by default. Although the difference in evaluation
strategy of the source language becomes irrelevant after desugaring, it raises the
question of how much our approach could be simplified if we targeted a source
language that was strict by default, such as OCaml, Lean, Idris, Rust, Python or
C\#.

On first thought, it is tempting to simply drop all parts related to laziness
from the formalism, such as $\grdbang{x}$ from $\Grd$ and
$\antbang{}{\hspace{-0.6em}}$ from $\Ant$. Actually, $\Ant$ and $\red$ could
vanish altogether and $\ann$ could just collect the redundant GRHS directly!
Since there would not be any bang guards, there is no reason to have $x
\termeq \bot$ and $x \ntermeq \bot$ constraints either. Most importantly, the
\inhabitedbot judgment form has to go, because $\bot$ does not inhabit any types
anymore.

And compiler writers for total languages such as Lean, Idris or Agda would live
happily after: Talking about $x \ntermeq \bot$ constraints made no sense there
to begin with. Not so with OCaml or Rust, which are strict, non-total languages
and allow arbitrary side-effects in expressions. Here's an example in OCaml:

\begin{code}
let rec f p x =
  match x with
  | []                         -> []
  | hd::_ when p hd && x = []  -> [hd]
  | _::tl                      -> f p tl;;
\end{code}

\noindent
Is the second clause redundant? It depends on whether |p| performs a
side-effect, such as throwing an exception, diverging, or even releasing a
mutex. We may not say without knowing the definition of |p|, so the second
clause has an inaccessible RHS but is not redundant.
It's a similar situation as in a lazy language, although the fact that
side-effects only matter in the guard of a match clause (where we can put
arbitrary expressions) makes the issue much less prominent.

We could come up with a desugaring function for OCaml that desugars the pattern
match above to the following guard tree:

\begin{forest}
  grdtree,
  [
    [{$\grdcon{|[]|}{x}$} [1]]
    [{$\grdcon{|hd::tl|}{x}, \grdlet{t}{|p hd|}, \grdbang{t}, \grdcon{true}{t}, \grdcon{|[]|}{x}$} [2]]
    [{$\grdcon{|hd::tl|}{x}$} [3]]]
\end{forest}

Compared to Haskell, note the lack of a bang guard on the match variable |x|.
Instead, there's now a bang guard on |t|, the new temporary that stands for
|p hd|. The bang guard will keep alive the second clause of the guard tree and
our algorithm would not classify the second clause as redundant, although it
will be flagged as inaccessible. Since the RHS of a |let| guard, such as
|p hd|, might have arbitrary side-effects, equational reasoning is lost and we
may no longer identify $|p hs| \termeq |t|$ as in \Cref{ssec:extviewpat}.

Zooming out a bit more, desugaring of Haskell pattern matches using bang guards
$\grdbang{|x|}$ can be understood as forcing \emph{one
specific effect}, namely divergence. In this work, we have given this side-effect
a first-class treatment in our formalism in order to get accurate coverage
warnings in a lazy language.

\subsection{Or-patterns}
\label{ssec:orpats}

\begin{figure}
\[
\begin{array}{c}
  \mathit{pat}   \Coloneqq ... \mid \highlight{\mathit{pat}_1;\, \mathit{pat}_2}
\end{array}
\]
\[
\arraycolsep=2pt
\begin{array}{rcrcll}
  t & \in & \Gdt &\Coloneqq& ... \mid \gdtguard{\highlight{d}}{t}         \\
  d & \in & \GrdDag &\Coloneqq& \dagone{g} \mid \highlight{\dagpar{d_1}{d_2}} \mid \dagseq{d_1}{d_2}
\end{array}
\]
\[
  \ds(x, (\mathit{pat}_1;\, \mathit{pat}_2)) = \dagpar{\ds(x, \mathit{pat}_1)}{\ds(x, \mathit{pat}_2)}
\]
\[ \ruleform{ \cov(\Theta, d) = \Theta } \]
\[
\begin{array}{lcl}
\cov(\Theta, \dagpar{d_1}{d_2}) &=& \cov(\Theta, d_1) \uniontheta \cov(\unc(\Theta, d_1), d_2) \\
\cov(\Theta, \dagseq{d_1}{d_2}) &=& \cov(\cov(\Theta, d_1), d_2) \\
\cov(\Theta, \dagone{\grdbang{x}}) &=& \Theta \andtheta (x \ntermeq \bot) \\
\cov(\Theta, \dagone{\grdlet{x}{e}}) &=& \Theta \andtheta (\ctlet{x}{e}) \\
\cov(\Theta, \dagone{\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}}) &=& \Theta \andtheta (\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}) \\
\end{array}
\]

\[ \ruleform{ \unc(\Theta, t) = \Theta, \qquad \unc(\Theta, d) = \Theta } \]
\[
\begin{array}{lcl}
\unc(\reft{\Gamma}{\Phi}, \gdtrhs{n}) &=& \reft{\Gamma}{\false} \\
\unc(\Theta, \gdtpar{t_1}{t_2}) &=& \unc(\unc(\Theta, t_1), t_2) \\
\unc(\Theta, \gdtguard{d}{t}) &=& \unc(\Theta, d) \uniontheta \unc(\cov(\Theta, d), t) \\
\\[-0.5em]
\unc(\Theta, \dagpar{d_1}{d_2}) &=& \unc(\unc(\Theta, d_1), d_2) \\
\unc(\Theta, \dagseq{d_1}{d_2}) &=& \unc(\Theta, d_1) \uniontheta \unc(\cov(\Theta, d_1), d_2) \\
\unc(\reft{\Gamma}{\Phi}, \grdbang{x}) &=& \reft{\Gamma}{\false} \\
\unc(\reft{\Gamma}{\Phi}, \grdlet{x}{e}) &=& \reft{\Gamma}{\false} \\
\unc(\Theta, \grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}) &=& \Theta \andtheta (x \ntermeq K) \\
\end{array}
\]

\[ \ruleform{ \ann(\Theta, t) = u, \qquad \ann(\Theta, d) = \Theta } \]
\[
\begin{array}{lcl}
\ann(\Theta,\gdtrhs{n}) &=& \antrhs{\Theta}{n} \\
\ann(\Theta, \gdtpar{t_1}{t_2}) &=& \antpar{\ann(\Theta, t_1)}{\ann(\unc(\Theta, t_1), t_2)} \\
\ann(\Theta, \gdtguard{d}{t}) &=& \antbang{\ann(\Theta, d)}{\ann(\cov(\Theta, d), t)} \\
\\[-0.5em]
\ann(\Theta, \dagpar{d_1}{d_2}) &=& \ann(\Theta, d_1) \uniontheta \ann(\unc(\Theta, d_1), d_2) \\
\ann(\Theta, \dagseq{d_1}{d_2}) &=& \ann(\Theta, d_1) \uniontheta \ann(\cov(\Theta, d_1), d_2) \\
\ann(\Theta, \grdbang{x}) &=& \Theta \andtheta (x \termeq \bot) \\
\ann(\reft{\Gamma}{\Phi}, \grdlet{x}{e}) &=& \reft{\Gamma}{\false} \\
\ann(\reft{\Gamma}{\Phi}, \grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}) &=& \reft{\Gamma}{\false} \\
\end{array}
\]

\caption{Extending coverage checking to handle Or-patterns}
\label{fig:orpats}
\end{figure}

Since this work appeared at ICFP in 2020, GHC 9.12 accumulated a new extension
to the pattern language: \emph{Or-patterns}%
\footnote{\url{https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0522-or-patterns.rst}}.
Or-patterns are an established language feature in many other languages such as
OCaml and Python, and can be used as follows:

\begin{code}
data LogLevel = Debug | Info | Error
notifyAdmin :: LogLevel -> Bool
notifyAdmin Error          = True
notifyAdmin (Debug; Info)  = False
\end{code}

\noindent
Here, the second clause matches when either |Debug| or |Info| matches the
parameter.
When the programmer later adds a new data constructor |Warning| to |LogLevel|,
\lyg should report the match in |notifyAdmin| as inexhaustive.
This coverage warning prompts the programmer to make a conscious decision about
which value should be returned for |notifyAdmin Warning|.
That is far better than the alternative of using a wildcard match for the last
clause: doing so would silently define |notifyAdmin Warning = False|.

Or-patterns were an interesting real-world benchmark to see how well \lyg
scales to new language features.
Previously in \Cref{fig:desugar}, if one part of a pattern failed to match, the
whole pattern would fail.
As a result, the desugaring function $\ds$ could map a pattern into a
(conjunctive) list of guards ($\overline{\Grd}$), which was then exploded into
a nesting of $\gdtguard{g}{t}$ forms, suitable for a single recursive definition
of $\unc$ and $\ann$.
However, with Or-patterns, we need a way to encode (disjunctive) first-match
semantics in the result of $\ds(x, \mathit{pat})$.
Such first-match semantics is currently exclusive to the
$\gdtpar{\makebox(3pt,2pt){$t_1$}}{\makebox(3pt,2pt){$t_2$}}$ guard tree form.
So one way to desugar Or-patterns would be to desugar
patterns into full guard trees instead of lists of guards.
That would be akin to \emph{exploding} each Or-pattern into two clauses.
We would get the equality
\[
\ds(f \; (\mathit{pat}_a;\, \mathit{pat}_b) \, \mathit{pat}_c \; \mathtt{=} \; \mathit{rhs}) \; =
  \raisebox{10px}{\begin{forest}
    baseline,
    grdtree,
    [ [{$\ds(x_1, \mathit{pat}_a),\; \ds(x_2, \mathit{pat}_c)$} [{$k_{\mathit{rhs}}$}] ]
      [{$\ds(x_1, \mathit{pat}_b),\; \ds(x_2, \mathit{pat}_c)$} [{$k_{\mathit{rhs}}$}] ] ]
  \end{forest}}
\]
\noindent
thus duplicating the desugaring of $\mathit{pat_c}$.
It is easy to see how a sequence of Or-patterns may lead to an exponential number of
duplications of $\mathit{pat}_c$, leading to unacceptable checking performance.
Hence we propose a different solution: \emph{Guard DAGs} (directed-acyclic
graphs).

\Cref{fig:orpats} defines the stucture of guard DAGs ($\GrdDag$) inductively.
Now consider the function

\begin{code}
f :: Ordering -> Ordering -> Int
f (LT; EQ)  (EQ; GT)  = 1
f _         _         = 2
\end{code}

\noindent
The desugaring to guard trees according to \Cref{fig:orpats} is

\vskip\abovedisplayskip
\begin{forest}
  grdtree,
  [
    [{$\dagseq{\dagpar{\dagseq{\dagone{\grdbang{x_1}}}{\dagone{\grdcon{|LT|}{x_1}}}}
                      {\dagseq{\dagone{\grdbang{x_1}}}{\dagone{\grdcon{|EQ|}{x_1}}}}}
              {\dagpar{\dagseq{\dagone{\grdbang{x_2}}}{\dagone{\grdcon{|EQ|}{x_2}}}}
                      {\dagseq{\dagone{\grdbang{x_2}}}{\dagone{\grdcon{|GT|}{x_2}}}}}$} [1]]
    [2]]
\end{forest}
\vskip\belowdisplayskip

\noindent
We define matching as follows:
\begin{itemize}
  \item Matching $\dagone{g}$ means matching a single guard $g \in \Grd$, which was done by $\gdtguard{g}{t}$ previously.
    However, the new $\gdtguard{d}{t}$ form stores a guard DAG $d$ instead of a single guard $g$.
  \item Matching a parallel composition $\dagpar{d_1}{d_2}$ means matching against $d_1$;
    if that succeeds, the overall match succeeds; if not, match against $d_2$.
  \item Matching a sequential composition $\dagseq{d_1}{d_2}$ means matching against $d_1$;
    if that succeeds, match against $d_2$.
    If either match fails, the whole match fails.
\end{itemize}
Matching parallel composition $\dagpar{d_1}{d_2}$ is much like matching
$\gdtpar{\makebox(3pt,2pt){$t_1$}}{\makebox(3pt,2pt){$t_2$}}$, and matching sequential composition $\dagseq{d_1}{d_2}$ is
much like matching $\gdtguard{d}{t}$.

\noindent
A clearer, non-flat visualisation of the guard DAG of the first clause could be

\vskip\abovedisplayskip
\begin{tikzpicture}[scale=1.5]
    \tikzstyle{bullet}=[circle, draw, fill=black, minimum size=3pt, inner sep=0pt]
    \tikzstyle{vertex}=[rectangle,draw, minimum size=4pt, inner sep=2pt]
    \tikzstyle{edge}=[draw, line width=0.5pt]

    % Nodes
    \node (before) at (-0.3,0) {};
    \node[bullet] (src) at (0,0) {};

    \node[bullet] (tl1) at (0.3,0.2) {};
    \node[vertex] (A) at (0.6,0.2) {$\grdbang{x_1}$};
    \node[bullet] (tl2) at (0.9,0.2) {};
    \node[vertex] (B) at (1.5,0.2) {$\grdcon{|LT|}{x_1}$};
    \node[bullet] (tl3) at (2.1,0.2) {};

    \node[bullet] (bl1) at (0.3,-0.2) {};
    \node[vertex] (C) at (0.6,-0.2) {$\grdbang{x_1}$};
    \node[bullet] (bl2) at (0.9,-0.2) {};
    \node[vertex] (D) at (1.5,-0.2) {$\grdcon{|EQ|}{x_1}$};
    \node[bullet] (bl3) at (2.1,-0.2) {};

    \node[bullet] (mid) at (2.4,0) {};

    \node[bullet] (tr1) at (2.7,0.2) {};
    \node[vertex] (E) at (3.0,0.2) {$\grdbang{x_2}$};
    \node[bullet] (tr2) at (3.3,0.2) {};
    \node[vertex] (F) at (3.9,0.2) {$\grdcon{|EQ|}{x_2}$};
    \node[bullet] (tr3) at (4.5,0.2) {};

    \node[bullet] (br1) at (2.7,-0.2) {};
    \node[vertex] (G) at (3.0,-0.2) {$\grdbang{x_2}$};
    \node[bullet] (br2) at (3.3,-0.2) {};
    \node[vertex] (H) at (3.9,-0.2) {$\grdcon{|GT|}{x_2}$};
    \node[bullet] (br3) at (4.5,-0.2) {};

    \node[bullet] (sink) at (4.8,0) {};
    \node (after) at (5.2,0) {$1$};

    % Edges
    \draw[edge,-{Bar[]}] (before) -- (src);
    \draw[edge] (src) -- (tl1);
    \draw[edge] (src) -- (bl1);

    \draw[edge] (tl1) -- (A);
    \draw[edge] (A) -- (tl2);
    \draw[edge] (tl2) -- (B);
    \draw[edge] (B) -- (tl3);

    \draw[edge] (bl1) -- (C);
    \draw[edge] (C) -- (bl2);
    \draw[edge] (bl2) -- (D);
    \draw[edge] (D) -- (bl3);

    \draw[edge] (tl3) -- (mid);
    \draw[edge] (bl3) -- (mid);
    \draw[edge] (mid) -- (tr1);
    \draw[edge] (mid) -- (br1);

    \draw[edge] (tr1) -- (E);
    \draw[edge] (E) -- (tr2);
    \draw[edge] (tr2) -- (F);
    \draw[edge] (F) -- (tr3);

    \draw[edge] (br1) -- (G);
    \draw[edge] (G) -- (br2);
    \draw[edge] (br2) -- (H);
    \draw[edge] (H) -- (br3);

    \draw[edge] (tr3) -- (sink);
    \draw[edge] (br3) -- (sink);
    \draw[edge,->] (sink) -- (after);
\end{tikzpicture}
\vskip\belowdisplayskip

\noindent
This visualisation acknowledges that $\GrdDag$ really models labelled
\emph{series-parallel graphs}~\citep{series-parallel}, a very specific
kind of DAG with a straightforward encoding as an algebraic data type:
every guard $g$ induces a series-parallel graph with a single edge from source to sink;
conjunction $\dagseq{d_1}{d_2}$ corresponds to series composition of graphs for $d_1$ and $d_2$;
and disjunction $\dagpar{d_1}{d_2}$ corresponds to parallel composition of graphs for $d_1$ and $d_2$.

Although the redefinition of coverage checking functions in \Cref{fig:orpats} is
much more expansive in size than the original definition in \Cref{fig:check}, we
will see that the encoded logic is derivative.

There is a new function $\cov$ that computes the \emph{covered} set of a guard dag $d$.
This function was previously inlined into the recursive call sites of $\unc$ and
$\ann$; it computes the set of $\Theta$ reaching $t$ in $\gdtguard{g}{t}$.
It is no longer possible to inline it because the $\gdtguard{d}{t}$ form now
carries a guard DAG $d$ with nested structure; hence we need a separate function
and a small refactor.

As expected, computing the uncovered set of parallel composition $\dagpar{d_1}{d_2}$
is much the same as for the
$\gdtpar{\makebox(3pt,2pt){$t_1$}}{\makebox(3pt,2pt){$t_2$}}$ form, and similarly
for sequential composition $\dagseq{d_1}{d_2}$ and the $\gdtguard{d}{t}$ form.
Similarly, the uncovered set for the $\gdtrhs{n}$ form is the same as that of
the irrefutable guards $\grdbang{x}$ and $\grdlet{x}{e}$.
For the purposes of $\unc$, we could have written a small function from $\Gdt$
to $\GrdDag$ to share this duplicate code.
Our actual implementation in GHC (\Cref{sec:impl}) simply re-uses polymorphic
combinators.

The changes to $\ann$ are similar in nature.
The use of $\uniontheta$ in $\ann(\Theta, \dagseq{g_1}{g_2})$ may be unexpected,
since usually sequential composition leads to conjunction $\andtheta$, not
disjunction $\uniontheta$.
Nevertheless, $\uniontheta$ is the correct choice, because it
follows directly from the previous definition of
$\ann(\Theta, \gdtguard{g_1,g_2}{t})$ and how the resulting
$\vcenter{\hbox{\begin{forest}
    anttree,
    for tree={delay={edge={-}}},
    [ [{$\Theta_1$\,\lightning} [{$\Theta_2$\,\lightning} [{$u$}]]]]
  \end{forest}}}$
annotations are used in $\red$ (\Cref{fig:gen}): $u$ can be redundant only if
there is no inhabitant in $\Theta_1 \uniontheta \Theta_2$; otherwise it is
inaccessible.

It is reassuring to know that extending coverage checking in \Cref{fig:check}
with Or-patterns is derivative and compatible with all the other proposed
extensions, although it takes a slight refactoring.
On the other hand, years of maintaining \lyg have shown that the entire
complexity rests in the inhabitation test (\Cref{fig:inh}).
We did not need to touch that; and neither did we need to adjust \Cref{fig:gen}
or later: this is compelling evidence that the core of our approach is quite
extensible and robust.

\section{Implementation}
\label{sec:impl}

Our implementation of \lyg has been part of GHC since the 8.10 release in 2020,
including all extensions in \Cref{sec:extensions} (except for strict-by-default
source syntax). Our implementation accumulates quite a few tricks
that go beyond the pure formalism. This section is dedicated to describing
these.

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
\[ \ruleform{ \uncann(\overline{\nabla}, t) = (\overline{\nabla}, u) } \]
\[
\begin{array}{lcl}
\uncann(\overline{\nabla}, \gdtrhs{n}) &=& (\epsilon, \antrhs{\overline{\nabla}}{n}) \\
\uncann(\overline{\nabla}, \gdtpar{t_1}{t_2}) &=& (\overline{\nabla}_2, \antpar{u_1}{u_2}) \hspace{0.5em} \text{where} \begin{array}{l@@{\,}c@@{\,}l}
    (\overline{\nabla}_1, u_1) &=& \uncann(\overline{\nabla}, t_1) \\
    (\overline{\nabla}_2, u_2) &=& \uncann(\overline{\nabla}_1, t_2)
  \end{array} \\
\uncann(\overline{\nabla}, \gdtguard{\grdbang{x}}{t}) &=& \antbang{\overline{\nabla} \addphiv (x \termeq \bot)}{u} \\
  && \quad \text{where } (\overline{\nabla}', u) = \uncann(\overline{\nabla} \addphiv (x \ntermeq \bot), t) \\
\uncann(\overline{\nabla}, \gdtguard{\grdlet{x}{e}}{t}) &=& \uncann(\overline{\nabla} \addphiv (\ctlet{x}{e}), t) \\
\uncann(\overline{\nabla}, \gdtguard{\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}}{t}) &=& ((\overline{\nabla} \addphiv (x \ntermeq K)) \, \overline{\nabla}', u) \\
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

But there's more: Looking at the last clause of $\unc$ in \Cref{fig:check},
we can see that we syntactically duplicate $\Theta$ every time we have a
pattern guard. In the worst case, that can amount to exponential growth of the
refinement predicate and for the time to prove it empty!

% Clearly, the space usage won't actually grow exponentially due to sharing in
% the implementation, but the problems for runtime performance remain.
What we really want is to summarise a $\Theta$ into a more compact canonical
form before doing these kinds of \emph{splits}. But that's exactly what
$\nabla$ is! Therefore, in our implementation we do not pass around
and annotate refinement types, but the result of calling $\normalise$ on them
directly.

You can see the resulting definition in \Cref{fig:fastcheck}. The readability
is clouded by unwrapping of pairs. $\uncann$ requires that each $\nabla$
individually is non-empty, \ie not $\false$. This invariant is maintained by
adding $\varphi$ constraints through $\addphiv$, which filters out any $\nabla$
that would become empty.

\subsection{Throttling for Graceful Degradation} \label{ssec:throttling}

Even with the tweaks from \Cref{ssec:interleaving}, checking certain pattern
matches remains NP-hard \citep{adaptivepm}. Naturally, there will be cases
where we have to conservatively approximate in order not to slow down
compilation too much. Consider the following example and its corresponding
guard tree:
\\
\begin{minipage}[t]{0.32\textwidth}
\begin{code}
data T = A | B; f1, f2 :: Int -> T
g _
  | A <- f1 1,  A <- f2 1  = ()
  | A <- f1 2,  A <- f2 2  = ()
  ...
  | A <- f1 N,  A <- f2 N  = ()
\end{code}
\end{minipage}%
\begin{minipage}[t][][b]{0.68\textwidth}
\vspace{2em}
\begin{forest}
  grdtree,
  [
    [{$\grdlet{a_1}{|f1 1|}, \grdbang{a_1}, \grdcon{|A|}{a_1}, \grdlet{b_1}{|f2 1|}, \grdbang{b_1}, \grdcon{|A|}{b_1}$} [1]]
    [{$\grdlet{a_2}{|f1 2|}, \grdbang{a_2}, \grdcon{|A|}{a_2}, \grdlet{b_2}{|f2 2|}, \grdbang{b_2}, \grdcon{|A|}{b_2}$} [2]]
    [... [...]]
    [{$\grdlet{a_{N}}{|f1 N|}, \grdbang{a_{N}}, \grdcon{|A|}{a_{N}}, \grdlet{b_{N}}{|f2 N|}, \grdbang{b_{N}}, \grdcon{|A|}{b_{N}}$} [N]]]
\end{forest}
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
continue with the original reaching $\nabla$s, a conservative estimate, instead.
Intuitively, throttling corresponds to \emph{forgetting} what we matched on in
that particular subtree. Throttling is refreshingly easy to implement! Only the
last clause of $\uncann$, where splitting is performed, needs to change:
\[
\begin{array}{r@@{\,}c@@{\,}lcl}
\uncann(\overline{\nabla}, \gdtguard{\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}}{t}) &=& (\throttle{\overline{\nabla}}{(\overline{\nabla} \addphiv (x \ntermeq K)) \, \overline{\nabla}'}, u) \\
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

with $K$ being an arbitrary constant. GHC uses 30 as the limit in the
implementation (dynamically configurable via a command-line flag) without
noticing any false positives in terms of exhaustiveness warnings outside of the
test suite.

It is worth noting that Or-patterns (\Cref{ssec:orpats}) introduce a function
$\cov$ to compute the covered set of a guard DAG $d$, and its case for
$\dagpar{d_1}{d_2}$ splits the incoming $\Theta$ as well; hence we throttle
there as well to ensure graceful degradation.

\subsection{Maintaining Residual \extension{COMPLETE} Sets}
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
asymptotically it should not matter much, since we are doing this only once at
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

\subsection{Reporting Uncovered Patterns}
\label{ssec:report}

The expansion function $\expand$ in \Cref{fig:gen} exists purely for presenting
uncovered patterns to the user. It does not account for negative information,
however, which can lead to surprising warnings. Consider a definition like |b
True = ()|. The computed uncovered set of |b| is the normalised refinement type
$\nabla_b = \nreft{x:|Bool|}{x \ntermeq \bot, x \ntermeq |True|}$, which crucially
contains no positive information on |x|! As a result, $\expand(\nabla_b) = \_$
and only the very unhelpful wildcard pattern |_| will be reported as uncovered.

Our implementation does better and shows that this is just a presentational
matter. It splits $\nabla_b$ on all possible constructors of |Bool|, immediately
rejecting the refinement $\nabla_b \adddelta x \termeq |True|$ due to $x \ntermeq
|True| \in \nabla_b$. What remains is the refinement $\nabla_b \adddelta x
\termeq |False| = \nreft{x:|Bool|}{x \ntermeq \bot, x \ntermeq |True|, x \termeq
|False|}$, which has the desired positive information for which $\expand$ will
happily report |False| as the uncovered pattern.

Additionally, our implementation formats negative information on opaque data
types such as |Int| and |Char|, since idiomatic use would match on literals
rather than on GHC-specific data constructors. For example, coverage checking
|f 0 = ()| will report something like this:

\begin{Verbatim}
    Missing equations for function 'f':
      f x = ... where 'x' is not one of {0}
\end{Verbatim}

\subsection{Syntax-specific Guard Tree Types}

Since we submitted our work to ICFP in 2020, we continued to improve and
refactor the implementation of \lyg in GHC.
Many of the changes were incremental improvements and bug fixes that are
not easy to present without a lot of context, but one particularly important
innovation%
\footnote{\url{https://gitlab.haskell.org/ghc/ghc/-/commit/1207576ac0cfdd3fe1ea00b5505f7c874613451e}}
was the introduction of syntax-specific instances of guard trees, such as
\begin{code}
type SrcInfo = String -- {appromixately; identifies the $k$ in $\mathit{rhs}_k$}
data PmMatch p  = PmMatch  { pm_pats :: p, pm_grhss :: [PmGRHS p] }
data PmGRHS p   = PmGRHS   { pg_grds :: p, pg_rhs :: SrcInfo }
\end{code}
These types are in structural correspondence to the $\mathit{match}$ and
$\mathit{grhs}$ constructs in \Cref{fig:srcsyn} from whence they desugar.
Prior to coverage checking, type parameter |p| is instantiated to lists
of guards $\overline{Grd}$ (resp.\ $\GrdDag$ after Or-patterns were
introduced, \Cref{ssec:orpats}), and coverage checking elaborates this list
into |RedSets|, carrying $\Theta$s encoding covered and diverging input
values.

Of course, the meaning of |PmMatch| and |PmGRHS| is in terms of the
desugaring into unrestricted guard trees $\Gdt$, as before.
However, with the new encoding it became much easier to extract covered sets
for long-distance information (\Cref{ssec:ldi}), because the |pm_grhss| field
has the same number of elements as there are $\overline{\mathit{grhs}}$ in a
$\mathit{match}$ and simple |Data.List.zip| suffices to bring covered sets and
$\mathit{grhs}$ together.

\section{Evaluation}
\label{sec:eval}

To put the new coverage checker to the test, we performed a survey of
real-world Haskell code using the \texttt{head.hackage} repository
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
term equalities.
\\
One library, \texttt{geniplate-mirror}, has a case that was
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

In order to support this use case in \texttt{HsYAML}, a primitive definition
|considerAccessible = False| was added in GHC 9.2, to be used instead of |False|
above and signalling to GHC that the first clause should not get marked as
redundant.
The unreachable code in \texttt{Cabal} and \texttt{network} is of a similar
caliber and could benefit from |considerAccessible| as well.

\subsection{Performance Tests}

\begin{table}

\caption{The relative compile-time performance of GHC 8.8.3 (which implements \gmtm) and HEAD
         (which implements \lyg) on test cases designed to stress-test coverage checking.}
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

\label{fig:perf}
\end{table}

To compare the efficiency of \gmtm and \lyg quantitatively, we
collected a series of test cases from GHC's test suite that are designed to test
the compile-time performance of coverage checking. \Cref{fig:perf} lists each of these 11 test
cases. Test cases with a \texttt{T} prefix are taken from user-submitted bug reports
about the poor performance of \gmtm. Test cases with a
\texttt{PmSeries} prefix are adapted from \citet{maranget:warnings},
which presents several test cases that caused GHC to exhibit exponential running times
during coverage checking.

We compiled each test case with GHC 8.8.3, which uses \gmtm as its checking
algorithm, and GHC HEAD (a pre-release of GHC 8.10), which uses \lyg.
We measured (1) the time spent in the desugarer, the phase of compilation in
which coverage checking occurs, and (2) how many megabytes were allocated during
desugaring. \Cref{fig:perf} shows these figures as well as the percent change
going from 8.8.3 to HEAD. Most cases exhibit a noticeable improvement under
\lyg, with the exception of \texttt{T11276}. Investigating \texttt{T11276}
suggests that the performance of GHC's equality constraint solver has become
more expensive in HEAD ~\citep{gitlab:17891}, and these extra costs outweigh the
performance benefits of using \lyg.
This performance bug was fixed in GHC 9.0%
\footnote{\url{https://gitlab.haskell.org/ghc/ghc/-/commit/fd7ea0fee92a60f9658254cc4fe3abdb4ff299b1}}.

Note that for typical code (rather than for regression tests), time spent doing
coverage checking is dwarfed by the time the rest of the desugarer takes. A
very desirable property for a static analysis that is irrelevant to the
compilation process!

\subsection{GHC Issues} \label{sec:ghc-issues}

Implementing \lyg in GHC has fixed over 30 bug reports related
to coverage checking. These include:

\begin{itemize}
  \item
    Better compile-time performance
    \citep{gitlab:11195,gitlab:11528,gitlab:17096,gitlab:17264}

  \item
    More accurate warnings for empty |case| expressions
    \citep{gitlab:10746,gitlab:13717,gitlab:14813,gitlab:15450,gitlab:17376}

  \item
    More accurate warnings due to \lyg's desugaring
    \citep{gitlab:11984,gitlab:12949,gitlab:14098,gitlab:15385,gitlab:17646}

  \item
    More accurate warnings due to improved term-level reasoning
    \citep{gitlab:12957,gitlab:14546,gitlab:14667,gitlab:15713,gitlab:15753,gitlab:15884,gitlab:16129,gitlab:16289,gitlab:17251}

  \item
    More accurate warnings due to tracking long-distance information
    \citep{gitlab:17465,gitlab:17703,gitlab:17783}

  \item
    Improved treatment of \extension{COMPLETE} sets
    \citep{gitlab:13021,gitlab:13363,gitlab:13965,gitlab:14059,gitlab:14253,gitlab:14851,gitlab:17112,gitlab:17149,gitlab:17386}

  \item
    Better treatment of strictness, bang patterns, and newtypes
    \citep{gitlab:15305,gitlab:15584,gitlab:17234,gitlab:17248}

\end{itemize}

\section{Soundness} \label{sec:soundness}

\begin{figure}
\[ \textbf{Semantics of guard trees} \]
\[
\arraycolsep=2pt
\begin{array}{rclcl}
   d & \in & \Domain & = & \bot \mid K \; \overline{d} \mid ... \\
   \rho & \in & \Env & \Coloneqq & [\overline{x \mapsto d}] \\
   r & \in & \Result [ \square ] & \Coloneqq & \yes{\square} \mid \no \mid \diverge \\
\end{array}
\]

\[ \ruleform{\exprsem{e}_\rho \in \Domain, \qquad \grdsem{g}_\rho \in \Result [ \rho ], \qquad \gdtsem{t}_\rho \in \Result [ k ]} \]
\[
\begin{array}{lcl}
\exprsem{K \; \overline{e}}_\rho & = & K \; \overline{\exprsem{e}_\rho} \\
\exprsem{e}_\rho & = & ... \\
\\[-0.5em]
\grdsem{\grdlet{x}{e}}_\rho & = & \rho[x \mapsto \exprsem{e}_\rho] \\
\grdsem{\grdcon{K \; \overline{y}}{x}}_\rho & = & \begin{cases}
  \yes{\rho[\overline{y \mapsto d}]} & \text{if $\rho(x) = K \; \overline{d}$} \\
  \no                        & \text{otherwise} \\
\end{cases} \\
\grdsem{\grdbang{x}}_\rho & = & \begin{cases}
  \diverge & \text{if $\rho(x) = \bot$} \\
  \yes{\rho} & \text{otherwise} \\
\end{cases} \\
\\[-0.5em]
\gdtsem{\gdtrhs{k}}_\rho & = & \yes{k} \\
\gdtsem{\gdtpar{t_1}{t_2}}_\rho & = & \begin{cases}
  \gdtsem{t_2}_\rho & \text{if $\gdtsem{t_1}_\rho = \no$} \\
  \gdtsem{t_1}_\rho & \text{otherwise} \\
\end{cases} \\
\gdtsem{\gdtguard{g}{t}}_\rho & = & \begin{cases}
  \gdtsem{t}_{\rho'} & \text{if $\grdsem{g}_\rho = \yes{\rho'}$} \\
  \grdsem{g}_\rho & \text{otherwise} \\
\end{cases} \\
\end{array}
\]

\[ \textbf{Semantics of refinement types} \]
\[ \ruleform{ \reftvalid{\rho}{(\varphi,\rho)}, \qquad \reftvalid{\rho}{\Theta}} \]
\[
\begin{array}{c}
  \inferrule{
  }{
    \reftvalid{\rho}{(\true,\rho)}
  }
\qquad
  \inferrule{
    {\rho(x) = K \; \overline{d}}
  }{
    \reftvalid{\rho}{(\ctcon{K \; \overline{y}}{x},\rho[\overline{y \mapsto d}])}
  }
\qquad
  \inferrule{
    {\rho(x) \not= K \; \overline{d}}
  }{
    \reftvalid{\rho}{(x \ntermeq K,\rho)}
  }
\\
\\[-0.5em]
  \inferrule{
    {\rho(x) = \bot}
  }{
    \reftvalid{\rho}{(x \termeq \bot,\rho)}
  }
\qquad
  \inferrule{
    {\rho(x) \not= \bot}
  }{
    \reftvalid{\rho}{(x \ntermeq \bot,\rho)}
  }
\qquad
  \inferrule{
  }{
    \reftvalid{\rho}{(\ctlet{x}{e},\rho[x \mapsto \exprsem{e}_\rho])}
  }
\\
\\[-0.5em]
  \inferrule{
    \Gamma_1 \vdash \rho_1 \quad
    \Gamma_2 \vdash \rho_2 \quad
    \reftvalid{\rho_1}{(\varphi,\rho_2)} \quad \reftvalid{\rho_2}{\reft{\Gamma}{\Phi}}
  }{
    \reftvalid{\rho_1}{\reft{\Gamma_1}{\varphi \wedge \Phi}}
  }
\qquad
  \inferrule{
    \reftvalid{\rho}{\reft{\Gamma}{\Phi_1}}
  }{
    \reftvalid{\rho}{\reft{\Gamma}{\Phi_1 \vee \Phi_2}}
  }
\qquad
  \inferrule{
    \reftvalid{\rho}{\reft{\Gamma}{\Phi_2}}
  }{
    \reftvalid{\rho}{\reft{\Gamma}{\Phi_1 \vee \Phi_2}}
  }
\end{array}
\]

\caption{Semantics of guard trees}
\label{fig:sem}
\end{figure}

The evaluation in \Cref{sec:eval} yields compelling evidence that \lyg is \emph{sound}.
That is, in terms of the formalism, \lyg \emph{overapproximates}---but never
underapproximates---the set of reaching values passed to $\unc$ and $\ann$.
As a result, \lyg will never fail to report uncovered clauses (no false
negatives), but it may report false positives. Similarly, \lyg will never report
accessible clauses as redundant (no false positives), but it may fail to report
clauses which are redundant when the code involved is too close to ``undecidable
territory''.

Remarkably, the symbolic checking process involving $\unc$, $\ann$ und $\red$
does not overapproximate at all.
To our knowledge, \lyg overapproximates only in these three mechanisms:

\begin{itemize}
  \item
    \lyg can run out of fuel for inhabitation testing (\Cref{sec:inhabitation}).

  \item
    Throttling (\Cref{ssec:throttling}) is useful when implementing \lyg efficiently.

  \item
    \lyg forgoes non-trivial semantic analysis of expressions. \lyg can
    recognize identical patterns or subexpressions, but it stops short of
    anything more sophisticated, such as interprocedural analysis or
    SMT-style reasoning (\Cref{ssec:comparison-with-structural}).
\end{itemize}

But what does it actually \emph{mean} for a value to match a particular part of
a guard tree, such as a right-hand side $\gdtrhs{k}$?
In what precise sense does \lyg --- or does not --- overapproximate this supposed
\emph{semantics}?

Since this work appeared at ICFP 2020, \citet{dieterichs:thesis} worked out both
a formal semantics as well as a mechanised correctness proof in Lean 3 for the
coverage checking pass from guard trees into uncovered set and annotated trees.%
\footnote{Types and type constraints are ignored; their interaction is largely
a black box to our approach anyway.}
He shows that $\unc$, $\ann$ and $\red$ preserve key semantic properties of the
guard trees under analysis, provided that function $\generate(\Theta)$ for
generating inhabitants indeed overapproximates $\Theta$.
We will briefly summarise the correctness results here.
For that, we need to define a plausible formal semantics for guard trees and
refinement predicates.

\subsection{Semantics} \label{ssec:sem}

We have described the semantics of guard trees and guards informally in
\Cref{sec:desugar}.
\Cref{fig:sem} formalises this intuition, describing the semantics of
guard trees by a function $\gdtsem{t}_\rho$ that, given a guard tree $t$ and an
environment $\rho$ describing a vector of values to match against, returns

\begin{itemize}
  \item
    $\yes{k}$ when $\rho$ is a vector of values that will reach RHS $k$ when
    matched against $t$.

  \item
    $\no$ when $\rho$ is a vector of values that is not covered
    by $t$.

  \item
    $\diverge$ when $\rho$ is a vector of values that will lead to
    divergence when matched against $t$.
\end{itemize}

Likewise, the valuation $\grdsem{g}_\rho$ returns $\yes{\rho'}$ when the vector
of values $\rho$ matches guard $g$, extending $\rho$ with new bindings into
$\rho'$.
The semantics of expressions $\exprsem{e}_\rho$ maps into the semantic domain
$\Domain$, just as the environment $\rho$.
Since this work leaves open a lot of details about the expression fragment
of the source language, the semantics leaves open $\Domain$ and most of
$\exprsem{e}_\rho$ as well, with the exception of postulating a semantics for
the data constructor application case.

Refinement types have been introduced by informal examples in \Cref{sec:check},
denoting refinement types $\Theta$ by sets of vectors of values $\rho$ that
satisfy the encoded refinement predicate.
\Cref{fig:sem} finally defines the satisfiability relation by an inductive
predicate $\reftvalid{\rho}{\Theta}$.
Thus, whenever a vector of values $\rho$ is part of the set denoted by a
refinement type $\Theta$, the inductive predicate must be provable.

The definition of $\reftvalid{\rho}{\Theta}$ assumes that conjunction $\wedge$
is associated to the right, $\varphi \wedge \Phi$, highlighting the unusual
scoping semantics briefly mentioned in \Cref{sec:check}.
Any binding constructs in the $\varphi$ to the left of $\wedge$, such as
$\ctlet{x}{e}$ or $\ctcon{K \; \overline{y}}{x}$, introduce names that are
subsequently in scope in the $\Phi$ to the right of $\wedge$.
In hindsight, we could have picked a different operator symbol to
avoid this confusion, for example $(\varphi~\textsf{in}~\Phi)$, such as in
\citet{dieterichs:thesis}.
Doing so would however complicate the $(\Theta \andtheta \varphi)$ operator a bit.
In the absence of types, the postulated judgment $\Gamma \vdash \rho$ merely
becomes a scoping check, namely that $\Gamma$ has the same domain as $\rho$.

\subsection{Formal Soundness Statement}

Having stated plausible semantics for the inputs and outputs of $\unc$, we can
formulate what it means for $\unc$ to be correct, following \citet[Section
4.1]{dieterichs:thesis} who mechanised the proof in Lean 3.

\begin{theorem}
  \label{thm:unc}
  Let $\unc(\reft{\Gamma}{\true},t) = \Theta$.
  Then $\gdtsem{t}_\rho = \no$ if and only if $\reftvalid{\rho}{\Theta}$.
\end{theorem}

In other words: when $\Theta$ is the set of uncovered values of guard tree $t$
as computed by $\unc$, then any vector of values $\rho$ that falls through
all clauses of $t$ (i.e., $\gdtsem{t}_\rho = \no$) is in $\Theta$
(\ie $\reftvalid{\rho}{\Theta}$).
In this precise sense, $\unc$ is \emph{sound}.
Conversely, when $\unc$ returns a non-empty refinement type $\Theta$, there
exists a vector of values $\rho$ in $\Theta$, and by \Cref{thm:unc} we have that
$\rho$ must also fall through all clauses of $t$.
In this precise sense, $\unc$ is \emph{complete}.

Of course, the judgment $\reftvalid{\rho}{\Theta}$ frequently compares domain
values $d$ that ultimately come from evaluating expressions $\exprsem{e}_\rho$,
rendering the predicate undecidable for many source languages.
Thus, any implementation of $\generate$ will be sound \wrt
$\reftvalid{\rho}{\Theta}$, but not complete --- it will \emph{overapproximate}
$\Theta$. \citet{dieterichs:thesis} captures this in his
\texttt{can\_prove\_empty} definition to abstract over sound implementations of
$\generate$.
\citet[Section 4.2]{dieterichs:thesis} proves the following soundness theorem
about $\ann$ and $\red$.

\begin{theorem}
\label{thm:red}
Let $\red(\ann(\reft{\Gamma}{\true}, t)) = (a,i,r)$ and $\generate$ sound in the
above sense.
\begin{itemize}
\item
  If $\gdtsem{t}_\rho = \yes{k}$, then $k \in a$, \ie clause $k$ is accessible
  according to $\ann$ and $\red$.

\item
  If $k \in r$ is redundant, then removing clause $k$ from guard tree $t$
  does not change the semantics of $t$, \ie $\forall \rho.\ \gdtsem{t}_\rho =
  \gdtsem{\mathit{remove}(k,t)}_\rho$ (where $\mathit{remove}(k,t)$ is the
  implied removal operation).
\end{itemize}
\end{theorem}

Perhaps unsurprisingly, proving correct the transformation in the second part of
\Cref{thm:red} proved far more subtle than the proof for \Cref{thm:unc}.
Fortunately, the mechanisation provides confidence in the proof's correctness.

\section{Related Work} \label{sec:related}

\subsection{Comparison with GADTs Meet Their Match}
\label{ssec:gmtm}

\citet{gadtpm} present GADTs Meet Their Match (\gmtm), an algorithm which
handles many of the subtleties of GADTs, guards, and laziness mentioned in
\Cref{sec:problem}. Despite this, the \gmtm algorithm still gives incorrect
warnings in many cases.

\subsubsection{\gmtm Does Not Consider Laziness in its Full Glory}

The formalism in \citet{gadtpm} incorporates strictness constraints, but
these constraints can only arise from matching against data constructors.
\gmtm does not consider strict matches that arise from strict fields of
data constructors or bang patterns. A consequence of this is that \gmtm
would incorrectly warn that |v| (\Cref{ssec:strictness}) is missing a case for
|SJust|, even though such a case is unreachable. \lyg, on the other hand,
more thoroughly tracks strictness when desugaring Haskell programs.

\subsubsection{\gmtm's Treatment of Guards Is Shallow}

\gmtm can only reason about guards through an abstract term oracle. Although
the algorithm is parametric over the choice of oracle, in practice the
implementation of \gmtm in GHC uses an extremely simple oracle that can only
reason about guards in a limited fashion. More sophisticated uses of guards,
such as in this variation of the |safeLast| function from \Cref{sssec:viewpat},
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
(\Cref{ssec:extviewpat}) demonstrates. While \gmtm's term oracle could be
improved to accomplish the same thing, it is unlikely to be as
straightforward of a process as extending $\addphi$.

\subsection{Comparison with Similar Coverage Checkers}

\subsubsection{Structural and Semantic Pattern Matching Analysis in Haskell}
\label{ssec:comparison-with-structural}

\citet{kalvoda2019structural} implement a variation of \gmtm that leverages an
SMT solver to give more accurate coverage warnings for programs that use
guards. For instance, their implementation can conclude that
the |signum| function from \Cref{ssec:guards} is exhaustive. This is something
that \lyg cannot do out of the box, although it would be possible to
extend $\addphi$ with SMT-like reasoning about booleans and linear integer arithmetic.
% \ryan{Sebastian: is this the thing that would need to be extended?}
% \sg{Yes, I imagine that $\addphi$ would match on arithmetic expressions and then
% add some kind of new $\delta$ constraint to $\Delta$. $\adddelta$ would then
% have to do the actual linear arithmetic reasoning, \eg conclude from
% $x \not< e, x \ntermeq e, x \not> e$ (and $x \ntermeq \bot$) that $x$ is not
% inhabited, quite similar to a \extension{COMPLETE} set.}

\subsubsection{Warnings for Pattern Matching}
\label{ssec:maranget}

\citet{maranget:warnings} presents a coverage checking algorithm for OCaml that
can identify clauses that are not \emph{useful}, \ie \emph{useless}. While
OCaml is a strict language, the algorithm can be adapted to handle languages
with non-strict semantics such as Haskell. In a lazy setting, uselessness
corresponds to our notion of unreachable clauses.
\citeauthor{maranget:warnings} does not distinguish inaccessible clauses from
redundant ones; thus clauses flagged as useless (such as the first two clauses
of |u'| in \Cref{sssec:inaccessibility}) generally cannot be deleted without
changing (lazy) program semantics.

\subsubsection{Case Trees in Dependently Typed Languages}

\emph{Case tree}s \citep{augustsson-case-trees} are a standard way of compiling
pattern matches to efficient code. Much like \lyg's guard trees, case trees
present a simplified representation of pattern matching. Several compilers for
dependently typed languages also use case trees as coverage checking algorithms,
as a well typed case tree can guarantee that it covers all possible cases.
Case trees play an integral role in coverage checking in
Agda \citep{norellphd,dependent-copattern} and the Equations plugin for Coq
\citep{equations,equations-reloaded}. \citet{oury} checks for coverage in
a dependently typed setting using sets of inhabitants of data types,
which have similarities to case trees.

One could take inspiration from case trees should one wish to extend \lyg to
support dependent types. Our implementation of \lyg in GHC can already handle
quasi-dependently typed code, such as the \texttt{singletons} library
\citep{singletons,singletons-promotion}, so we expect that it can be adapted to
full dependent types. One key change that would be required is extending equation
(9) in \Cref{fig:add} to reason about term constraints in addition to type
constraints. GHC's constraint solver already has limited support for term-level
reasoning as part of its \texttt{DataKinds} language extension
\citep{hspromoted}, so the groundwork is present.

\subsubsection{Refinement Type--Based Totality Checking in Liquid Haskell}

In addition to \lyg, Liquid Haskell uses refinement types to perform a limited form of
exhaustivity checking \citep{liquidhaskell,refinement-reflection}.
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

\subsection{Other Representations of Constraints}

\subsubsection{Leveraging Existing Constraint Solvers}

\lyg represents $\Phi$ constraints using logical predicates that are
tailor-made for \lyg's purposes. One could instead imagine encoding $\Phi$
constraints in a more standard logic and then using an ``off-the-shelf''
constraint solver to check them. This would render \Cref{fig:add} and the
arguably rather intricate \Cref{sec:normalise,sec:inhabitation} unnecessary,
and it allows the checker to benefit from improvements to the solver without
any further maintenance burden.

Encoding $\Phi$ constraints into another logic would have its downsides,
however. The $\addphi$ function is able to reason about \lyg-oriented
predicates rather efficiently, but other constraint solvers (e.g., STM solvers)
might incur significant constant factors. Moreover, elaborating from
one logic to another could inhibit programmers from forming a mental model of
how coverage checking works.

\subsubsection{Refinement Types versus Predicates}

Refinement types $\Theta$ and predicates $\Phi$ are very similar. The main
difference between the two is that refinement types carry a typing context
$\Gamma$ that is used for inhabitation testing. Predicates are quite fully
featured on their own, however, as they can bind variables that scope over
conjunctions. The scoping semantics of predicates allows $\unc$ and $\ann$ to
be purely syntactic transformations, and in fact, they could be modified to take
$\Phi$ as an argument rather than $\Theta$.

Making $\unc$ and $\ann$ operate over $\Theta$ or $\Phi$ is ultimately a design
choice. We have opted to operate over $\Theta$ mainly because we find it
more intuitive to think about coverage checking as refining a vector of values as
it falls from one match to the next. In our opinion, that intuition is more
easily expressed with refinement types than predicates alone.

\subsection{Positive and Negative Information}
\label{ssec:negative-information}

\lyg's use of positive and negative constructor constraints is inspired by
\citet{sestoft1996ml}, which uses positive and negative information to
implement a pattern-match compiler for ML. Sestoft utilises positive and
negative information to generate decision trees that avoid scrutinizing the
same terms repeatedly. This insight is equally applicable to coverage checking
and is one of the primary reasons for \lyg's efficiency.

Besides efficiency, the accuracy of redundancy warnings involving \extension{COMPLETE} sets hinge
on negative constraints. To see why this is not possible in other checkers that
only track positive information, such as those of
\citet{gadtpm} (\Cref{ssec:gmtm})
and
\citet{maranget:warnings} (\Cref{ssec:maranget}),
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
while choosing $\{|True|,|False|\}$ will not. GHC's implementation used to try
each \extension{COMPLETE} set in turn and would disambiguate using a
complicated metric based on the number and kinds of warnings the choice of each
set would generate \citep{complete-users-guide}, which was broken still
\citep{gitlab:13363}.

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

\subsection{Strict Fields in Inhabitation Testing}
\label{ssec:strict-fields}

The $\mathsf{Inst}$ function in \Cref{fig:inh} takes strict fields into account
during inhabitation testing, which is essential to conclude that the |v|
function from \Cref{ssec:strictness} is exhaustive. This trick was pioneered
by \citet{oury}, who uses it to check for unreachable cases in the presence of
dependent types. Coverage checkers for strict and total programming
languages usually implement inhabitation testing, but sometimes with
less-than-perfect results. As two data points, we decided to see how OCaml and
Idris, two call-by-value languages that check for pattern-match coverage
\footnote{Idris has separate compile-time and runtime semantics, the latter
of which is call by value.},
would fare when checking functions like |v|:

\begin{minipage}{\textwidth}
\begin{minipage}{0.4\textwidth}
\centering
\begin{code}
(* OCaml *)
type void = |;;

let v (None : void option) : int = 0;;
let v' (o : void option) : int =
      match o with
        None    -> 0
      | Some _  -> 1;;
\end{code}
\end{minipage} %
\begin{minipage}{0.4\textwidth}
\centering
\begin{code}
-- Idris
v : Maybe Void -> Int
v Nothing  = 0

v' : Maybe Void -> Int
v' Nothing   = 0
v' (Just _)  = 1
\end{code}
\end{minipage}
\end{minipage}

Both OCaml 4.10.0 and Idris 1.3.2 correctly mark their respective versions of
|v| as exhaustive. OCaml also correctly warns that the |Some| case in |v'| is
unreachable, while Idris emits no warnings for |v'| at all.

\Cref{sec:inhabitation} also contains an example of a function |f| that \lyg
will fail to recognize as exhaustive due to \lyg's conservative, fuel-based
approach to inhabitation testing. Porting |f| to OCaml and Idris reveals that
both languages will also conservatively claim that |f| is non-exhaustive:

\begin{minipage}{\textwidth}
\begin{minipage}{0.4\textwidth}
\centering
\begin{code}
(* OCaml *)
type t = MkT of t;;

let f (None : t option) : int = 0;;
\end{code}
\end{minipage} %
\begin{minipage}{0.4\textwidth}
\centering
\begin{code}
-- Idris
data T : Type where
  MkT : T -> T

f : Maybe T -> Int
f Nothing = 0
\end{code}
\end{minipage}
\end{minipage}

Indeed, the warning that OCaml produces will cite
|Some (MkT (MkT (MkT (MkT (MkT _)))))|
as a case that is not matched, which suggests that OCaml may also be using
a fuel-based approach. We believe these examples show that inhabitation testing
is something that programming language implementors have discovered
independently, but with varying degrees
of success in putting into practice. We hope that \lyg can bring this
knowledge into wider use.

\section{Conclusion}

In this paper, we describe Lower Your Guards, a coverage checking algorithm that
distills rich pattern matching into simple guard trees. Guard trees are
amenable to analyses that are not easily expressible in coverage checkers
that work over structural pattern matches.
The last four years of continued maintenance of GHC's implementation offer a
compelling retrospective: the approach scales well to new language features,
causes very few functional bug reports in practice, and offers robust
performance.

\begin{acks}
We would like to thank the anonymous ICFP reviewers for their feedback, as well
as Henning Dieterichs, Martin Hecker, Sylvain Henry, Philipp Kr\"uger, Luc
Maranget and Sebastian Ullrich.
\end{acks}

\bibliography{references}

\end{document}
