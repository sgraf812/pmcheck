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

% The following lines remove ACM stuff unneeded for prototyping
% https://tex.stackexchange.com/a/346309/52414
\settopmatter{printacmref=false} % Removes citation information below abstract
\renewcommand\footnotetextcopyrightpermission[1]{} % removes footnote with conference information in first column
\pagestyle{plain} % removes running headers

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

% Wildcards
\newcommand\WILD{\mbox{@_@}}

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

\simon{Ryan is going to draft.  Include a list of contributions}

Contributions from our call:
\begin{itemize}
\item Things we do that weren’t done in GADTs meet their match
  \begin{itemize}
    \item Strictness, including bang patterns, data structures with strict fields.
\item 	COMPLETE pragmas
\item	Newtype pattern matching
\item	..anything else?
\item	Less syntactic; robust to mixing pattern guards and syntax pattern matching and view patterns
\end{itemize}

  \item 
Much simpler and more modular formalism (evidence: compare the Figures; separation of desugaring and clause-tree processing, so that it’s easy to add new source-language forms)
\item 	Leading to a simpler, more correct, and much more performant implementation.  (Evidence: GHC’s bug tracker, perf numbers)
\item 	Maybe the first to handle both strict and lazy languages.

\end{itemize}


\section{The problem we want to solve}

\simon{Ryan is going to draft}

\simon{Maybe a Figure with Tricky Examples}


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
\end{array} &
\begin{array}{rcl}
  defn   &\Coloneqq& \overline{clause} \\
  clause &\Coloneqq&  f \; \overline{pat} \; \overline{match} \\
  pat    &\Coloneqq& x \mid K \; \overline{pat} \\
  match  &\Coloneqq& \mathtt{=} \; expr \mid \overline{grhss} \\ % Or: clause?
  grhss  &\Coloneqq& \mathtt{\mid} \; \overline{guard} \; \mathtt{=} \; expr \\
  guard  &\Coloneqq& pat \leftarrow expr \mid expr \mid \mathtt{let} \; x \; \mathtt{=} \; expr \\
\end{array}
\end{array}
\]

\caption{Source syntax}
\label{fig:srcsyn}
\end{figure}

\section{Overview over Our Solution}

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
                  &     &\mid     & \expconapp{K}{\tau}{\sigma}{\gamma}{e} \\ % TODO: We should probably have univ tvs split from ex
                  &     &\mid     & ... \\
\end{array} &
\begin{array}{rlcl}
  n      \in      &\mathbb{N}&    & \\

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
  \delta &\Coloneqq& \gamma \mid x \termeq \deltaconapp{K}{a}{y} \mid x \ntermeq K \mid x \termeq \bot \mid x \ntermeq \bot \mid x \termeq y & \text{Constraints without scoping} \\
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

\begin{figure}
\[
\begin{array}{cc}
  \begin{array}{rcll}
    \vcenter{\hbox{\begin{forest}
      grdtree,
      for tree={delay={edge={-Bar}}},
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

\simon{Add diagram of the main road map here}

\subsection{Desugaring to clause trees}

% TODO: better words
It is customary to define Haskell functions using pattern-matching, possibly
with one or more \emph{guarded right-hand sides} (GRHS) per \emph{clause} (see
\cref{fig:srcsyn}). Consider for example this 3am attempt at lifting equality
over \hs{Maybe}:

% TODO: better code style
\begin{code}
liftEq Nothing  Nothing  = True
liftEq (Just x) (Just y)
  | x == y          = True
  | otherwise       = False
\end{code}
\noindent
This function will crash for the call site |liftEq (Just 1) Nothing|. To see
that, we can follow Haskell's top-to-bottom, left-to-right pattern match
semantics. The first clause fails to match |Just 1| against |Nothing|,
while the second clause successfully matches |1| with |x|, but then fails
trying to match |Nothing| against |Just y|. There is no third clause, and an
\emph{uncovered} value vector that falls out at the bottom of this process
will lead to a crash. \simon{We have not talked about value vectors yet!  Rephrase}

Compare that to matching on |(Just 1) (Just 2)|: While matching against the first 
clause fails, the second matches |x| to |1| and |y| to |2|. Since there are
multiple guarded right-hand sides (GRHSs), each of them in turn has to be tried in
a top-to-bottom fashion. The first GRHS consists of a single
boolean guard (in general we have to consider each of them in a left-to-right
fashion!) \sg{Maybe an example with more guards would be helpful} that will
fail because |1 /= 2|. So the second GRHS is tried successfully, because
|otherwise| is a boolean guard that never fails.

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
Transforming the first clause with its single GRHS easy.
But the second clause already had two GRHSs, so we need to use
\emph{nested} pattern guards.  This is not a feature that Haskell offers (yet),
but it allows a very convenient uniformity for our purposes:
after the successful match on the first two guards
left-to-right, we try to match each of the GRHSs in turn, top-to-bottom (and
their individual guards left-to-right).

% In fact, it seems rather arbitrary to
% only allow one level of nested guards!
Hence our algorithm desugars the source
syntax to the following \emph{guard tree} (see \cref{fig:syn} for the full
syntax and \cref{fig:grphnot} the corresponding graphical notation):

\sg{TODO: Make the connection between textual syntax and graphic representation.}
\sg{The bangs are distracting. Also the otherwise. Also binding the temporary.}

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
the pattern guards in our tree language are not, so we had to insert bang
patterns. \sg{This makes me question again if making pattern guards "lazy" was
the right choice. But I like to keep the logic of bang patterns orthogonal to
pattern guards in our checking function.} For another thing, the pattern guards
in $\Grd$ only scrutinise variables (and only one level deep), so the
comparison in the boolean guard's scrutinee had to be bound to an auxiliary
variable in a let binding.

Pattern guards in $\Grd$ are the only guards that can possibly fail to match,
in which case the value of the scrutinee was not of the shape of the
constructor application it was matched against. The $\Gdt$ tree language
determines how to cope with a failed guard. Left-to-right matching semantics is
captured by $\gdtguard{}{}$, whereas top-to-bottom backtracking is expressed by
sequence ($\gdtseq{}{}$). The leaves in this tree each correspond to a GRHS.
\sg{The preceding and following paragraph would benefit from illustrations.
It's hard to come up with something concrete that doesn't go into too much
detail. GMTM just shows a top-to-bottom pipeline. But why should we leave out
left-to-right composition? Also we produce an annotated syntax tree $\Ant$
instead of a covered set.}

\subsection{Checking Guard Trees}

Pattern match checking works by gradually refining the set of uncovered values
as they flow through the tree and produces two values: The uncovered set that
wasn't covered by any clause and an annotated guard tree skeleton $\Ant$ with
the same shape as the guard tree to check, capturing redundancy and divergence
information. Pattern match checking our guard tree from above should yield 
an empty uncovered set and an annotated guard tree skeleton like

\begin{forest}
  anttree
  [ 
    [{\lightning}
      [1,acc]
      [{\lightning}
        [{\lightning} [2,acc]]
        [3,acc]]]]
\end{forest}

A GRHS is deemed accessible (\checked{}) whenever there's a non-empty set of
values reaching it. For the first GRHS, the set that reaches it looks
like $\{ (mx, my) \mid mx \ntermeq \bot, \grdcon{\mathtt{Nothing}}{mx}, my
\ntermeq \bot, \grdcon{\mathtt{Nothing}}{my} \}$, which is inhabited by
$(\mathtt{Nothing}, \mathtt{Nothing})$. Similarly, we can find inhabitants for
the other two clauses.

A \lightning{} denotes possible divergence in one of the bang patterns and
involves testing the set of reaching values for compatibility with \ie $mx
\termeq \bot$. We don't know for $mx$, $my$ and $t$ (hence insert a
\lightning{}), but can certainly rule out $otherwise \termeq \bot$ simply by
knowing that it is defined as |True|. But since all GRHSs are accessible,
there's nothing to report in terms of redundancy and the \lightning{}
decorators are irrelevant.

Perhaps surprisingly and most importantly, $\Grd$ with its three primitive
guards, combined with left-to-right or top-to-bottom semantics in $\Gdt$, is
expressive enough to express all pattern matching in Haskell (cf. fig.
\sg{TODO: desugaring function})! We have yet to find a language extension that
doesn't fit into this framework.

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

Is the first clause inaccessible or even redundant? Although the match on |()|
forces the argument, we can delete the first clause without changing program
semantics, so clearly it's redundant. But that wouldn't be true if the second
clause wasn't there to "keep alive" the |()| pattern!

Here is the corresponding annotated tree after checking:

\begin{forest}
  anttree
  [ 
    [{\lightning}
      [1,inacc]
      [2,acc]]
    [3,acc]]
\end{forest}

In general, at least one GRHS under a \lightning{} may not be flagged as redundant.
Thus the checking algorithm can't decide which GRHSs are redundant (\vs just
inaccessible) when it reaches a particular GRHS.

\subsection{Testing for Emptiness}

The informal style of pattern match checking above represents the set of values
reaching a particular node of the guard tree as a \emph{refinement type} (which
is the $\Theta$ from \cref{fig:syn}). Each guard encountered in the tree
traversal refines this set with its own constraints.

Apart from generating inhabitants of the final uncovered set for missing
equation warnings, there are two points at which we have to check whether such
a refinement type has become empty: To determine whether a right-hand side is
inaccessible and whether a particular bang pattern may lead to divergence and
requires us to wrap a \lightning{}.

Take the the final uncovered set $\reft{(mx : |Maybe a|, my : |Maybe a|)}{\Phi}$ after checking |liftEq| above
as an example, where the predicate $\Phi$ is:
\sg{This doesn't even pick up the trivially empty clauses ending in $\false$,
but is already qutie complex.}
\[
\begin{array}{cl}
         & (mx \ntermeq \bot \wedge (mx \ntermeq \mathtt{Nothing} \vee (\ctcon{\mathtt{Nothing}}{mx} \wedge my \ntermeq \bot \wedge my \ntermeq \mathtt{Nothing}))) \\
  \wedge & (mx \ntermeq \bot \wedge (mx \ntermeq \mathtt{Just} \vee (\ctcon{\mathtt{Just}\;x}{mx} \wedge my \ntermeq \bot \wedge (my \ntermeq \mathtt{Just})))) \\
\end{array}
\]

A bit of eyeballing |liftEq|'s definition finds |Nothing (Just _)| as an
uncovered pattern, but eyeballing the constraint formula above seems impossible
in comparison. A more systematic approach is to adopt a generate-and-test
scheme: Enumerate possible values of the data types for each variable involved
(the pattern variables |mx| and |my|, but also possibly the guard-bound |x|,
|y| and |t|) and test them for compatibility with the recorded constraints.

Starting from |mx my|, we enumerate all possibilities for the shape of |mx|,
and similarly for |my|. The obvious first candidate in a lazy language is
$\bot$! But that is a contradicting assignment for both |mx| and |my|
indepedently. Refining to |Nothing Nothing| contradicts with the left part
of the top-level $\wedge$. Trying |Just y| (|y| fresh) instead as the shape for
|my| yields our first inhabitant! Note that |y| is unconstrained, so $\bot$ is
a trivial inhabitant. Similarly for |(Just _) Nothing| and |(Just _) (Just _)|.

Why do we have to test guard-bound variables in addition to the pattern
variables? It's because of empty data types and strict fields:
\sg{This example will probably move to an earlier section}

\begin{code}
data Void -- No data constructors
data SMaybe a = SJust !a | SNothing
v :: SMaybe Void -> Int
v x@SNothing = 0
\end{code}

|v| does not have any uncovered patterns. And our approach better should see that
by looking at its uncovered set
$\reft{x : |Maybe Void|}{x \ntermeq \bot \wedge x \ntermeq \mathtt{Nothing}}$.

Specifically, the candidate |SJust y| (for fresh |y|) for |x| should be rejected,
because there is no inhabitant for |y|! $\bot$ is ruled out by the strict field
and |Void| means there is no data constructor to instantiate. Hence it is
important to test guard-bound variables for inhabitants, too.

\sg{GMTM goes into detail about type constraints, term constraints and
worst-case complexity here. That feels a bit out of place.}

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
\unc(\Theta, \gdtguard{(\grdlet{x}{e})}{t}) &=& \unc(\Theta \andtheta (x \termeq e), t) \\
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
\ann(\Theta, \gdtguard{(\grdlet{x}{e})}{t}) &=& \ann(\Theta \andtheta (x \termeq e), t) \\
\ann(\Theta, \gdtguard{(\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{t}) &=& \ann(\Theta \andtheta (\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}), t) \\
\end{array}
\]

\[ \textbf{Putting it all together} \]
  \begin{enumerate}
    \item[(0)] Input: Context with match vars $\Gamma$ and desugared $\Gdt$ $t$
    \item Report $n$ pattern vectors of $\generate(\unc(\reft{\Gamma}{\true}, t))$ as uncovered
    \item Report the collected redundant and not-redundant-but-inaccessible clauses in $\ann(\reft{\Gamma}{\true}, t)$ (TODO: Write a function that collects the RHSs).
  \end{enumerate}

\caption{Pattern-match checking}
\label{fig:check}
\end{figure}

\section{Formalism}

The previous section gave insights into how we represent pattern match checking
problems as clause trees and provided an intuition for how to check them for
exhaustiveness and redundancy. This section formalises these intuitions in
terms of the syntax (\cf \cref{fig:syn}) we introduced earlier.

As in the previous section, this comes in two main parts: Pattern match
checking and finding inhabitants of the arising refinement types.
\sg{Maybe we'll split that last part in two: 1. Converting $\Theta$ into a
bunch of inhabited $\nabla$s 2. Make sure that each $\nabla$ is inhabited.}

\subsection{Desugaring to Guard Trees}

\simon{Write a desugaring function (in a Figure) and describe it here.
  Give one example that illustrates; e.g. the one from my talk.}

\subsection{Checking Guard Trees}

\Cref{fig:check} shows the two main functions for checking guard trees. $\unc$
carries out exhaustiveness checking by computing the set of uncovered values
for a particular guard tree, whereas $\ann$ computes the corresponding
annotated tree, capturing redundancy information.

Both functions take as input the set of values \emph{reaching} the particular
guard tree node passed in as second parameter. The definition of $\unc$ follows
the intuition we built up earlier: It refines the set of reaching values as a
subset of it falls through from one clause to the next. This is most visible in
the $\gdtseq{}{}$ case (top-to-bottom composition), where the set of values
reaching the right (or bottom) child is exactly the set of values that were
uncovered by the left (or top) child on the set of values reaching the whole
node. A GRHS covers every reaching value. The left-to-right semantics of
$\gdtguard{}{}$ are respected by refining the set of values reaching the
wrapped subtree, depending on the particular guard. Bang patterns and let
bindings don't do anything beyond that refinement, whereas pattern guards
additionally account for the possibility of a failed pattern match. Note that
ultimately, a failing pattern guard is the only way in which the uncovered set
can become non-empty!

When $\ann$ hits a GRHS, it asks $\generate$ for inhabitants of $\Theta$
to decide whether the GRHS is accessible or not. Since $\ann$ needs to compute
and maintain the set of reaching values just the same as $\unc$, it has to call
out to $\unc$ for the $\gdtseq{}{}$ case. Out of the three guard cases, the one
handling bang patterns is the only one doing more than just refining the set of
reaching values for the subtree (thus respecting left-to-right semantics). A
bang pattern $\grdbang{x}$ is handled by testing whether the set of reaching
values $\Theta$ is compatible with the assignment $x \termeq \bot$, which again
is done by asking $\generate$ for concrete inhabitants of the resulting
refinement type. If it \emph{is} inhabited, then the bang pattern might diverge
and we need to wrap the annotated subtree in a \lightning{}.

Pattern guard semantics are important for $\unc$ and bang pattern semantics are
important for $\ann$. But what about let bindings? They are in fact completely
uninteresting to the checking process, but making sense of them is important
for the precision of the emptiness check involving $\generate$, as we'll see
later on \sg{TODO: cref}.

\subsection{Testing for Emptiness}

\sg{Maybe the this paragraph should somewhere else, possibly earlier.}
The predicate literals $\varphi$ of refinement types looks quite similar to the
original $\Grd$ language, so how is checking them for emptiness an improvement
over reasoning about about guard trees directly? To appreciate the translation
step we just described, it is important to realise that semantics of $\Grd$s
are \emph{highly non-local}! Left-to-right and top-to-bottom match semantics
means that it's hard to view $\Grd$s in isolation, we always have to reason
about whole $\Gdt$s. By contrast, refinement types are self-contained, which
means the emptiness test can be treated in separation from the whole pattern
match checking problem.

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
in the orginal predicate \sg{This is not true of $\false$}. Each $\nabla$ is
the trace of commitments to a left or right disjunct in a $\Phi$ \sg{Not sure
how to say this more accurately}, which are checked in isolation. So in
contrast to $\Phi$, there is no disjunction in $\Delta$. Which makes it easy to
check if a new constraint is compatible with the existing ones without any
backtracking.

$\construct$ is the function that breaks down a $\Phi$ into multiple $\nabla$s.
At the heart of $\construct$ is adding a $\varphi$ literal to the $\nabla$
under construction via $\!\addphi\!$ and filtering out any unsuccessful attempts
($\false$) to do so. Conjunction is handled by the equivalent of a
|concatMap|, whereas a disjunction corresponds to a plain union.

Expanding a $\nabla$ to a pattern vector in $\expand$ is syntactically heavy, but
straightforward: When there is a positive constraint like 
$x \termeq |Just y|$ in $\Delta$ for the head $x$ of the variable vector of
interest, expand $y$ in addition to the other variables and wrap it in a |Just|.
Only that it's not plain $x \termeq |Just y|$, but $\Delta(x) \termeq |Just
y|$. That's because $\Delta$ is in \emph{triangular form} (alluding to
\emph{triangular substitutions} \sg{TODO cite something}): We have to follow $x
\termeq y$ constraints in $\Delta$ until we find the representative of its
equality class, to which all constraints apply. Note that a $x \termeq y$
constraint implies absence of any other constraints mentioning $x$ in its
left-hand side
($x \termeq y \in \Delta \Rightarrow (\Delta\,\cap\,x = x \termeq y)$,
foreshadowing notation from \cref{fig:add}). For $\expand$ to be well-defined,
there needs to be at most one positive constraint in $\Delta$.

Thus, constraints within $\nabla$s constructed by $\!\addphi\!$ satisfy a
number of well-formedness constraints, like mutual compatibility, triangular
form and the fact that there is at most one positive constraint $x \termeq
\mathunderscore$ per variable $x$. We refer to such $\nabla$s as an \emph{inert
set}, in the sense that constraints inside it satisfy it are of canonical form
and already checked for mutual compatibility, in analogy to a typechecker's
implementation \sg{Feel free to flesh out or correct this analogy}.

\subsection{Extending the inert set}



\begin{figure}[t]
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










\begin{figure}[t]
\centering
\[ \textbf{Add a formula literal to the inert set} \]
\[ \ruleform{ \nabla \addphi \varphi = \nabla } \]
\[
\begin{array}{r@@{\,}c@@{\,}lcl}

  \nabla &\addphi& \false &=& \false \\
  \nabla &\addphi& \true &=& \nabla \\
  \ctxt{\Gamma}{\Delta} &\addphi& \ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x} &=&
    \ctxt{\Gamma,\overline{a},\overline{y:\tau}}{\Delta} \adddelta \overline{\gamma} \adddelta x \termeq \deltaconapp{K}{a}{y} \\
  % TODO: Really ugly to mix between adding a delta, a phi and then a delta again. But whatever
  \ctxt{\Gamma}{\Delta} &\addphi& \ctlet{x}{\expconapp{K}{\tau'}{\tau}{\gamma}{e}} &=& \ctxt{\Gamma,\overline{a},\overline{y:\sigma}}{\Delta} \addphi \ctcon{\genconapp{K}{a}{\gamma}{y}}{x} \adddelta \overline{a \typeeq \tau} \addphi \overline{\ctlet{y}{e}} \text{ where $\overline{a} \# \Gamma$, $\overline{y} \# \Gamma$, $\overline{e:\sigma}$} \\ 
  \nabla &\addphi& \ctlet{x}{e} &=& \nabla \\
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
    \ctxt{\Gamma'}{(\Delta',\rep{\Delta}{x} \termeq \deltaconapp{K}{a}{y})} & \parbox[t]{0.6\textwidth}{where $\ctxt{\Gamma'}{\Delta'} = \ctxt{\Gamma}{\Delta} \adddelta \overline{\gamma} $ \\ and $\rep{\Delta'}{x} \ntermeq K \not\in \Delta'$ and $\overline{\inhabited{\ctxt{\Gamma'}{\Delta'}}{y}}$} \\
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
    \bot & \text{if $\rep{\Delta}{x} \ntermeq \bot \in \Delta$} \\
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
    \ctxt{\Gamma}{(\Delta, \rep{\Delta}{x} \termeq \rep{\Delta}{y})} \adddelta ((\Delta \cap \rep{\Delta}{x})[\rep{\Delta}{y} / \rep{\Delta}{x}]) & \text{otherwise} \\
  \end{cases} \\

\end{array}
\]


\[ \ruleform{ \Delta \cap x = \Delta } \]
\[
\begin{array}{lcl}
  \varnothing \cap x &=& \varnothing \\
  (\Delta,x \termeq \deltaconapp{K}{a}{y}) \cap x &=& (\Delta \cap x), x \termeq \deltaconapp{K}{a}{y} \\
  (\Delta,x \ntermeq K) \cap x &=& (\Delta \cap x), x \ntermeq K \\
  (\Delta,x \termeq \bot) \cap x &=& (\Delta \cap x), x \termeq \bot \\
  (\Delta,x \ntermeq \bot) \cap x &=& (\Delta \cap x), x \ntermeq \bot \\
  (\Delta,\varphi) \cap x &=& \Delta \cap x \\
\end{array}
\]

\caption{Adding a constraint to the inert set $\nabla$}
\label{fig:add}
\end{figure}

\begin{figure}[t]
\centering
\[ \textbf{Test if $x$ is inhabited considering $\nabla$} \]
\[ \ruleform{ \inhabited{\nabla}{x} } \]
\[
\begin{array}{c}

  \prooftree
    (\ctxt{\Gamma}{\Phi} \adddelta x \termeq \bot) \not= \false
  \justifies
    \inhabited{\ctxt{\Gamma}{\Phi}}{x}
  \endprooftree

  \quad

  \prooftree
    \Shortstack{{x:\tau \in \Gamma \quad K \in \cons{\ctxt{\Gamma}{\Phi}}{\tau}}
                {\inst{\Gamma}{x}{K} = \overline{\varphi}}
               {(\ctxt{\Gamma,\overline{y:\tau'}}{\Phi} \adddelta \overline{\varphi}) \not= \false}}
  \justifies
    \inhabited{\ctxt{\Gamma}{\Phi}}{x}
  \endprooftree

  \\
  \\

  \prooftree
    {x:\tau \in \Gamma \quad \cons{\ctxt{\Gamma}{\Phi}}{\tau} = \bot}
  \justifies
    \inhabited{\ctxt{\Gamma}{\Phi}}{x}
  \endprooftree

  \quad

  \prooftree
    \Shortstack{{x:\tau \in \Gamma \quad K \in \cons{\ctxt{\Gamma}{\Phi}}{\tau}}
                {\inst{\Gamma}{x}{K} = \bot}}
  \justifies
    \inhabited{\ctxt{\Gamma}{\Phi}}{x}
  \endprooftree

\end{array}
\]

\[ \textbf{Find data constructors of $\tau$} \]
\[ \ruleform{ \cons{\ctxt{\Gamma}{\Phi}}{\tau} = \overline{K}} \]
\[
\begin{array}{c}

  \cons{\ctxt{\Gamma}{\Phi}}{\tau} = \begin{cases}
    \overline{K} & \parbox[t]{0.8\textwidth}{$\tau = T \; \overline{\sigma}$ and $T$ data type with constructors $\overline{K}$ \\ (after normalisation according to the type constraints in $\Phi$)} \\
    % TODO: We'd need a cosntraint like \delta's \false here... Or maybe we
    % just omit this case and accept that the function is partial
    \bot & \text{otherwise} \\
  \end{cases} \\

\end{array}
\]

% This is mkOneConFull
\[ \textbf{Instantiate $x$ to data constructor $K$} \]
\[ \ruleform{ \inst{\Gamma}{x}{K} = \overline{\varphi} } \]
\[
\begin{array}{c}

  \inst{\Gamma}{x}{K} = \begin{cases}
    \tau_x \typeeq \tau, \overline{\gamma}, x \termeq \deltaconapp{K}{a}{y}, \overline{y' \ntermeq \bot} & \parbox[t]{0.8\textwidth}{$K : \forall \overline{a}. \overline{\gamma} \Rightarrow \overline{\sigma} \rightarrow \tau$, $\overline{y} \# \Gamma$, $\overline{a} \# \Gamma$, $x:\tau_x \in \Gamma$, $\overline{y'}$ bind strict fields} \\
    % TODO: We'd need a cosntraint like \delta's \false here... Or maybe we
    % just omit this case and accept that the function is partial
    \bot & \text{otherwise} \\
  \end{cases} \\

\end{array}
\]

\caption{Inhabitance test}
\end{figure}




\section{End to end example}

\sg{This section is completely out of date and goes into so much detail that it
is barely comprehensible. I think we might be able to recycle some of the
examples later on.}

We'll start from the following source Haskell program and see how each of the steps (translation to guard trees, checking guard trees and ultimately generating inhabitants of the occurring $\Delta$s) work.

\begin{code}
f :: Maybe Int -> Int
f Nothing          = 0  -- RHS 1
f x | Just y <- x  = y  -- RHS 2
\end{code} 

\subsection{Translation to guard trees}

The program (by a function we probably only give in the appendix?) corresponds to the following guard tree $t_{\mathtt{f}}$:
\[
\begin{array}{c}
  \gdtseq{\gdtguard{(\grdbang{x})}{\gdtguard{(\grdcon{\mathtt{Nothing}}{x})}{\gdtrhs{1}}}}{\\ \gdtguard{(\grdbang{x})}{\gdtguard{(\grdcon{\mathtt{Just} \; y}{x})}{\gdtrhs{2}}}}
\end{array}
\]

Data constructor matches are strict, so we add a bang for each match.

\subsection{Checking}

\subsubsection{Uncovered values}

First compute the uncovered $\Delta$s, after the first and the second clause respectively.

\begin{enumerate}
  \item \[
      \begin{array}{lcl}
        \Delta_1 &:=& \unc{\gdtguard{(\grdbang{x})}{\gdtguard{(\grdcon{\mathtt{Nothing}}{x})}{\gdtrhs{1}}}} \\
                 &= & x \ntermeq \bot \wedge (x \ntermeq \mathtt{Nothing} \vee \false)
      \end{array}
    \]
  \item \[
      \begin{array}{lcl}
        \Delta_2 &:=& \unc{t_{\mathtt{f}}} = \Delta_1 \wedge x \ntermeq \bot \wedge (x \ntermeq \mathtt{Just} \vee \false)
      \end{array}
    \]
\end{enumerate}

The right operands of $\vee$ are vacuous, but the purely syntactical transformation doesn't see that. 

We can see that $\Delta_2$ is in fact uninhabited, because the three
constraints $x \ntermeq \bot$, $x \ntermeq \mathtt{Nothing}$ and $x \ntermeq
\mathtt{Just}$ cover all possible data constructors of the \texttt{Maybe} data
type. And indeed $\generate{x:\texttt{Maybe Int}}{\Delta_2} = \emptyset$, as we'll see later.

\subsubsection{Redundancy}

In order to compute the annotated clause tree $\ann{\true}{t_{\mathtt{f}}}$, we
need to perform the following four inhabitance checks, one for each bang (for
knowing whether we need to wrap a $\antdiv{}$ and one for each RHS (where we
have to decide for $\antred{}$ or $\antrhs{}$):

\begin{enumerate}
  \item The first divergence check: $\Delta_3 := \true \wedge x \termeq \bot$
  \item Upon reaching the first RHS: $\Delta_4 := \true \wedge x \ntermeq \bot \wedge \ctcon{\mathtt{Nothing}}{x}$
  \item The second divergence check: $\Delta_5 := \true \wedge \Delta_1 \wedge x \termeq \bot$
  \item Upon reaching the second RHS: $\Delta_6 := \true \wedge \Delta_1 \wedge x \ntermeq \bot \wedge \ctcon{\mathtt{Just} \; y}{x}$ \end{enumerate}

Except for $\Delta_5$, these are all inhabited, i.e.
$\generate{x:\texttt{Maybe Int}}{\Delta_i} \not= \emptyset$ (as we'll see in the next
section).

Thus, we will get the following annotated tree:
\[
  \antseq{\antdiv{\antrhs{1}}}{\antrhs{2}}
\]

\subsection{Generating inhabitants}

The last section left open how $\generate$ works, which was used to
establish or refute vacuosity of a $\Delta$.

$\generate$ proceeds in two steps: First it constructs zero, one or many
\emph{inert sets} $\nabla$ with $\construct$ (each of them representing a
set of mutually compatible constraints) and then expands each of the returned
inert sets into one or more pattern vectors $\overline{p}$ with $\expand$,
which is the preferred representation to show to the user.

The interesting bit happens in $\construct$, where a $\Delta$ is basically
transformed into disjunctive normal form, represented by a set of independently
inhabited $\nabla$. This ultimately happens in the base case of
$\construct$, by gradually adding individual constraints to the incoming
inert set with $\adddelta{}{}$, which starts out empty in $\generate$.
Conjunction is handled by performing the equivalent of a \hs{concatMap},
whereas disjunction simply translates to set union.

Let's see how that works for $\Delta_3$ above. Recall that 
$\Gamma = x:\texttt{Maybe Int}$ and $\Delta_3 = \true \wedge x \termeq \bot$:

\[
  \begin{array}{ll}
    & \construct(\Gamma, \true \wedge x \termeq \bot) \\
  = & \quad \{ \text{ Conjunction } \} \\
    & \bigcup \left\{ \construct(\ctxt{\Gamma'}{\nabla'}, x \termeq \bot) \mid \ctxt{\Gamma'}{\nabla'} \in \construct(\ctxt{\Gamma}{\varnothing}, \true) \right\} \\
  = & \quad \{ \text{ Single constraint } \} \\
    & \begin{cases}
        \construct(\ctxt{\Gamma'}{\nabla'}, x \termeq \bot) & \text{where $\ctxt{\Gamma'}{\nabla'} = \adddelta{\ctxt{\Gamma}{\varnothing}}{\true}$} \\
        \emptyset & \text{otherwise} \\
    \end{cases} \\
  = & \quad \{ \text{ $\true$ case of $\adddelta{}{}$ } \} \\
    & \construct(\ctxt{\Gamma}{\varnothing}, x \termeq \bot) \\
  = & \quad \{ \text{ Single constraint } \} \\
    & \begin{cases}
        \{ \ctxt{\Gamma'}{\nabla'} \} & \text{where $\ctxt{\Gamma'}{\nabla'} = \adddelta{\ctxt{\Gamma}{\varnothing}}{x \termeq \bot}$} \\
        \emptyset & \text{otherwise} \\
    \end{cases} \\
  = & \quad \{ \text{ $x \termeq \bot$ case of $\adddelta{}{}$ } \} \\
    & \{ \ctxt{\Gamma}{x \termeq \bot} \}
  \end{array}
\]

Let's start with $\generate{\Gamma}{\Delta_3}$, where
$\Gamma = x:\texttt{Maybe Int}$ and recall that
$\Delta_3 = \true \wedge x \termeq \bot$. The first constraint $\true$ is added
very easily to the initial nabla by discarding it, the second one ($x
\termeq \bot$) is not conflicting with any $x \ntermeq \bot$ constraint in the
incoming, still empty ($\varnothing$) nabla, so we end up with
$\ctxt{\Gamma}{x \termeq \bot}$ as proof that $\Delta_3$ is in fact inhabited.
Indeed, $\expand(\ctxt{\Gamma}{x \termeq \bot}, x)$ generate $\_$ as the
inhabitant (which is rather unhelpful, but correct).

The result of $\generate{\Gamma}{\Delta_3}$ is thus $\{\_\}$, which is not
empty. Thus, $\ann{\Delta}{t}$ will wrap a $\antdiv{}$ around the first RHS.

Similarly, $\generate{\Gamma}{\Delta_4}$ needs
$\construct(\ctxt{\Gamma}{\varnothing}, \Delta_4)$, which in turn will add $x
\ntermeq \bot$ to an initially empty $\nabla$. That entails an inhabitance
check to see if $x$ might take on any values besides $\bot$.

This is one possible derivation of the $\inhabited{\ctxt{\Gamma}{x \ntermeq \bot}}{x}$ predicate:
\[
  \begin{array}{c}

  \prooftree
    \Shortstack{{x:\texttt{Maybe Int} \in \Gamma \quad \mathtt{Nothing} \in \cons{\ctxt{\Gamma}{x \ntermeq \bot}}{\texttt{Maybe Int}}}
                {\inst{\Gamma}{x}{\mathtt{Nothing}} = \ctcon{\mathtt{Nothing}}{x}}
               {(\adddelta{\ctxt{\Gamma}{x \ntermeq \bot}}{\ctcon{\mathtt{Nothing}}{x}}) \not= \bot}}
  \justifies
    \inhabited{\ctxt{\Gamma}{x \ntermeq \bot}}{x}
  \endprooftree

  \end{array}
\]

The subgoal $\adddelta{\ctxt{\Gamma}{x \ntermeq \bot}}{\ctcon{\mathtt{Nothing}}{x}}$
is handled by the second case of the match on constructor pattern constraints,
because there are no other constructor pattern constraints yet in the incoming
$\nabla$. Since there are no type constraints carried by \texttt{Nothing}, no
fields and no constraints of the form $x \ntermeq K$ in $\nabla$, we end up
with $\ctxt{\Gamma}{x \ntermeq \bot, \ctcon{\mathtt{Nothing}}{x}}$. Which is
not $\bot$, thus we conclude our proof of
$\inhabited{\ctxt{\Gamma}{x \ntermeq \bot}}{x}$.

Next, we have to add $\ctcon{\mathtt{Nothing}}{x}$ to our $\nabla = x \ntermeq \bot$,
which amounts to computing
$\adddelta{\ctxt{\Gamma}{x \ntermeq \bot}}{\ctcon{\mathtt{Nothing}}{x}}$.
Conveniently, we just did that! So the result of
$\construct(\ctxt{\Gamma}{\varnothing}, \Delta_4)$ is
$\ctxt{\Gamma}{x \ntermeq \bot, \ctcon{\mathtt{Nothing}}{x}}$.

Now, we see that
$\expand(\ctxt{\Gamma}{(x \ntermeq \bot, \ctcon{\mathtt{Nothing}}{x})}, x) = \{\mathtt{Nothing}\}$,
which is also the result of $\generate{\Gamma}{\Delta_4}$.

The checks for $\Delta_5$ and $\Delta_6$ are quite similar, only that we start
from $\construct(\ctxt{\Gamma}{\varnothing}, \Delta_1)$ (which occur
syntactically in $\Delta_5$ and $\Delta_6$) as the initial $\nabla$. So, we
first compute that.

Fast forward to computing $\adddelta{\ctxt{\Gamma}{x \ntermeq \bot}}{x \ntermeq \mathtt{Nothing}}$.
Ultimately, this entails a proof of
$\inhabited{\ctxt{\Gamma}{x \ntermeq \bot, x \ntermeq \mathtt{Nothing}}}{x}$, for which we need to instantiate the \texttt{Just} constructor:
\[
  \begin{array}{c}

  \prooftree
    \Shortstack{{x:\texttt{Maybe Int} \in \Gamma \quad \mathtt{Just} \in \cons{\ctxt{\Gamma}{(x \ntermeq \bot, x \ntermeq \mathtt{Nothing})}}{\texttt{Maybe Int}}}
                {\inst{\Gamma}{x}{\mathtt{Just}} = \ctcon{\mathtt{Just} \; y}{x}}
               {(\adddelta{\ctxt{\Gamma,y:\mathtt{Int}}{(x \ntermeq \bot, x \ntermeq \mathtt{Nothing})}}{\ctcon{\mathtt{Just} \; y}{x}}) \not= \bot}}
  \justifies
    \inhabited{\ctxt{\Gamma}{x \ntermeq \bot, x \ntermeq \mathtt{Nothing}}}{x}
  \endprooftree

  \end{array}
\]

$\adddelta{\ctxt{\Gamma,y:\mathtt{Int}}{(x \ntermeq \bot, x \ntermeq \mathtt{Nothing})}}{\ctcon{\mathtt{Just} \; y}{x}})$
is in fact not $\bot$, which is enough to conclude
$\inhabited{\ctxt{\Gamma}{x \ntermeq \bot, x \ntermeq \mathtt{Nothing}}}{x}$.

The second operand of $\vee$ in $\Delta_1$ is similar, but ultimately ends in
$\false$, so will never produce a $\nabla$, so
$\construct(\ctxt{\Gamma}{\varnothing}, \Delta_1) = \ctxt{\Gamma}{x \ntermeq \bot, x \ntermeq \mathtt{Nothing}}$.

$\construct{\ctxt{\Gamma}{\varnothing}}{\Delta_5}$ will then just add
$x \termeq \bot$ to that $\nabla$, which immediately refutes with
$x \ntermeq \bot$. So no $\antdiv{}$ around the second RHS.

$\construct(\ctxt{\Gamma}{\varnothing}, \Delta_6)$ is very similar to the
situation with $\Delta_4$, just with more (non-conflicting) constraints in the
incoming $\nabla$ and with $\ctcon{\mathtt{Just}\;y}{x}$ instead of
$\ctcon{\mathtt{Nothing}}{x}$. Thus, $\generate{\Gamma}{\Delta_6} = \{\mathtt{Just}\; \_\}$.

The last bit concerns $\generate{\Gamma}{\Delta_2}$, which is empty because we
ultimately would add $x \ntermeq \mathtt{Just}$ to the inert set
$x \ntermeq \bot, x \ntermeq \mathtt{Nothing}$, which refutes by the second
case of $\adddelta{\_}{\_}$. (The $\vee$ operand with $\false$ in it is empty,
as usual).

So we have $\generate{\Gamma}{\Delta_2} = \emptyset$ and the pattern-match is
exhaustive.

The result of $\ann{\Gamma}{t}$ is thus $\antseq{\antdiv{\antrhs{1}}}{\antrhs{2}}$.

%\listoftodos\relax

\nocite{*}

%\bibliography{references}

\end{document}
