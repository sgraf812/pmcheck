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
%\usepackage{graphicx}
\usepackage{todonotes}
\usepackage{mathtools} % loads amsmath too  % for matrices
\usepackage{hhline}    % for custom lines in matrices
\usepackage{verbatim}  % for multiline comments
\usepackage{wasysym}   % for \checked
\usepackage{amssymb}   % for beautiful empty set
\usepackage{paralist}  % For inlined lists

\usepackage{prooftree} % For derivation trees
\usepackage{stackengine} % For linebraks in derivation tree premises
\stackMath

\PassOptionsToPackage{table}{xcolor} % for highlight
\usepackage{pgf}
\usepackage[T1]{fontenc}   % for textsc in headings

% For strange matrices
\usepackage{array}
\usepackage{multirow}
\usepackage{multicol}

\usepackage{xspace} % We need this for OutsideIn(X)X
%%%%%%%

\usepackage{float}
\floatstyle{boxed}
\restylefloat{figure}
\usepackage[all,cmtip]{xy}

% To balance the last page
\usepackage{flushend}

% Theorems
\usepackage{amsthm}
\newtheorem{theorem}{Theorem}

\usepackage{hyperref}
\usepackage{cleveref}

\input{macros}

% Wildcards
\newcommand\WILD{\mbox{@_@}}

\usepackage[labelfont=bf]{caption}

\usepackage{mathrsfs}

\clubpenalty = 10000
\widowpenalty = 10000
\displaywidowpenalty = 10000

% Tables should have the caption above
\floatstyle{plaintop}
\restylefloat{table}
% \usepackage{caption}
% \DeclareCaptionFormat{myformat}{#1#2#3\hrulefill}
% \captionsetup[table]{format=myformat}

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

\begin{figure}[t]
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

\section{Our Solution}

% TODO:
% Clarify nomenclature: Clause vs. (guarded) RHS
% syntax from language report:
%   f p11 … p1k match1
% and each match has multiple guarded RHSs. The report seems to call the above a clause:
%   "Note that all clauses defining a function must be contiguous, and the number of patterns in each clause must be the same."
% We *could* treat multiple GRHSs as a language extension, but I don't see the point.
% TODO: better words
It is customary to define Haskell functions using pattern-matching, possibly
with one or more \emph{guarded right-hand sides} (GRHS) per \emph{clause} (see
\cref{fig:srcsyn}). Consider for example this 3 AM attempt at lifting equality
over \hs{Maybe}:

% TODO: better code style
\begin{code}
f Nothing  Nothing  = True
f (Just x) (Just y)
  | x == y          = True
  | otherwise       = False
\end{code}

This function will crash for the call site |f (Just 1) Nothing|. To see that,
we can follow Haskell's top-to-bottom, left-to-right pattern match semantics.
The first clause already fails to match |Nothing| against |Just 1|, while the
second clause successfully matches |x| with |1|, but then fails trying to
match |Just y| against |Nothing|. There is no third clause, and an
\emph{uncovered} value vector that falls out at the bottom of this process will
lead to a crash.

Compare that to matching on |(Just 1) (Just 2)|: While matching against the first 
clause fails, the second matches |x| to |1| and |y| to |2|. Since there are
multiple guarded right-hand sides, every one of them in turn has to be tried in
a top-to-bottom fashion. The first GRHS consists of a single
boolean guard (in general we have to consider each of them in a left-to-right
fashion!) \sg{Maybe an example with more guards would be helpful} that will
fail because |1 /= 2|. So the second GRHS is tried successfully, because
|otherwise| is a boolean guard that never fails.

Note how both the pattern matching per clause and the guard checking within a
syntactic $match$ share top-to-bottom and left-to-right semantics. Having to
make sense of both pattern and guard semantics seems like a waste of energy.
Why can't we just express all pattern matching simply by pattern guards on an
auxiliary variable match? See for yourself:

\begin{code}
f mx my
  | Nothing <- mx, Nothing <- my              = True
  | Just x <- mx,  Just y <- my  | x == y     = True
                                 | otherwise  = False
\end{code}

Transforming the first clause with its single GRHS was quite successful.
But the second clause already had two GRHSs before, and the resulting tree-like
nesting of guards definitely is not valid Haskell! Although intuitively, this
is just what we want: After the successful match on the first two guards
left-to-right, we try to match each of the GRHSs in turn, top-to-bottom (and
their individual guards left-to-right). In fact, it seems rather arbitrary to
only allow one level of nested guards! Hence our algorithm desugars the source
syntax to the following \emph{guard tree} (see \cref{fig:syn} for the full
syntax):

\sg{Find shorter aliases for the syntax, maybe make top-to-bottom sequence prefix. Or a more graphic representation, even. Will sketch it out when we have some prose to work on. For now assume that Guard binds stronger than sequence (;)}
\sg{The bangs are distracting. Also the otherwise. Also binding the temporary.}

\[
\begin{array}{l}
  \gdtseq{\gdtguard{(\grdbang{mx})}{\gdtguard{(\grdcon{\mathtt{Nothing}}{mx})}{\gdtguard{(\grdbang{my})}{\gdtguard{(\grdcon{\mathtt{Nothing}}{my})}{\gdtrhs{1}}}}}}{}\\
  \gdtguard{(\grdbang{mx})}{\gdtguard{(\grdcon{\mathtt{Just}\;x}{mx})}{\gdtguard{(\grdbang{my})}{\gdtguard{(\grdcon{\mathtt{Just}\;y}{my})}{\\ (\gdtseq{\gdtguard{(\grdlet{t}{|x == y|})}{\gdtguard{(\grdbang{t})}{\gdtguard{(\grdcon{\mathtt{True}}{t})}{\gdtrhs{2}}}}}{\\ \gdtguard{(\grdbang{otherwise})}{\gdtguard{(\grdcon{\mathtt{True}}{otherwise})}{\gdtrhs{3}}}})}}}}\\
  
\end{array}
\]

This representation is quite a bit more explicit than the original program. For
one thing, every source-level pattern guard is strict in its scrutinee, whereas
the pattern guards in our tree language don't have that semantics, so we had to
insert bang patterns. \sg{This makes me question again if that was the right
choice. But I like to keep the logic of bang patterns orthogonal to pattern
guards in our checking function.} For another thing, the pattern guards in
$\Grd$ only scrutinise variables (and only one level deep), so the comparison
in the boolean guard's scrutinee had to be bound to an auxiliary variable in a
let binding.

Pattern guards in $\Grd$ are the only guards that can possibly fail to match,
in which case the value of the scrutinee was not of the shape of the
constructor application it was matched against. The $\Gdt$ tree language
determines how to cope with a failed guard. Left-to-right matching semantics is
captured by $\gdtguard{}{}$, whereas top-to-bottom backtracking is expressed by
sequence ($\gdtseq{}{}$). The leaves in this tree, $\gdtrhs{}$, each correspond
to a GRHS.

Perhaps surprisingly and most importantly, $\Grd$ with its three primitive
guards, combined with left-to-right or top-to-bottom semantics in $\Gdt$ is
expressive enough to express all pattern matching in the original program!  
We have yet to find a language extension that doesn't fit into this framework.

\begin{figure}[t]
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
  \delta &\Coloneqq& \true \mid \false \mid \ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x} \mid x \ntermeq K \mid x \termeq \bot \mid x \ntermeq \bot \mid \ctlet{x}{e} & \text{Constraint Literals} \\
  \Delta &\Coloneqq& \delta \mid \Delta \wedge \Delta \mid \Delta \vee \Delta & \text{Formula} \\
  \varphi   &\Coloneqq& \gamma \mid x \termeq \phiconapp{K}{a}{y} \mid x \ntermeq K \mid x \termeq \bot \mid x \ntermeq \bot \mid x \termeq y & \text{Simple constraints without scoping} \\
  \Phi   &\Coloneqq& \varnothing \mid \Phi,\varphi & \text{Set of simple constraints} \\
  \nabla &\Coloneqq& \ctxt{\Gamma}{\Phi} \mid \false & \text{Inert Set} \\
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
\[ \textbf{Checking Guard Trees} \]
\[ \ruleform{ \unc{t_G} = \Delta } \]
\[
\begin{array}{lcl}
\unc{\gdtrhs{n}} &=& \false \\
\unc{\gdtseq{t}{u}} &=& \unc{t} \wedge \unc{u} \\
\unc{\gdtguard{(\grdbang{x})}{t}} &=& (x \ntermeq \bot) \wedge \unc{t} \\
\unc{\gdtguard{(\grdlet{x}{e})}{t}} &=& (x \termeq e) \wedge \unc{t} \\
\unc{\gdtguard{(\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{t}} &=& (x \ntermeq K) \vee ((\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}) \wedge \unc{t}) \\
\end{array}
\]
\[ \ruleform{ \ann{\Delta}{t_G} = t_A } \]
\[
\begin{array}{lcl}
\ann{\Delta}{\gdtrhs{n}} &=& \begin{cases}
    \antred{n}, & \generate{\Gamma}{\Delta} = \emptyset \\
    \antrhs{n}, & \text{otherwise} \\
  \end{cases} \\
\ann{\Delta}{(\gdtseq{t}{u})} &=& \antseq{\ann{\Delta}{t}}{\ann{\Delta \wedge \unc{t}}{u}} \\
\ann{\Delta}{\gdtguard{(\grdbang{x})}{t}} &=& \begin{cases}
    \ann{\Delta \wedge (x \ntermeq \bot)}{t}, & \generate{\Gamma}{\Delta \wedge (x \termeq \bot)} = \emptyset \\
    \antdiv{\ann{\Delta \wedge (x \ntermeq \bot)}{t}} & \text{otherwise} \\
  \end{cases} \\
\ann{\Delta}{\gdtguard{(\grdlet{x}{e})}{t}} &=& \ann{\Delta \wedge (x \termeq e)}{t} \\
\ann{\Delta}{\gdtguard{(\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{t}} &=& \ann{\Delta \wedge (\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{t} \\
\end{array}
\]

\[ \textbf{Putting it all together} \]
  \begin{enumerate}
    \item[(0)] Input: Context with match vars $\Gamma$ and desugared $\Gdt$ $t$
    \item Report $n$ pattern vectors of $\generate{\Gamma}{\unc{t}}$ as uncovered
    \item Report the collected redundant and not-redundant-but-inaccessible clauses in $\ann{\true}{t}$ (TODO: Write a function that collects the RHSs).
  \end{enumerate}

\caption{Pattern-match checking}
\end{figure}







\begin{figure}[t]
\centering
\[ \textbf{Generate inhabitants of $\Delta$} \]
\[ \ruleform{ \generate{\Gamma}{\Delta} = \mathcal{P}(\PS) } \]
\[
\begin{array}{c}
   \generate{\Gamma}{\Delta} = \bigcup \left\{ \expand{\nabla}{\mathsf{dom}(\Gamma)} \mid \nabla \in \construct{\ctxt{\Gamma}{\varnothing}}{\Delta} \right\}
\end{array}
\]

\[ \textbf{Construct inhabited $\nabla$s from $\Delta$} \]
\[ \ruleform{ \construct{\nabla}{\Delta} = \mathcal{P}(\nabla) } \]
\[
\begin{array}{lcl}

  \construct{\nabla}{\delta} &=& \begin{cases}
    \left\{ \ctxt{\Gamma'}{\Phi'} \right\} & \text{where $\ctxt{\Gamma'}{\Phi'} = \adddelta{\nabla}{\delta}$} \\
    \emptyset & \text{otherwise} \\
  \end{cases} \\
  \construct{\nabla}{\Delta_1 \wedge \Delta_2} &=& \bigcup \left\{ \construct{\nabla'}{\Delta_2} \mid \nabla' \in \construct{\nabla}{\Delta_1} \right\} \\
  \construct{\nabla}{\Delta_1 \vee \Delta_2} &=& \construct{\nabla}{\Delta_1} \cup \construct{\nabla}{\Delta_2}

\end{array}
\]

\[ \textbf{Expand variables to $\Pat$ with $\nabla$} \]
\[ \ruleform{ \expand{\nabla}{\overline{x}} = \mathcal{P}(\PS) } \]
\[
\begin{array}{lcl}

  \expand{\nabla}{\epsilon} &=& \{ \epsilon \} \\
  \expand{\ctxt{\Gamma}{\Phi}}{x_1 ... x_n} &=& \begin{cases}
    \left\{ (K \; q_1 ... q_m) \, p_2 ... p_n \mid (q_1 ... q_m \, p_2 ... p_n) \in \expand{\ctxt{\Gamma}{\Phi}}{y_1 ... y_m x_2 ... x_n} \right\} & \text{if $\rep{\Phi}{x} \termeq \phiconapp{K}{a}{y} \in \Phi$} \\
    \left\{ \_ \; p_2 ... p_n \mid (p_2 ... p_n) \in \expand{\ctxt{\Gamma}{\Phi}}{x_2 ... x_n} \right\} & \text{otherwise} \\
  \end{cases} \\

\end{array}
\]

\[ \textbf{Finding the representative of a variable in $\Phi$} \]
\[ \ruleform{ \rep{\Phi}{x} = y } \]
\[
\begin{array}{lcl}
  \rep{\Phi}{x} &=& \begin{cases}
    \rep{\Phi}{y} & x \termeq y \in \Phi \\
    x & \text{otherwise} \\
  \end{cases} \\
\end{array}
\]


\caption{Bridging between the facade $\Delta$ and $\nabla$}
\end{figure}










\begin{figure}[t]
\centering
\[ \textbf{Add a constraint to the inert set} \]
\[ \ruleform{ \adddelta{\nabla}{\delta} = \nabla } \]
\[
\begin{array}{lcl}

  \adddelta{\nabla}{\false} &=& \false \\
  \adddelta{\nabla}{\true} &=& \nabla \\
  \adddelta{\ctxt{\Gamma}{\Phi}}{\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}} &=&
    \addphi{\addphi{\ctxt{\Gamma,\overline{a},\overline{y:\tau}}{\Phi}}{\overline{\gamma}}}{x \termeq \phiconapp{K}{a}{y}} \\
  % TODO: Really ugly to mix between adding a delta, a phi and then a delta again. But whatever
  \adddelta{\ctxt{\Gamma}{\Phi}}{\ctlet{x}{\expconapp{K}{\tau'}{\tau}{\gamma}{e}}} &=& \adddelta{\addphi{\adddelta{\ctxt{\Gamma,\overline{a},\overline{y:\sigma}}{\Phi}}{\ctcon{\genconapp{K}{a}{\gamma}{y}}{x}}}{\overline{a \typeeq \tau}}}{\overline{\ctlet{y}{e}}} \text{ where $\overline{a} \# \Gamma$, $\overline{y} \# \Gamma$, $\overline{e:\sigma}$} \\ 
  \adddelta{\nabla}{\ctlet{x}{e}} &=& \nabla \\
  % TODO: Somehow make the coercion from delta to phi less ambiguous
  \adddelta{\ctxt{\Gamma}{\Phi}}{\delta} &=& \addphi{\ctxt{\Gamma}{\Phi}}{\delta}

\end{array}
\]

\[ \textbf{Add a simple constraint to the inert set} \]
\[ \ruleform{ \addphi{\nabla}{\varphi} = \nabla } \]
\[
\begin{array}{lcl}

  \addphi{\false}{\varphi} &=& \false \\
  \addphi{\ctxt{\Gamma}{\Phi}}{\gamma} &=& \begin{cases}
    % TODO: This rule can loop indefinitely for GADTs... I believe we do this
    % only one level deep in the implementation and assume that it's inhabited otherwise
    \ctxt{\Gamma}{(\Phi,\gamma)} & \parbox[t]{0.6\textwidth}{if type checker deems $\gamma$ compatible with $\Phi$ \\ and $\forall x \in \mathsf{dom}(\Gamma): \inhabited{\ctxt{\Gamma}{(\Phi,\gamma)}}{\rep{\Phi}{x}}$} \\
    \false & \text{otherwise} \\
  \end{cases} \\
  \addphi{\ctxt{\Gamma}{\Phi}}{x \termeq \phiconapp{K}{a}{y}} &=& \begin{cases}
    \addphi{\addphi{\ctxt{\Gamma}{\Phi}}{\overline{a \typeeq b}}}{\overline{y \termeq z}} & \text{if $\rep{\Phi}{x} \termeq \phiconapp{K}{b}{z} \in \Phi$ } \\
    \ctxt{\Gamma'}{(\Phi',\rep{\Phi}{x} \termeq \phiconapp{K}{a}{y})} & \parbox[t]{0.6\textwidth}{where $\ctxt{\Gamma'}{\Phi'} = \addphi{\ctxt{\Gamma}{\Phi}}{\overline{\gamma}}$ \\ and $\rep{\Phi'}{x} \ntermeq K \not\in \Phi'$ and $\overline{\inhabited{\ctxt{\Gamma'}{\Phi'}}{y}}$} \\
    \false & \text{otherwise} \\
  \end{cases} \\
  \addphi{\ctxt{\Gamma}{\Phi}}{x \ntermeq K} &=& \begin{cases}
    \false & \text{if $\rep{\Phi}{x} \termeq \phiconapp{K}{a}{y} \in \Phi$} \\
    % TODO: I'm not sure if we really need the next line. It should be covered
    % by the following case, which will try to instantiate all constructors and
    % see if any is still possible by the x ~ K as gammas ys case
    % \bot & \parbox[t]{0.6\textwidth}{if $\rep{\Phi}{x}:\tau \in \Gamma$ \\ and $\forall K' \in \cons{\ctxt{\Gamma}{\Phi}}{\tau}: \rep{\Phi}{x} \ntermeq K' \in (\Phi,\rep{\Phi}{x} \ntermeq K)$} \\
    \false & \text{if not $\inhabited{\ctxt{\Gamma}{(\Phi,\rep{\Phi}{x} \ntermeq K)}}{\rep{\Phi}{x}}$} \\
    \ctxt{\Gamma}{(\Phi,\rep{\Phi}{x}\ntermeq K)} & \text{otherwise} \\
  \end{cases} \\
  \addphi{\ctxt{\Gamma}{\Phi}}{x \termeq \bot} &=& \begin{cases}
    \bot & \text{if $\rep{\Phi}{x} \ntermeq \bot \in \Phi$} \\
    \ctxt{\Gamma}{(\Phi,\rep{\Phi}{x}\termeq \bot)} & \text{otherwise} \\
  \end{cases} \\
  \addphi{\ctxt{\Gamma}{\Phi}}{x \ntermeq \bot} &=& \begin{cases}
    \false & \text{if $\rep{\Phi}{x} \termeq \bot \in \Phi$} \\
    \false & \text{if not $\inhabited{\ctxt{\Gamma}{(\Phi,\rep{\Phi}{x}\ntermeq\bot)}}{\rep{\Phi}{x}}$} \\
    \ctxt{\Gamma}{(\Phi,\rep{\Phi}{x} \ntermeq \bot)} & \text{otherwise} \\
  \end{cases} \\
  \addphi{\ctxt{\Gamma}{\Phi}}{x \termeq y} &=& \begin{cases}
    \ctxt{\Gamma}{\Phi} & \text{if $\rep{\Phi}{x} = \rep{\Phi}{y}$} \\
    % TODO: Write the function that adds a Phi to a nabla
    \addphi{\ctxt{\Gamma}{(\Phi, \rep{\Phi}{x} \termeq \rep{\Phi}{y})}}{((\Phi \cap \rep{\Phi}{x})[\rep{\Phi}{y} / \rep{\Phi}{x}])} & \text{otherwise} \\
  \end{cases} \\

\end{array}
\]


\[ \ruleform{ \Phi \cap x = \Phi } \]
\[
\begin{array}{lcl}
  \varnothing \cap x &=& \varnothing \\
  (\Phi,x \termeq \phiconapp{K}{a}{y}) \cap x &=& (\Phi \cap x), x \termeq \phiconapp{K}{a}{y} \\
  (\Phi,x \ntermeq K) \cap x &=& (\Phi \cap x), x \ntermeq K \\
  (\Phi,x \termeq \bot) \cap x &=& (\Phi \cap x), x \termeq \bot \\
  (\Phi,x \ntermeq \bot) \cap x &=& (\Phi \cap x), x \ntermeq \bot \\
  (\Phi,\varphi) \cap x &=& \Phi \cap x \\
\end{array}
\]

\caption{Adding a constraint to the inert set $\nabla$}
\end{figure}

\begin{figure}[t]
\centering
\[ \textbf{Test if $x$ is inhabited considering $\nabla$} \]
\[ \ruleform{ \inhabited{\nabla}{x} } \]
\[
\begin{array}{c}

  \prooftree
    (\addphi{\ctxt{\Gamma}{\Phi}}{x \termeq \bot}) \not= \false
  \justifies
    \inhabited{\ctxt{\Gamma}{\Phi}}{x}
  \endprooftree

  \quad

  \prooftree
    \Shortstack{{x:\tau \in \Gamma \quad K \in \cons{\ctxt{\Gamma}{\Phi}}{\tau}}
                {\inst{\Gamma}{x}{K} = \overline{\varphi}}
               {(\addphi{\ctxt{\Gamma,\overline{y:\tau'}}{\Phi}}{\overline{\varphi}}) \not= \false}}
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
    \tau_x \typeeq \tau, \overline{\gamma}, x \termeq \phiconapp{K}{a}{y}, \overline{y' \ntermeq \bot} & \parbox[t]{0.8\textwidth}{$K : \forall \overline{a}. \overline{\gamma} \Rightarrow \overline{\sigma} \rightarrow \tau$, $\overline{y} \# \Gamma$, $\overline{a} \# \Gamma$, $x:\tau_x \in \Gamma$, $\overline{y'}$ bind strict fields} \\
    % TODO: We'd need a cosntraint like \delta's \false here... Or maybe we
    % just omit this case and accept that the function is partial
    \bot & \text{otherwise} \\
  \end{cases} \\

\end{array}
\]

\caption{Inhabitance test}
\end{figure}




\section{End to end example}

We'll start from the following source Haskell program and see how each of the steps (translation to guard trees, checking guard trees and ultimately generating inhabitants of the occurring $\Delta$s) work.

\begin{code}
f :: Maybe Int -> Int
f Nothing         = 0 -- RHS 1
f x | Just y <- x = y -- RHS 2
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

The last section left open how $\generate{}{}$ works, which was used to
establish or refute vacuosity of a $\Delta$.

$\generate{}{}$ proceeds in two steps: First it constructs zero, one or many
\emph{inert sets} $\nabla$ with $\construct{}{}$ (each of them representing a
set of mutually compatible constraints) and then expands each of the returned
inert sets into one or more pattern vectors $\overline{p}$ with $\expand{}{}$,
which is the preferred representation to show to the user.

The interesting bit happens in $\construct{}{}$, where a $\Delta$ is basically
transformed into disjunctive normal form, represented by a set of independently
inhabited $\nabla$. This ultimately happens in the base case of
$\construct{}{}$, by gradually adding individual constraints to the incoming
inert set with $\addphi{}{}$, which starts out empty in $\generate{}{}$.
Conjunction is handled by performing the equivalent of a \hs{concatMap},
whereas disjunction simply translates to set union.

Let's see how that works for $\Delta_3$ above. Recall that 
$\Gamma = x:\texttt{Maybe Int}$ and $\Delta_3 = \true \wedge x \termeq \bot$:

\[
  \begin{array}{ll}
    & \construct{\Gamma}{\true \wedge x \termeq \bot} \\
  = & \quad \{ \text{ Conjunction } \} \\
    & \bigcup \left\{ \construct{\ctxt{\Gamma'}{\nabla'}}{x \termeq \bot} \mid \ctxt{\Gamma'}{\nabla'} \in \construct{\ctxt{\Gamma}{\varnothing}}{\true} \right\} \\
  = & \quad \{ \text{ Single constraint } \} \\
    & \begin{cases}
        \construct{\ctxt{\Gamma'}{\nabla'}}{x \termeq \bot} & \text{where $\ctxt{\Gamma'}{\nabla'} = \addphi{\ctxt{\Gamma}{\varnothing}}{\true}$} \\
        \emptyset & \text{otherwise} \\
    \end{cases} \\
  = & \quad \{ \text{ $\true$ case of $\addphi{}{}$ } \} \\
    & \construct{\ctxt{\Gamma}{\varnothing}}{x \termeq \bot} \\
  = & \quad \{ \text{ Single constraint } \} \\
    & \begin{cases}
        \{ \ctxt{\Gamma'}{\nabla'} \} & \text{where $\ctxt{\Gamma'}{\nabla'} = \addphi{\ctxt{\Gamma}{\varnothing}}{x \termeq \bot}$} \\
        \emptyset & \text{otherwise} \\
    \end{cases} \\
  = & \quad \{ \text{ $x \termeq \bot$ case of $\addphi{}{}$ } \} \\
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
Indeed, $\expand{\ctxt{\Gamma}{x \termeq \bot}}{x}$ generate $\_$ as the
inhabitant (which is rather unhelpful, but correct).

The result of $\generate{\Gamma}{\Delta_3}$ is thus $\{\_\}$, which is not
empty. Thus, $\ann{\Delta}{t}$ will wrap a $\antdiv{}$ around the first RHS.

Similarly, $\generate{\Gamma}{\Delta_4}$ needs
$\construct{\ctxt{\Gamma}{\varnothing}}{\Delta_4}$, which in turn will add $x
\ntermeq \bot$ to an initially empty $\nabla$. That entails an inhabitance
check to see if $x$ might take on any values besides $\bot$.

This is one possible derivation of the $\inhabited{\ctxt{\Gamma}{x \ntermeq \bot}}{x}$ predicate:
\[
  \begin{array}{c}

  \prooftree
    \Shortstack{{x:\texttt{Maybe Int} \in \Gamma \quad \mathtt{Nothing} \in \cons{\ctxt{\Gamma}{x \ntermeq \bot}}{\texttt{Maybe Int}}}
                {\inst{\Gamma}{x}{\mathtt{Nothing}} = \ctcon{\mathtt{Nothing}}{x}}
               {(\addphi{\ctxt{\Gamma}{x \ntermeq \bot}}{\ctcon{\mathtt{Nothing}}{x}}) \not= \bot}}
  \justifies
    \inhabited{\ctxt{\Gamma}{x \ntermeq \bot}}{x}
  \endprooftree

  \end{array}
\]

The subgoal $\addphi{\ctxt{\Gamma}{x \ntermeq \bot}}{\ctcon{\mathtt{Nothing}}{x}}$
is handled by the second case of the match on constructor pattern constraints,
because there are no other constructor pattern constraints yet in the incoming
$\nabla$. Since there are no type constraints carried by \texttt{Nothing}, no
fields and no constraints of the form $x \ntermeq K$ in $\nabla$, we end up
with $\ctxt{\Gamma}{x \ntermeq \bot, \ctcon{\mathtt{Nothing}}{x}}$. Which is
not $\bot$, thus we conclude our proof of
$\inhabited{\ctxt{\Gamma}{x \ntermeq \bot}}{x}$.

Next, we have to add $\ctcon{\mathtt{Nothing}}{x}$ to our $\nabla = x \ntermeq \bot$,
which amounts to computing
$\addphi{\ctxt{\Gamma}{x \ntermeq \bot}}{\ctcon{\mathtt{Nothing}}{x}}$.
Conveniently, we just did that! So the result of
$\construct{\ctxt{\Gamma}{\varnothing}}{\Delta_4}$ is
$\ctxt{\Gamma}{x \ntermeq \bot, \ctcon{\mathtt{Nothing}}{x}}$.

Now, we see that
$\expand{\ctxt{\Gamma}{(x \ntermeq \bot, \ctcon{\mathtt{Nothing}}{x})}}{x} = \{\mathtt{Nothing}\}$,
which is also the result of $\generate{\Gamma}{\Delta_4}$.

The checks for $\Delta_5$ and $\Delta_6$ are quite similar, only that we start
from $\construct{\ctxt{\Gamma}{\varnothing}}{\Delta_1}$ (which occur
syntactically in $\Delta_5$ and $\Delta_6$) as the initial $\nabla$. So, we
first compute that.

Fast forward to computing $\addphi{\ctxt{\Gamma}{x \ntermeq \bot}}{x \ntermeq \mathtt{Nothing}}$.
Ultimately, this entails a proof of
$\inhabited{\ctxt{\Gamma}{x \ntermeq \bot, x \ntermeq \mathtt{Nothing}}}{x}$, for which we need to instantiate the \texttt{Just} constructor:
\[
  \begin{array}{c}

  \prooftree
    \Shortstack{{x:\texttt{Maybe Int} \in \Gamma \quad \mathtt{Just} \in \cons{\ctxt{\Gamma}{(x \ntermeq \bot, x \ntermeq \mathtt{Nothing})}}{\texttt{Maybe Int}}}
                {\inst{\Gamma}{x}{\mathtt{Just}} = \ctcon{\mathtt{Just} \; y}{x}}
               {(\addphi{\ctxt{\Gamma,y:\mathtt{Int}}{(x \ntermeq \bot, x \ntermeq \mathtt{Nothing})}}{\ctcon{\mathtt{Just} \; y}{x}}) \not= \bot}}
  \justifies
    \inhabited{\ctxt{\Gamma}{x \ntermeq \bot, x \ntermeq \mathtt{Nothing}}}{x}
  \endprooftree

  \end{array}
\]

$\addphi{\ctxt{\Gamma,y:\mathtt{Int}}{(x \ntermeq \bot, x \ntermeq \mathtt{Nothing})}}{\ctcon{\mathtt{Just} \; y}{x}})$
is in fact not $\bot$, which is enough to conclude
$\inhabited{\ctxt{\Gamma}{x \ntermeq \bot, x \ntermeq \mathtt{Nothing}}}{x}$.

The second operand of $\vee$ in $\Delta_1$ is similar, but ultimately ends in
$\false$, so will never produce a $\nabla$, so
$\construct{\ctxt{\Gamma}{\varnothing}}{\Delta_1} = \ctxt{\Gamma}{x \ntermeq \bot, x \ntermeq \mathtt{Nothing}}$.

$\construct{\ctxt{\Gamma}{\varnothing}}{\Delta_5}$ will then just add
$x \termeq \bot$ to that $\nabla$, which immediately refutes with
$x \ntermeq \bot$. So no $\antdiv{}$ around the second RHS.

$\construct{\ctxt{\Gamma}{\varnothing}}{\Delta_6}$ is very similar to the
situation with $\Delta_4$, just with more (non-conflicting) constraints in the
incoming $\nabla$ and with $\ctcon{\mathtt{Just}\;y}{x}$ instead of
$\ctcon{\mathtt{Nothing}}{x}$. Thus, $\generate{\Gamma}{\Delta_6} = \{\mathtt{Just}\; \_\}$.

The last bit concerns $\generate{\Gamma}{\Delta_2}$, which is empty because we
ultimately would add $x \ntermeq \mathtt{Just}$ to the inert set
$x \ntermeq \bot, x \ntermeq \mathtt{Nothing}$, which refutes by the second
case of $\addphi{\_}{\_}$. (The $\vee$ operand with $\false$ in it is empty,
as usual).

So we have $\generate{\Gamma}{\Delta_2} = \emptyset$ and the pattern-match is
exhaustive.

The result of $\ann{\Gamma}{t}$ is thus $\antseq{\antdiv{\antrhs{1}}}{\antrhs{2}}$.

%\listoftodos\relax

\nocite{*}

%\bibliography{references}

\end{document}
