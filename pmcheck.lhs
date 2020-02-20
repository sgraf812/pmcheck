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

\title{GADTs Meet Their Match:}
\subtitle{Pattern-Matching Warnings That Account for GADTs, Guards, and Laziness}

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

\maketitle

\begin{abstract}

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
if a function is missing clauses (i.e., if it is \emph{non-exhaustive}) or if
a function has overlapping clauses (i.e., if it is \emph{redundant}). We refer
to the combination of checking for exhaustivity and redundancy as
\emph{pattern-match coverage checking}. Coverage checking is the first line
of defence in catching programmer mistakes when defining code that uses
pattern matching.

If coverage checking catches mistakes in pattern matches, then who checks for
mistakes in the coverage checker itself? It is a surprisingly frequent
occurrence for coverage checkers to contain bugs that impact correctness.
This is especially true in Haskell, which has an especially rich pattern
language, and the Glasgow Haskell Compiler (GHC) complicates the story further
by adding pattern-related language extensions. Designing a coverage
checker that can cope with all of these features is no small task.

The current state of the art for coverage checking GHC is
\citet{gadtpm}, which presents an algorithm that handles the intricacies of
checking GADTs, lazy patterns, and pattern guards. We argue that this
algorithm is insufficient in a number of key ways. It does not account for a number of
important language features and even gives incorrect results in certain cases.
Moreover, the implementation of this algorithm in GHC is inefficient and has
proved to be difficult to maintain due to its complexity.

In this paper we propose a new algorithm, called \sysname, that addresses the
deficiencies of \citet{gadtpm}. The key insight of \sysname is to condense all
of the complexities of pattern matching into just three constructs:
|let| bindings, pattern guards, and bang guards. We make the
following contributions:
\ryan{Cite section numbers in the list below.}

\begin{itemize}
\item
  We characterise the nuances of coverage checking that not even the
  algorithm in \cite{gadtpm} handles. We also identify issues in GHC's
  implementation of this algorithm.

\item
  \ryan{Describe the "Overview Over Our Solution" section and "Formalism" sections.}

\item
  We have implemented \sysname in GHC. \ryan{More details.}
\end{itemize}

We discuss the wealth of related work in \TODO.

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


\section{The problem we want to solve}

\begin{figure}

\caption{Definitions used in the text}
\label{fig:definitions}
\end{figure}

What makes coverage checking so difficult in a language like Haskell? At first
glance, implementing a coverage checker algorithm might appear simple: just
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
\ryan{Cite related work section}) accounts for some of these nuances, but
not all of them. In this section we identify all of the language features that
complicate coverage checking. While these features may seem disparate at first,
we will later show in \ryan{Cite the relevant section} that these ideas can all
fit into a unified framework.

\subsection{Guards}

Guards are a flexible form of control flow in Haskell. Here is a function that
demonstrates various capabilities of guards:

\begin{code}
guardDemo :: Char -> Char -> Int
guardDemo c1 c2
  | c1 == 'a' = 0
  | 'b' <- c1 = 1
  | let c1' = c1, 'c' <- c1', c2 == 'd' = 2
  | otherwise = 3
\end{code}

The first guard is a boolean-valued guard that evaluates its right-hand side if
the expression in the guard returns |True|. The second guard is
a \emph{pattern guard} that evaluates its right-hand side if the pattern in
the guard successfully matches. Moreover, a guard can have |let| bindings or
even multiple checks, as the third guard demonstrates. Note that the fourth
guard uses |otherwise|, a boolean guard that is guaranteed to match successfully.

Guards can be thought of as a generalization of patterns, and we would like to
include them as part of coverage checking. Checking guards is significantly more
complicated than checking ordinary pattern matches, however, since guards can
contain arbitrary expressions. Consider this implementation of the |signum|
function:

\begin{code}
signum :: Int -> Int
signum x
  | x > 0 = 1
  | x == 0 = 0
  | x < 0 = -1
\end{code}

Intuitively, |signum| is exhaustive since the combination of |(>)|, |(==)|, and
|(<)| covers all possible |Int|s. This is much harder for a machine to check,
however, since that would require knowledge about the properties of |Int|
inequalities. In fact, coverage checking for guards in the general case is an
undecidable problem. While we cannot accurately check \emph{all} uses of guards,
we can at least give decent warnings for some commonly use cases for guards.
For instance, take the following function that only uses pattern guards:

\begin{code}
not :: Bool -> Bool
not b
  | False <- b = True
  | True <- b = False
\end{code}

|not| is clearly equivalent to the following function that matches on its argument
without guards:

\begin{code}
not' :: Bool -> Bool
not' False = True
not' True = False
\end{code}

We would like our coverage checking algorithm to mark both |not| and |not'|
as exhaustive, and \sysname does so. We explore the subset of guards that
\sysname can check in more detail in \ryan{Cite relevant section}.

\subsection{Strictness}

The evaluation order of pattern matching can impact whether a pattern is
reachable or not. While Haskell is a lazy language, programmers can opt
into extra strict evaluation by giving the fields of a data type strict fields,
such as in this example: \ryan{Consider moving some of this code to the figure}
\ryan{There is an erroneous space between the |!| and the |a|}

\begin{code}
data Void -- No data constructors
data SMaybe a = SJust !a | SNothing

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
reached. The only way to use |SJust| to construct a value of type |SMaybe Void|
is |SJust| $\bot$, since |Void| has no data constructors. Because |SJust| is
strict in its field, matching on |SJust| will cause |SJust| $\bot$ to diverge,
since matching on a data constructor evaluates it to WHNF. As a result, there
is no argument one could pass to |v| to make it return |1|, which makes the
|SJust| case unreachable.

Although \citet{gadtpm} incorporates strictness constraints into their algorithm,
it does not consider constraints that arise from strict fields.
\ryan{Say more here?}

\subsubsection{Bang patterns}

Strict fields are the primary mechanism for adding extra strictness in Haskell, but
GHC adds another mechanism in the form of \emph{bang patterns}. A bang pattern
such as |!pat| indicates that matching against |pat| \emph{always} evaluates it to
WHNF. While data constructor matches are normally the only patterns that match
strictly, bang patterns extend this treatment to other patterns. For example,
one can rewrite the earlier |v| example to use the ordinary, lazy |Maybe| data
type: \ryan{I actually wanted to write Just !\_, but LaTeX won't parse that :(}

\begin{code}
v' :: Maybe Void -> Int
v' Nothing = 0
v' (Just !x) = 1
\end{code}

The |Just| case in |v'| is unreachable for the same reasons that the |SJust| case in
|v| is unreachable. Due to bang patterns, a strictness-aware coverage-checking
algorithm must be consider the effects of strictness on any possible pattern,
not just those arising from matching on data constructors with strict fields.

\subsubsection{Newtypes}

\TODO

\subsection{Programmable patterns}

\TODO

\subsubsection{Overloaded literals}

\TODO

\subsubsection{View patterns}

\TODO

\subsubsection{Pattern synonyms}

Pattern synonyms~\cite{patsyns} allow abstracting over patterns in a very general
fashion. For example, one can define patterns that allow viewing Haskell's
opaque |Text| data type as though it were a linked list of characters:

\begin{code}
pattern Nil :: Text
pattern Nil <- (Text.null -> True)

pattern Cons :: Char -> Text -> Text
pattern Cons x xs <- (Text.uncons -> Just (x, xs))

length :: Text -> Int
length Nil = 0
length (Cons x xs) = 1 + length xs
\end{code}

How should a coverage checker handle pattern synonyms? One idea is to simply look
through the definitions of each pattern synonym and verify whether the underlying
patterns are exhaustive. This would be undesirable, however, because (1) we would
like to avoid leaking the implementation details of abstract pattern synonyms, and
(2) even if we \emph{did} look at the underlying implementation, it would be
challenging to automatically check that the combination of |Text.null| and
|Text.uncons| is exhaustive.

Intuitively, |Text.null| and |Text.uncons| are obviously exhaustive. GHC allows
programmers to communicate this sort of intuition to the coverage checker in the
form of |COMPLETE| sets.
\ryan{Cite the |COMPLETE| section of the users guide.}
A |COMPLETE| set is a combination of data constructors
and pattern synonyms that should be regarded as exhaustive when a function matches
on all of them.
For example, declaring |{-# COMPLETE Nil, Cons #-}| is sufficient to make
the definition of |length| above compile without any exhaustivity warnings.
Since GHC does not (and cannot, in general) check that all of the members of
a |COMPLETE| actually comprise a complete set of patterns, the burden is on
the programmer to ensure that this invariant is upheld.

\ryan{More?}

\subsection{Term and type constraints}

\TODO

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
  defn   &\Coloneqq& \overline{clause} \\
  clause &\Coloneqq&  f \; \overline{pat} \; \overline{match} \\
  pat    &\Coloneqq& x \mid |_| \mid K \; \overline{pat} \mid x|@|pat \mid |!|pat \mid |~|pat \mid x \, \mathtt{+} \, l \\
  match  &\Coloneqq& \mathtt{=} \; expr \mid \overline{grhs} \\
  grhs   &\Coloneqq& \mathtt{\mid} \; \overline{guard} \; \mathtt{=} \; expr \\
  guard  &\Coloneqq& pat \leftarrow expr \mid expr \mid \mathtt{let} \; x \; \mathtt{=} \; expr \\
\end{array}
\end{array}
\]

\caption{Source syntax}
\label{fig:srcsyn}
\end{figure}

\section{Overview of Our Solution}

\begin{figure}
\includegraphics{pipeline.eps}
\caption{Bird's eye view of pattern match checking}
\label{fig:pipeline}
\end{figure}

\begin{figure}
\centering
\[ \textbf{Guard Syntax} \]
\[
\begin{array}{cc}
\begin{array}{rlcl}
  K           \in &\Con &         & \\
  x,y,a,b     \in &\Var &         & \\
  \tau,\sigma \in &\Type&         & \\
  e \in           &\Expr&\Coloneqq& x \\
                  &     &\mid     & \expconapp{K}{\tau}{\sigma}{\gamma}{e} \\
                  &     &\mid     & ... \\
\end{array} &
\begin{array}{rlcl}
  k,n,m  \in      &\mathbb{N}&    & \\

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

In this section, we aim to provide an intuitive understanding of our pattern
match checking algorithm, by way of deriving the intermediate representations
of the pipeline step by step from motivating examples.

%TODO: Not sure how I can tell ipe (the program from which I exported the
%      graphics) to use the ACM font
\Cref{fig:pipeline} depicts a high-level overview over this pipeline.
Desugaring the complex source Haskell syntax to the very elementary language of
guard trees $\Gdt$ via $\ds$ is an incredible simplification for the checking
process. At the same time, $\ds$ is the only transformation that is specific to
Haskell, implying easy applicability to other languages. The resulting guard
tree is then processed by two different functions, $\ann$ and $\unc$, which
compute redundancy information and uncovered patterns, respectively. $\ann$
boils down this information into an annotated tree $\Ant$, for which the set of
redundant and inaccessible right-hand sides can be computed in a final pass of
$\red$. $\unc$ on the other hand returns a \emph{refinement type} representing
the set of \emph{uncovered values}, for which $\generate$ can generate the
inhabiting patterns to show to the user.

\subsection{Desugaring to Guard Trees}

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

% TODO: Work on code style
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

Hence our algorithm desugars the source syntax to the following \emph{guard
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
binding. Note that |otherwise| is an external identifier which we can assume to
be bound to |True|, which is in fact how it defined.

Pattern guards in $\Grd$ are the only guards that can possibly fail to match,
in which case the value of the scrutinee was not of the shape of the
constructor application it was matched against. The $\Gdt$ tree language
determines how to cope with a failed guard. Left-to-right matching semantics is
captured by $\gdtguard{}{\hspace{-0.6em}}$, whereas top-to-bottom backtracking
is expressed by sequence ($\gdtseq{}{}$). The leaves in a guard tree each
correspond to a GRHS.

\subsection{Checking Guard Trees}

Pattern match checking works by gradually refining the set of reaching values
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
tree could fail. It is not obvious at all for humans to read off satisfying
values
\ryan{Did you mean to write ``satisfiable values'' instead of
``satisfying values'' here? Again, the latter reads strangely to me.}
\sg{I think I agree. I was thinking of the values that satisfy $\Phi$ and thus
inhabit $\Theta$. Maybe ``inhabiting values'' then?}
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
problem. Consider this example: \sg{I think this kind of detail should be
motivated in a prior section and then referenced here for its solution.}

\begin{code}
g :: () -> Int
g ()   | False   = 1
       | True    = 2
g _              = 3
\end{code}

Is the first GRHS just inaccessible or even redundant? Although the match on
|()| forces the argument, we can delete the first GRHS without changing program
semantics, so clearly it is redundant.
But that wouldn't be true if the second GRHS wasn't there to ``keep alive'' the
|()| pattern!

Here is the corresponding annotated tree after checking:

\begin{forest}
  anttree
  [
    [{\lightning}
      [1,inacc]
      [2,acc]]
    [3,acc]]
\end{forest}

In general, at least one GRHS under a \lightning{} may not be flagged as
redundant ($\times$).
Thus the checking algorithm can't decide which GRHSs are redundant (\vs just
inaccessible) when it reaches a particular GRHS.

\subsection{Generating Inhabitants of a Refinement Type}

The predicate literals $\varphi$ of refinement types look quite similar to the
original $\Grd$ language, so how is checking them for emptiness an improvement
over reasoning about about guard trees directly? To appreciate the transition,
it is important to realise that semantics of $\Grd$s are \emph{highly
non-local}! Left-to-right and top-to-bottom match semantics means that it is
hard to view $\Grd$s in isolation; we always have to reason about whole
$\Gdt$s. By contrast, refinement types are self-contained, which means the
process of generating inhabitants can be treated separately from the process
of pattern match checking
\ryan{We inconsistently switch between calling it ``pattern match checking''
and ``coverage checking'' in the prose. We should adopt one term and stick with it.}
\sg{I think I like ``coverage checking'' (after introducing it as ``pattern match coverage checking'' better, provided the term subsumes both exhaustivity and overlap checking.}

Apart from generating inhabitants of the final uncovered set for non-exhaustive
match warnings, there are two points at which we have to check whether
a refinement type has become empty: To determine whether a right-hand side is
inaccessible and whether a particular bang guard may lead to divergence and
requires us to wrap a \lightning{}.

Take the final uncovered set $\Theta_{|liftEq|}$ after checking |liftEq| above
as an example. \sg{Do we need to give its predicate here again?}
A bit of eyeballing |liftEq|'s definition reveals that |Nothing (Just _)| is an
uncovered pattern, but eyeballing the constraint formula of $\Theta_{|liftEq|}$
seems impossible in comparison. A more systematic approach is to adopt a
generate-and-test scheme: Enumerate possible values of the data types for each
variable involved (the pattern variables |mx| and |my|, but also possibly the
guard-bound |x|, |y| and |t|) and test them for compatibility with the recorded
constraints.

Starting from |mx my|, we enumerate all possibilities for the shape of |mx|,
and similarly for |my|. The obvious first candidate in a lazy language is
$\bot$! But that is a contradicting assignment for both |mx| and |my|
indepedently. Refining to |Nothing Nothing| contradicts with the left part
of the top-level $\wedge$. Trying |Just y| (|y| fresh) instead as the shape for
|my| yields our first inhabitant! Note that |y| is unconstrained, so $\bot$ is
a trivial inhabitant. Similarly for |(Just _) Nothing| and |(Just _) (Just _)|.

Why do we have to test guard-bound variables in addition to the pattern
variables? It is because of empty data types and strict fields:
\sg{This example will probably move to an earlier section}

\begin{code}
data Void -- No data constructors
data SMaybe a = SJust !a | SNothing
v :: SMaybe Void -> Int
v x@SNothing = 0
\end{code}

|v| does not have any uncovered patterns. And our approach should see that
by looking at its uncovered set
$\reft{x : |Maybe Void|}{x \ntermeq \bot \wedge x \ntermeq \mathtt{Nothing}}$.
Specifically, the candidate |SJust y| (for fresh |y|) for |x| should be rejected,
because there is no inhabitant for |y|! $\bot$ is ruled out by the strict field
and |Void| has no data constructors with which to instantiate |y|. Hence it is
important to test guard-bound variables for inhabitants, too.

\sg{GMTM goes into detail about type constraints, term constraints and
worst-case complexity here. That feels a bit out of place.}

\section{Formalism}

The previous section gave insights into how we represent pattern match checking
problems as guard trees and provided an intuition for how to check them for
exhaustiveness and redundancy. This section formalises these intuitions in
terms of the syntax (\cf \cref{fig:syn}) we introduced earlier.

As in the previous section, we divide this section into three main parts:
desugaring, pattern match checking and finding inhabitants of the resulting
refinement types. The latter subtask proves challenging enough to warrant two
additional subsections.

\subsection{Desugaring to Guard Trees}

\begin{figure}

\[ \ruleform{ \ds(defn) = \Gdt, \ds(clause) = \Gdt, \ds(grhs) = \Gdt } \]
\[ \ruleform{ \ds(guard) = \overline{\Grd}, \ds(x, pat) = \overline{\Grd} } \]
\[
\begin{array}{lcl}

\ds(clause_1\,...\,clause_n) &=&
  \vcenter{\hbox{\begin{forest}
    grdtree,
    grhs/.style={tier=rhs,edge={-}},
    [ [{$\ds(clause_1)$}] [...] [{$\ds(clause_n)$}] ] ]
  \end{forest}}} \\
\\
\ds(f \; pat_1\,...\,pat_n \; \mathtt{=} \; expr) &=&
  \vcenter{\hbox{\begin{forest}
    grdtree,
    [ [{$\ds(x_1, pat_1)\,...\,\ds(x_n, pat_n)$} [{$k$}] ] ]
  \end{forest}}} \\
\ds(f \; pat_1\,...\,pat_n \; grhs_1\,...\,grhs_m) &=&
  \vcenter{\hbox{\begin{forest}
    grdtree,
    grhs/.style={tier=rhs,edge={-}},
    [ [{$\ds(x_1, pat_1)\,...\,\ds(x_n, pat_n)$} [{$\ds(grhs_1)$}] [...] [{$\ds(grhs_m)$}] ] ]
  \end{forest}}} \\
\\
\ds(\mathtt{\mid} \; guard_1\,...\,guard_n \; \mathtt{=} \; expr) &=&
  \vcenter{\hbox{\begin{forest}
    grdtree,
    [ [{$\ds(guard_1)\,...\,\ds(guard_n)$} [{$k$}] ] ]
  \end{forest}}} \\
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
\ds(x, |~|pat) &=& \epsilon \\
\ds(x, y\,\mathtt{+}\,l) &=& \ds(|x >= l|), \grdlet{y}{|x - l|} \\

\end{array}
\]
\caption{Desugaring Haskell to $\Gdt$}
\label{fig:desugar}
\end{figure}

\sg{I find this section quite boring. There's nothing to see in \cref{fig:desugar} that wasn't already clear after reading 3.1.}

\Cref{fig:desugar} outlines the desugaring step from source Haskell to our
guard tree language $\Gdt$. It is assumed that the top-level match variables
$x_1$ through $x_n$ in the $clause$ cases have special, fixed names. \sg{If we
had a different font for meta variables than for object variables, we could
make that visible in syntax. But we don't...} All other variables that aren't
bound in arguments to $\ds$ have fresh names.

Consider this example function \sg{Maybe use the same function as in 3.1? But we already desugar it there...}:

\begin{code}
f (Just (!xs,_))  ys@Nothing  = 1
f Nothing         zs          = 2
\end{code}

Under $\ds$, this desugars to

\begin{forest}
  grdtree,
  [
    [{$\grdbang{x_1}, \grdcon{|Just t_1|}{x_1}, \grdbang{t_1}, \grdcon{(t_2, t_3)}{t_1}, \grdbang{t_2}, \grdlet{xs}{t_2}, \grdlet{ys}{x_2}, \grdbang{ys}, \grdcon{|Nothing|}{ys}$} [1]]
    [{$\grdbang{x_1}, \grdcon{|Nothing|}{x_1}, \grdlet{zs}{x_2}$} [2]]]
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

\subsection{Checking Guard Trees}

\begin{figure}
\[ \textbf{Operations on $\Theta$} \]
% TODO: Figure out where to move these
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

\caption{Pattern match checking}
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
both in \cref{ssec:extinert} and \sg{TODO: Reference CoreMap/semantic equality
extension, and possibly an extension for linear arithmetic or boolean logic}.


\subsection{Generating Inhabitants of a Refinement Type}
\label{ssec:gen}

\begin{figure}
\centering
\[ \textbf{Generate inhabitants of $\Theta$} \]
\[ \ruleform{ \generate(\Theta) = \mathcal{P}(\PS) } \]
\[
\begin{array}{c}
   \generate(\reft{\Gamma}{\Phi}) = \bigcup \left\{ \expand(\nabla, \mathsf{dom}(\Gamma)) \mid \nabla \in \construct(\ctxt{\Gamma}{\varnothing}, \Phi) \right\}
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

% TODO: Expand currently assumes that there are only positive assignments in
% nabla. But that's not the case! E.g. for
%   data T = A | B | C
%   f A = ()
% The nabla representing the uncovered set will only have the constraint x /~ A.
% Currently, we will print this as _, but we want the two patterns B and C.
% I think we should consider this an implementation detail, but should really write
% about it later on.
\[ \textbf{Expand variables to $\Pat$ with $\nabla$} \]
\[ \ruleform{ \expand(\nabla, \overline{x}) = \mathcal{P}(\PS) } \]
\[
\begin{array}{lcl}

  \expand(\nabla, \epsilon) &=& \{ \epsilon \} \\
  \expand(\ctxt{\Gamma}{\Delta}, x_1 ... x_n) &=& \begin{cases}
    \left\{ (K \; q_1 ... q_m) \, p_2 ... p_n \mid (q_1 ... q_m \, p_2 ... p_n) \in \expand(\ctxt{\Gamma}{\Delta}, y_1 ... y_m x_2 ... x_n) \right\} & \text{if $\rep{\Delta}{x} \termeq \deltaconapp{K}{a}{y} \in \Delta$} \\
    \left\{ \_ \; p_2 ... p_n \mid (p_2 ... p_n) \in \expand(\ctxt{\Gamma}{\Delta}, x_2 ... x_n) \right\} & \text{otherwise} \\
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
pattern vectors. \sg{Currently, $\expand$ will only expand positive constraints
and not produce multiple pattern vectors for a $\nabla$ with negative info (see
the TODO comment attached to $\expand$'s definition)}

But what \emph{is} $\nabla$? To a first approximation, it is a set of mutually
compatible constraints $\delta$ (or a proven incomatibility $\false$ between
them). It is also a unifier to the particular $\Phi$ it is constructed for, in
that the recorded constraints are valid assignments for the variables occuring
in the orginal predicate \sg{This is not true of $\false$, but maybe we can
gloss over that fact?}. Each $\nabla$ is the trace of commitments to a left or
right disjunct in a $\Phi$ \sg{Not sure how to say this more accurately}, which
are checked in isolation. So in contrast to $\Phi$, there is no disjunction in
$\Delta$, which makes it easy to check if a new constraint is compatible with
the existing ones without any backtracking. Another fundamental difference is
that $\delta$ has no binding constructs (so every variable has to be bound in
the $\Gamma$ part of $\nabla$), whereas pattern bindings in $\varphi$ bind
constructor arguments.

$\construct$ is the function that breaks down a $\Phi$ into multiple $\nabla$s.
At the heart of $\construct$ is adding a $\varphi$ literal to the $\nabla$
under construction via $\!\addphi\!$ and filtering out any unsuccessful attempts
(via intercepting the $\false$ failure mode) to do so. Conjunction is handled
by the equivalent of a |concatMap|, whereas a disjunction corresponds to a
plain union.

\sg{$\expand$ undoubtly needs some love, but that's a TODO for later.}
Expanding a $\nabla$ to a pattern vector in $\expand$ is syntactically heavy, but
straightforward: When there is a positive constraint like
$x \termeq |Just y|$ in $\Delta$ for the head $x$ of the variable vector of
interest, expand $y$ in addition to the other variables and wrap it in a |Just|.
Only that it's not plain $x \termeq |Just y|$, but $\Delta(x) \termeq |Just
y|$. That's because $\Delta$ is in \emph{triangular form} (alluding to
\emph{triangular substitutions}, as opposed to an idempotent substitution): We
have to follow $x \termeq y$ constraints in $\Delta$ until we find the
representative of its equality class, to which all constraints apply. Note that
a $x \termeq y$ constraint implies absence of any other constraints mentioning
$x$ in its left-hand side ($x \termeq y \in \Delta \Rightarrow (\Delta\,\cap\,x
= x \termeq y)$, foreshadowing notation from \cref{fig:add}). For $\expand$ to
be well-defined, there needs to be at most one positive constraint in $\Delta$.

\noindent
Thus, constraints within $\nabla$s constructed by $\!\addphi\!$ satisfy a
number of well-formedness constraints:

\begin{enumerate}
  \item[\inert{1}] \emph{Mutual compatibility}: No two constraints in $\nabla$ should
    conflict with each other.
  \item[\inert{2}] \emph{Triangular form}: A $x \termeq y$ constraint implies absence
    of any other constraints mentioning |x| in its left-hand side.
  \item[\inert{3}] \emph{Single solution}: There is at most one positive constraint $x
    \termeq \mathunderscore$ per variable |x|.
\end{enumerate}

We refer to such $\nabla$s as an \emph{inert set}, in the sense that its
constraints are of canonical form and already checked for mutual compatibility,
in analogy to a typechecker's implementation.
\sg{Feel free to flesh out or correct this analogy}

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
    % TODO: This rule can loop indefinitely for GADTs... I believe we do this
    % only one level deep in the implementation and assume that it's inhabited otherwise
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
    % TODO: I'm not sure if we really need the next line. It should be covered
    % by the following case, which will try to instantiate all constructors and
    % see if any is still possible by the x ~ K as gammas ys case
    % \bot & \parbox[t]{0.6\textwidth}{if $\rep{\Delta}{x}:\tau \in \Gamma$ \\ and $\forall K' \in \cons{\ctxt{\Gamma}{\Delta}}{\tau}: \rep{\Delta}{x} \ntermeq K' \in (\Delta,\rep{\Delta}{x} \ntermeq K)$} \\
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
    % TODO: Write the function that adds a Delta to a nabla
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
are nearly at the kernel of our algorithm: \Cref{fig:add} depicts how to add a
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
extension \sg{TODO reference CoreMap} which will expand here. The last case of
$\!\addphi\!$ turns the syntactically and semantically identical subset of
$\varphi$ into $\delta$ and adds that constraint via $\!\adddelta\!$.

Which brings us to the prime unification procedure, $\!\adddelta\!$.
Consider adding a positive constructor constraint like $x \termeq |Just y|$:
The unification procedure will first look for any positive constructor constraint
involving the representative of $x$ with \emph{that same constructor}. Let's say
there is $\Delta(x) = z$ and $z \termeq |Just u| \in \Delta$. Then
$\!\adddelta\!$ decomposes the new constraint just like a classic unification
algorithm, by equating type and term variables with new constraints, \ie $y
\termeq u$. The original constraint, although not conflicting (thus maintaining
wellformed-ness condition \inert{1}), is not added to the inert set because of
\inert{3}.

If there was no positive constructor constraint with the same constructor, it
will look for such a constraint involving a different constructor, like $x
\termeq |Nothing|$. In this case the new constraint is incompatible by
\emph{generativity} of data constructors \cite{eisenberg:dependent}.
\sg{We can also cite injectivity to justify decomposition above, but that would
serve no other purpose than sounding smart?!}
\ryan{Do we even need to cite anything at all here? As far as I understand it,
generativity is a specific property of type constructors with respect to type
inference. In other words, I don't think it applies here. Personally, I would
just say something about |Just|/|Nothing| being a mistmatch and move on.}
\sg{True, but later on in the extensions section we will have Pattern Synonyms
which specifically \emph{lack} generativity (at least without doing any
reasoning about their defn). For example
\begin{code}
pattern P
pattern Q
case P 15 of
  Q _  -> ...
  P 15 ->
\end{code}
The first clause shouldn't be flagged as redundant, because Q and P might have
the same defns. But arguably we could bring that point when we need it in the
extensions section. Or not argue in terms of generativity at all, but it's
quite similar to how type inference works: We discard |x ~ Q y| from the fact
that we know |x ~ P z|, inferring that |x| must be a |P|.}
There are two other ways in which the constraint can be incompatible: If there
was a negative constructor constraint $x \ntermeq |Just|$ or if any of the
fields were not inhabited, which is checked by the $\inhabited{\nabla}{x}$
judgment in \cref{fig:inh}. Otherwise, the constraint is compatible and is
added to $\Delta$.

Adding a negative constructor constraint $x \ntermeq Just$ is quite
similar, as is handling of positive and negative constraints involving $\bot$.
The idea is that whenever we add a negative constraint that doesn't
contradict with positive constraints, we still have to test if there are any
inhabitants left.

\sg{Maybe move down the type constraint case in the definition?}
Adding a type constraint drives this paranoia to a maximum: After calling out
to the type-checker (the logic of which we do not and would not replicate in
this paper or our implementation) to assert that the constraint is consistent
with the inert set, we have to test \emph{all} variables in the domain of
$\Gamma$ for inhabitants, because the new type constraint could have rendered
a type empty. To demonstrate why this is necessary, imagine we have $\ctxt{x :
a}{x \ntermeq \bot}$ and try to add $a \typeeq |Void|$. Although the type
constraint is consistent, $x$ in $\ctxt{x : a}{x \ntermeq \bot, a \typeeq
|Void|}$ is no longer inhabited. There is room for being smart about which
variables we have to re-check: For example, we can exclude variables whose type
is a non-GADT data type. \sg{That trick probably belongs in the implementation
section. Although it's quite boring and ad-hoc.}

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


\subsection{Inhabitation Test}

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

  \quad

  \prooftree
    {x:\tau \in \Gamma \quad \cons{\ctxt{\Gamma}{\Delta}}{\tau} = \bot}
  \justifies
    \inhabited{\ctxt{\Gamma}{\Delta}}{x}
  \using
    \inhabitednocpl
  \endprooftree

  \\
  \\

  % TODO: Maybe inline Inst into this rule?
  \prooftree
    \Shortstack{{x:\tau \in \Gamma \quad K \in \cons{\ctxt{\Gamma}{\Delta}}{\tau}}
                {\inst{\ctxt{\Gamma}{\Delta}}{x}{K} \not= \false}}
  \justifies
    \inhabited{\ctxt{\Gamma}{\Delta}}{x}
  \using
    \inhabitedinst
  \endprooftree

\end{array}
\]

\[ \textbf{Find data constructors of $\tau$} \]
\[ \ruleform{ \cons{\ctxt{\Gamma}{\Delta}}{\tau} = \overline{K}} \]
\[
\begin{array}{c}

  \cons{\ctxt{\Gamma}{\Delta}}{\tau} = \begin{cases}
    \overline{K} & \parbox[t]{0.8\textwidth}{$\tau = T \; \overline{\sigma}$ and $T$ data type with constructors $\overline{K}$ \\ (after normalisation according to the type constraints in $\Delta$)} \\
    % TODO: We'd need a cosntraint like \delta's \false here... Or maybe we
    % just omit this case and accept that the function is partial
    \bot & \text{otherwise} \\
  \end{cases} \\

\end{array}
\]

% This is mkOneConFull
\[ \textbf{Instantiate $x$ to data constructor $K$} \]
\[ \ruleform{ \inst{\nabla}{x}{K} = \nabla } \]
\[
\begin{array}{c}

  \inst{\ctxt{\Gamma}{\Delta}}{x}{K} =
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

\sg{We need to find better subsection titles that clearly distinguish
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


\section{Possible Extensions}



\subsection{Long Distance Information}
\label{ssec:ldi}

\TODO


\subsection{Empty Case}

As can be seen in \cref{fig:srcsyn}, Haskell function definitions need to have
at least one clause. That leads to an awkward situation when pattern matching
on empty data types, like |Void|:
\begin{code}
absurd :: Void -> a
absurd  x    = undefined
absurd (!x)  = undefined
\end{code}

\noindent
\sg{lhs2TeX chokes on wildcards and will format |absurd !x| as infix. Yuck}
Clearly, neither option is satisfactory to implement |absurd|: The first one
would actually return |undefined| when called with $\bot$, thus masking the
original $\bot$ with the error thrown by |undefined|. The second one would
diverge alright, but it is unfortunate that we still have to provide a RHS that
we know will never be entered. In fact, our checking algorithm will mark the
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

\subsection{Identifying Semantically Equivalent Expressions}

\sg{Or just ``View Patterns'' for a catchier title?}
\TODO


\subsection{Pattern Synonyms and \texttt{COMPLETE} Pragmas}

\TODO


\subsection{Literals}

\TODO


\subsection{Newtypes}

\TODO


\subsection{Strictness}

\TODO


\sg{Treat type information as an extension?}


\section{Implementation}

The implementation of our algorithm in GHC accumulates quite a few tricks that
go beyond the pure formalism. This section is dedicated to describing these.

Warning messages need to reference source syntax in order to be comprehensible
by the user. At the same time, completeness checks involving GADTs need a
type-checked program, so the only reasonable phase to run the Pattern match
checker is between type-checking and desugaring to GHC Core, a typed
intermediate representation lacking the connection to source syntax.
We perform pattern match checking in the same tree traversal as desugaring.

\sg{New implementation has 3850 lines, out of which 1753 is code. Previous impl
as of GHC 8.6.5 had 3118 lines, out of which 1438 were code. Not sure how to
sell that.}

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

\caption{Fast pattern match checking}
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

\subsection{Throttling for Graceful Degradation}

Even with the tweaks from \cref{ssec:interleaving}, checking certain pattern
matches remains NP-hard \sg{Cite something here or earlier, bring an example}.
Naturally, there will be cases where we have to conservatively approximate in
order not to slow down compilation too much. After all, pattern match checking
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

\sg{I'm not sure what other hacks we should mention beyond this. I don't think
we want to write about ad-hoc details like 6.2 in GMTM, because they are
specific to how $\Delta$ is represented (solved, canonical type constraints in
particular). That's of limited value for other implementations and not a
conceptual improvement.}

\sg{We could talk about when adding a type constraint, we only need to perform
the inhabitation check on a subset of all variables. Namely those that aren't
obviously of plain old ADT type. But the implementation doesn't currently do
that hack, so it's a bit of a moot point.}

%\listoftodos\relax

%\nocite{*}

\bibliography{references}

\end{document}
