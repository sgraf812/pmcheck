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

\documentclass[acmsmall]{acmart}

% The following lines remove ACM stuff unneeded for prototyping
% https://tex.stackexchange.com/a/346309/52414
\settopmatter{printacmref=false} % Removes citation information below abstract
\renewcommand\footnotetextcopyrightpermission[1]{} % removes footnote with conference information in first column
\pagestyle{plain} % removes running headers


%include lhs2TeX.fmt
%include lhs2TeX.sty

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




\pagebreak

\begin{figure}[t]
\centering
\[ \textbf{Guard Syntax} \]
\[
\begin{array}{cc}
\begin{array}{rlcl}
  K           \in &\Con &         & \\
  x,y,a,b     \in &\Var &         & \\
  \tau,\sigma \in &\Type&         & \\
  e \in           &\Expr&\Coloneqq& x:\tau \\
                  &     &\mid     & \genconapp{K}{\tau}{\gamma}{e:\tau} \\
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
  \nabla &\Coloneqq& \varnothing \mid \nabla, \delta & \text{Inert Set} \\
\end{array}
\]

\[ \textbf{Clause Tree Syntax} \]
\[
\begin{array}{rcll}
  t_G,u_G \in \Gdt &\Coloneqq& \gdtrhs{n} \mid \gdtseq{t_G}{u_G} \mid \gdtguard{g}{t_G}         \\
  t_A,u_A \in \Ant &\Coloneqq& \antrhs{n} \mid \antred{n} \mid \antseq{t_A}{u_A} \mid \antdiv{t_A} \\
\end{array}
\]

\[ \textbf{Checking Guard Trees} \]
\[ \ruleform{ \unc{t_G} = \Delta } \]
\[
\begin{array}{lcl}
\unc{\gdtrhs{n}} &=& \false \\
\unc{\gdtseq{t}{u}} &=& \unc{t} \wedge \unc{u} \\
\unc{\gdtguard{(\grdbang{x})}{t}} &=& (x \ntermeq \bot) \wedge \unc{t} \\
\unc{\gdtguard{(\grdlet{x}{e})}{t}} &=& (x \termeq e) \wedge \unc{t} \\
\unc{\gdtguard{(\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{t}} &=& (x \ntermeq K) \vee ((\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}) \wedge \unc{gs}) \\
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
\end{figure}







\begin{figure}[t]
\centering
\[ \textbf{Generate inhabitants of $\Delta$} \]
\[ \ruleform{ \generate{\Gamma}{\Delta} = \mathcal{P}(\PS) } \]
\[
\begin{array}{c}
   \generate{\Gamma}{\Delta} = \bigcup \left\{ \expand{\ctxt{\Gamma'}{\nabla'}}{\mathsf{fvs}(\Gamma)} \mid \forall (\ctxt{\Gamma'}{\nabla'}) \in \construct{\ctxt{\Gamma}{\varnothing}}{\Delta} \right\}
\end{array}
\]

\[ \textbf{Construct inhabited $\nabla$s from $\Delta$} \]
\[ \ruleform{ \construct{\ctxt{\Gamma}{\nabla}}{\Delta} = \mathcal{P}(\ctxt{\Gamma}{\nabla}) } \]
\[
\begin{array}{lcl}

  \construct{\ctxt{\Gamma}{\nabla}}{\delta} &=& \begin{cases}
    \left\{ \ctxt{\Gamma'}{\nabla'} \right\} & \text{where $\ctxt{\Gamma'}{\nabla'} = \addinert{\ctxt{\Gamma}{\nabla}}{\delta}$} \\
    \emptyset & \text{otherwise} \\
  \end{cases} \\
  \construct{\ctxt{\Gamma}{\nabla}}{\Delta_1 \wedge \Delta_2} &=& \bigcup \left\{ \construct{\ctxt{\Gamma'}{\nabla'}}{\Delta_2} \mid \forall (\ctxt{\Gamma'}{\nabla'}) \in \construct{\ctxt{\Gamma}{\nabla}}{\Delta_1} \right\} \\
  \construct{\ctxt{\Gamma}{\nabla}}{\Delta_1 \vee \Delta_2} &=& \construct{\ctxt{\Gamma}{\nabla}}{\Delta_1} \cup \construct{\ctxt{\Gamma}{\nabla}}{\Delta_2}

\end{array}
\]

\[ \textbf{Expand variables to $\Pat$ with $\nabla$} \]
\[ \ruleform{ \expand{\ctxt{\Gamma}{\nabla}}{\overline{x}} = \mathcal{P}(\PS) } \]
\[
\begin{array}{lcl}

  \expand{\ctxt{\Gamma}{\nabla}}{\epsilon} &=& \{ \epsilon \} \\
  \expand{\ctxt{\Gamma}{\nabla}}{x_1 ... x_n} &=& \begin{cases}
    \left\{ (K \; q_1 ... q_m) \, p_2 ... p_n \mid \forall (q_1 ... q_m \, p_2 ... p_n) \in \expand{\ctxt{\Gamma}{\nabla}}{y_1 ... y_m x_2 ... x_n} \right\} & \text{if $\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x} \in \nabla$} \\
    \left\{ \_ \; p_2 ... p_n \mid \forall (p_2 ... p_n) \in \expand{\ctxt{\Gamma}{\nabla}}{x_2 ... x_n} \right\} & \text{otherwise} \\
  \end{cases} \\

\end{array}
\]
\end{figure}










\begin{figure}[t]
\centering
\[ \textbf{Add a constraint to the inert set} \]
\[ \ruleform{ \addinert{\ctxt{\Gamma}{\nabla}}{\delta} = \ctxt{\Gamma}{\nabla} } \]
\[
\begin{array}{lcl}

  \addinert{\ctxt{\Gamma}{\nabla}}{\false} &=& \bot \\
  \addinert{\ctxt{\Gamma}{\nabla}}{\true} &=& \ctxt{\Gamma}{\nabla} \\
  \addinert{\ctxt{\Gamma}{\nabla}}{\gamma} &=& \begin{cases}
    % TODO: This rule can loop indefinitely for GADTs... I believe we do this
    % only one level deep in the implementation and assume that it's inhabited otherwise
    \ctxt{\Gamma}{(\nabla,\gamma)} & \parbox[t]{0.6\textwidth}{if type checker deems $\gamma$ compatible with $\nabla$ \\ and $\forall x \in \mathsf{fvs}(\Gamma): \inhabited{\ctxt{\Gamma}{(\nabla,\gamma)}}{x}$} \\
    \bot & \text{otherwise} \\
  \end{cases} \\
  \addinert{\ctxt{\Gamma}{\nabla}}{\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}} &=& \begin{cases}
    \addinert{\addinert{\addinert{\ctxt{\Gamma,\overline{a},\overline{y:\tau}}{\nabla}}{\overline{a \typeeq b}}}{\overline{\gamma}}}{\overline{\ctlet{y}{z}}} & \text{if $\ctcon{\genconapp{K}{b}{\gamma}{z:\tau}}{x} \in \nabla$ } \\
    \ctxt{\Gamma'}{(\nabla',\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})} & \parbox[t]{0.6\textwidth}{where $\ctxt{\Gamma'}{\nabla'} = \addinert{\ctxt{\Gamma,\overline{a},\overline{y:\tau}}{\nabla}}{\overline{\gamma}}$ \\ and $x \ntermeq K \not\in \nabla$ \\ and $\overline{\inhabited{\ctxt{\Gamma'}{\nabla'}}{y}}$} \\
    \bot & \text{otherwise} \\
  \end{cases} \\
  \addinert{\ctxt{\Gamma}{\nabla}}{x \ntermeq K} &=& \begin{cases}
    \bot & \text{if $\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x} \in \nabla$} \\
    % TODO: I'm not sure if we really need the next line. It should be covered by the following case
    \bot & \parbox[t]{0.6\textwidth}{if $x:\tau \in \Gamma$ \\ and $\forall K' \in \mathsf{Cons}(\ctxt{\Gamma}{\nabla}, \tau): x \ntermeq K' \in (\nabla,x \ntermeq K)$} \\
    \bot & \text{if not $\inhabited{\ctxt{\Gamma}{(\nabla,x\ntermeq K)}}{x}$} \\
    \ctxt{\Gamma}{(\nabla,x\ntermeq K)} & \text{otherwise} \\
  \end{cases} \\
  \addinert{\ctxt{\Gamma}{\nabla}}{x \termeq \bot} &=& \begin{cases}
    \bot & \text{if $x \ntermeq \bot \in \nabla$} \\
    \ctxt{\Gamma}{(\nabla,x\termeq \bot)} & \text{otherwise} \\
  \end{cases} \\
  \addinert{\ctxt{\Gamma}{\nabla}}{x \ntermeq \bot} &=& \begin{cases}
    \bot & \text{if $x \termeq \bot \in \nabla$} \\
    \bot & \text{if not $\inhabited{\ctxt{\Gamma}{(\nabla,x\ntermeq\bot)}}{x}$} \\
    \ctxt{\Gamma}{(\nabla,x\ntermeq \bot)} & \text{otherwise} \\
  \end{cases} \\
  \addinert{\ctxt{\Gamma}{\nabla}}{\ctlet{x}{y}} &=& \begin{cases}
    \ctxt{\Gamma}{\nabla} & \text{if $\nabla(x) = z = \nabla(y)$} \\
    \addinert{\ctxt{\Gamma}{\nabla}, \ctlet{x}{y}}{(\nabla \cap x)[y / x]} & \text{if $\nabla(x) \not= z$ or $\nabla(y) \not= z$} \\
  \end{cases} \\
  \addinert{\ctxt{\Gamma}{\nabla}}{\ctlet{x}{\genconapp{K}{\tau}{\gamma}{e}}} &=& \addinert{\addinert{\addinert{\ctxt{\Gamma,\overline{a},\overline{y:\sigma}}{\nabla}}{\ctcon{\genconapp{K}{a}{\gamma}{y}}{x}}}{\overline{a \typeeq \tau}}}{\overline{\ctlet{y}{e}}} \text{ where $\overline{a} \# \Gamma$, $\overline{y} \# \Gamma$, $\overline{e:\sigma}$} \\ 
  \addinert{\ctxt{\Gamma}{\nabla}}{\ctlet{x}{e}} &=& \ctxt{\Gamma}{\nabla} \\

\end{array}
\]

\[ \ruleform{ \nabla \cap x = \nabla } \]
\[
\begin{array}{lcl}
  \varnothing \cap x &=& \varnothing \\
  (\nabla,\ctcon{\genconapp{K}{a}{\gamma}{y}}{x}) \cap x &=& (\nabla \cap x), \ctcon{\genconapp{K}{a}{\gamma}{y}}{x} \\
  (\nabla,x \ntermeq K) \cap x &=& (\nabla \cap x), x \ntermeq K \\
  (\nabla,x \termeq \bot) \cap x &=& (\nabla \cap x), x \termeq \bot \\
  (\nabla,x \ntermeq \bot) \cap x &=& (\nabla \cap x), x \ntermeq \bot \\
  (\nabla,x \termeq e) \cap x &=& (\nabla \cap x), x \termeq e \\
  (\nabla,\delta) \cap x &=& \nabla \cap x \\
\end{array}
\]
\end{figure}

\begin{figure}[t]
\centering
\[ \textbf{Test if $x$ is inhabited considering $\nabla$} \]
\[ \ruleform{ \inhabited{\ctxt{\Gamma}{\nabla}}{x} } \]
\[
\begin{array}{c}

  \prooftree
    (\addinert{\ctxt{\Gamma}{\nabla}}{x \termeq \bot}) \not= \bot
  \justifies
    \inhabited{\ctxt{\Gamma}{\nabla}}{x}
  \endprooftree

  \quad

  \prooftree
    \Shortstack{{x:\tau \in \Gamma \quad K \in \mathsf{Cons}(\ctxt{\Gamma}{\nabla},\tau)}
                {\inst{\Gamma}{x}{K} = \overline{\delta}}
               {(\addinert{\ctxt{\Gamma,\overline{y:\tau'}}{\nabla}}{\overline{\delta}}) \not= \bot}}
  \justifies
    \inhabited{\ctxt{\Gamma}{\nabla}}{x}
  \endprooftree

  \\
  \\

  \prooftree
    {x:\tau \in \Gamma \quad \mathsf{Cons}(\ctxt{\Gamma}{\nabla},\tau) = \bot}
  \justifies
    \inhabited{\ctxt{\Gamma}{\nabla}}{x}
  \endprooftree

  \quad

  \prooftree
    \Shortstack{{x:\tau \in \Gamma \quad K \in \mathsf{Cons}(\ctxt{\Gamma}{\nabla},\tau)}
                {\inst{\Gamma}{x}{K} = \bot}}
  \justifies
    \inhabited{\ctxt{\Gamma}{\nabla}}{x}
  \endprooftree

\end{array}
\]

\[ \textbf{Find data constructors of $\tau$} \]
\[ \ruleform{ \cons{\ctxt{\Gamma}{\nabla}}{\tau} = \overline{K}} \]
\[
\begin{array}{c}

  \cons{\ctxt{\Gamma}{\nabla}}{\tau} = \begin{cases}
    \overline{K} & \parbox[t]{0.8\textwidth}{$\tau = T \; \overline{\sigma}$ and $T$ data type with constructors $\overline{K}$ \\ (after normalisation according to the type constraints in $\nabla$)} \\
    \bot & \text{otherwise} \\
  \end{cases} \\

\end{array}
\]

% This is mkOneConFull
\[ \textbf{Instantiate $x$ to data constructor $K$} \]
\[ \ruleform{ \inst{\Gamma}{x}{K} = \overline{\gamma} } \]
\[
\begin{array}{c}

  \inst{\Gamma}{x}{K} = \begin{cases}
    \tau_x \typeeq \tau, \ctcon{\genconapp{K}{a}{\gamma}{y}}{x}, \overline{y' \ntermeq \bot} & \parbox[t]{0.8\textwidth}{$K : \forall \overline{a}. \overline{\gamma} \Rightarrow \overline{\sigma} \rightarrow \tau$, $\overline{y} \# \Gamma$, $\overline{a} \# \Gamma$, $x:\tau_x \in \Gamma$, $\overline{y'}$ bind strict fields} \\
    \bot & \text{otherwise} \\
  \end{cases} \\

\end{array}
\]


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

Note how $\Delta_1$ gets duplicated in $\Delta_2$. The right operands of $\vee$
are vacuous, but the purely syntactical transformation doesn't see that. Hence
it makes sense for the implementation to do work on $\Delta_1$ prior to
duplicating it, so that the same work doesn't have to be performed twice (or
exponentially often). In practice, this works by converting to $\nabla$
eagerly. It's quite similar to the situation with call-by-name (where we might
need to "evaluate" $\Delta_1$ multiple times) vs. call-by-value (where we
evaluate once up front).
 
\subsubsection{Redundancy}

We'll just give the four $\Delta$s that we need to generate the inhabitants
for (as part of computing $\ann{\Delta}{t}$): One for each bang (for knowing
whether we need to wrap a $\antdiv{}$ and one for each RHS (where we have to
decide for $\antred{}$ or $\antrhs{}$).

\begin{enumerate}
  \item The first divergence check: $\Delta_3 := \true \wedge x \termeq \bot$
  \item Upon reaching the first RHS: $\Delta_4 := \true \wedge x \ntermeq \bot \wedge \ctcon{\mathtt{Nothing}}{x}$
  \item The second divergence check: $\Delta_5 := \Delta_1 \wedge x \termeq \bot$
  \item Upon reaching the second RHS: $\Delta_6 := \Delta_1 \wedge x \ntermeq \bot \wedge \ctcon{\mathtt{Just} \; y}{x}$
\end{enumerate}

The missing equations and the annotated tree then depend on the inhabitants of these $\Delta$s, i.e. on the result of $\generate{x:\texttt{Maybe Int}}{\Delta_i}$.

\subsection{Generating inhabitants}

Let's start with $\generate{\Gamma}{\Delta_3}$, where $\Gamma =
x:\texttt{Maybe Int}$.

We immediately have $\construct{\ctxt{\Gamma}{\varnothing}}{\Delta_3}$ as a
sub-goal. The first constraint $\true$ is added very easily to the initial
$\nabla$ by discarding it, the second one ($x \termeq \bot$) is not conflicting
with any $x \ntermeq \bot$ constraint in the incoming $\nabla$ $\varnothing$,
so we end up with $\ctxt{\Gamma}{x \termeq \bot}$ as proof that $\Delta_3$ is
in fact inhabited. Indeed, $\expand{\ctxt{\Gamma}{x \termeq \bot}}{x}$
generate $\_$ as the inhabitant (which is rather unhelpful, but correct).

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
    \Shortstack{{x:\texttt{Maybe Int} \in \Gamma \quad \mathtt{Nothing} \in \mathsf{Cons}(\ctxt{\Gamma}{x \ntermeq \bot},\texttt{Maybe Int})}
                {\inst{\Gamma}{x}{\mathtt{Nothing}} = \ctcon{\mathtt{Nothing}}{x}}
               {(\addinert{\ctxt{\Gamma}{x \ntermeq \bot}}{\ctcon{\mathtt{Nothing}}{x}}) \not= \bot}}
  \justifies
    \inhabited{\ctxt{\Gamma}{x \ntermeq \bot}}{x}
  \endprooftree

  \end{array}
\]

The subgoal $\addinert{\ctxt{\Gamma}{x \ntermeq \bot}}{\ctcon{\mathtt{Nothing}}{x}}$
is handled by the second case of the match on constructor pattern constraints,
because there are no other constructor pattern constraints yet in the incoming
$\nabla$. Since there are no type constraints carried by \texttt{Nothing}, no
fields and no constraints of the form $x \ntermeq K$ in $\nabla$, we end up
with $\ctxt{\Gamma}{x \ntermeq \bot, \ctcon{\mathtt{Nothing}}{x}}$. Which is
not $\bot$, thus we conclude our proof of
$\inhabited{\ctxt{\Gamma}{x \ntermeq \bot}}{x}$.

Next, we have to add $\ctcon{\mathtt{Nothing}}{x}$ to our $\nabla = x \ntermeq \bot$,
which amounts to computing
$\addinert{\ctxt{\Gamma}{x \ntermeq \bot}}{\ctcon{\mathtt{Nothing}}{x}}$.
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

Fast forward to computing $\addinert{\ctxt{\Gamma}{x \ntermeq \bot}}{x \ntermeq \mathtt{Nothing}}$.
Ultimately, this entails a proof of
$\inhabited{\ctxt{\Gamma}{x \ntermeq \bot, x \ntermeq \mathtt{Nothing}}}{x}$, for which we need to instantiate the \texttt{Just} constructor:
\[
  \begin{array}{c}

  \prooftree
    \Shortstack{{x:\texttt{Maybe Int} \in \Gamma \quad \mathtt{Just} \in \mathsf{Cons}(\ctxt{\Gamma}{(x \ntermeq \bot, x \ntermeq \mathtt{Nothing})},\texttt{Maybe Int})}
                {\inst{\Gamma}{x}{\mathtt{Just}} = \ctcon{\mathtt{Just} \; y}{x}}
               {(\addinert{\ctxt{\Gamma,y:\mathtt{Int}}{(x \ntermeq \bot, x \ntermeq \mathtt{Nothing})}}{\ctcon{\mathtt{Just} \; y}{x}}) \not= \bot}}
  \justifies
    \inhabited{\ctxt{\Gamma}{x \ntermeq \bot, x \ntermeq \mathtt{Nothing}}}{x}
  \endprooftree

  \end{array}
\]

$\addinert{\ctxt{\Gamma,y:\mathtt{Int}}{(x \ntermeq \bot, x \ntermeq \mathtt{Nothing})}}{\ctcon{\mathtt{Just} \; y}{x}})$
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
case of $\addinert{\_}{\_}$. (The $\vee$ operand with $\false$ in it is empty,
as usual).

So we have $\generate{\Gamma}{\Delta_2} = \emptyset$ and the pattern-match is
exhaustive.

The result of $\ann{\Gamma}{t}$ is thus $\antseq{\antdiv{\antrhs{1}}}{\antrhs{2}}$.

%\listoftodos\relax

\nocite{*}

%\bibliography{references}

\end{document}
