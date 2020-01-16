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
                  &     &\mid     & K \; \overline{y} \\
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
\[ \ruleform{ \unc{\Delta}{t_G} = \Delta } \]
\[
\begin{array}{lcl}
\unc{\Delta}{\gdtrhs{n}} &=& \false \\
\unc{\Delta}{(\gdtseq{t}{u})} &=& \unc{\unc{\Delta}{t}}{u} \\
\unc{\Delta}{\gdtguard{(\grdbang{x})}{t}} &=& \unc{\Delta \wedge (x \ntermeq \bot)}{t} \\
\unc{\Delta}{\gdtguard{(\grdlet{x}{e})}{t}} &=& \unc{\Delta \wedge (x \termeq e)}{t} \\
\unc{\Delta}{\gdtguard{(\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{t}} &=& (\Delta \wedge (x \ntermeq K) \wedge (x \ntermeq \bot)) \vee \unc{\Delta \wedge (\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{gs} \\
\end{array}
\]
\[ \ruleform{ \ann{\Delta}{t_G} = t_A } \]
\[
\begin{array}{lcl}
\ann{\Delta}{\gdtrhs{n}} &=& \begin{cases}
    \antred{n}, & \values{\Gamma}{\Delta} = \emptyset \\
    \antrhs{n}, & \text{otherwise} \\
  \end{cases} \\
\ann{\Delta}{(\gdtseq{t}{u})} &=& \antseq{\ann{\Delta}{t}}{\ann{\unc{\Delta}{t}}{u}} \\
\ann{\Delta}{\gdtguard{(\grdbang{x})}{t}} &=& \begin{cases}
    \ann{\Delta \wedge (x \ntermeq \bot)}{t}, & \values{\Gamma}{\Delta \wedge (x \termeq \bot)} = \emptyset \\
    \antdiv{\ann{\Delta \wedge (x \ntermeq \bot)}{t}} & \text{otherwise} \\
  \end{cases} \\
\ann{\Delta}{\gdtguard{(\grdlet{x}{e})}{t}} &=& \ann{\Delta \wedge (x \termeq e)}{t} \\
\ann{\Delta}{\gdtguard{(\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{t}} &=& \ann{\Delta \wedge (\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{t} \\
\end{array}
\]

\[ \textbf{Putting it all together} \]
  \begin{enumerate}
    \item[(0)] Input: Context with match vars $\Gamma$ and desugared $\Gdt$ $t$
    \item Report $n$ value vectors of $\values{\Gamma}{\unc{\true}{t}}$ as uncovered
    \item Report the collected redundant and not-redundant-but-inaccessible clauses in $\ann{\true}{t}$ (TODO: Write a function that collects the RHSs).
  \end{enumerate}
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
    \ctxt{\Gamma}{(\nabla,\gamma)} & \parbox[t]{0.6\textwidth}{if type checker deems $\gamma$ compatible with $\nabla$ \\ and $\forall x \in \mathsf{fvs}(\Gamma): \inh{\ctxt{\Gamma}{(\nabla,\gamma)}}{x}$} \\
    \bot & \text{otherwise} \\
  \end{cases} \\
  \addinert{\ctxt{\Gamma}{\nabla}}{\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x}} &=& \begin{cases}
    \addinert{\addinert{\addinert{\ctxt{\Gamma,\overline{a},\overline{y:\tau}}{\nabla}}{\overline{a \typeeq b}}}{\overline{\gamma}}}{\overline{\ctlet{y}{z}}} & \text{if $\ctcon{\genconapp{K}{b}{\gamma}{z:\tau}}{x} \in \nabla$ } \\
    \ctxt{\Gamma'}{(\nabla',\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})} & \parbox[t]{0.6\textwidth}{where $\ctxt{\Gamma'}{\nabla'} = \addinert{\ctxt{\Gamma,\overline{a},\overline{y:\tau}}{\nabla}}{\overline{\gamma}}$ \\ and $x \ntermeq K \not\in \nabla$ \\ and $\overline{\inh{\ctxt{\Gamma'}{\nabla'}}{y}}$} \\
    \bot & \text{otherwise} \\
  \end{cases} \\
  \addinert{\ctxt{\Gamma}{\nabla}}{x \ntermeq K} &=& \begin{cases}
    \bot & \text{if $\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x} \in \nabla$} \\
    \bot & \parbox[t]{0.6\textwidth}{if $x:\tau \in \Gamma$ \\ and $\forall K':\sigma \in \mathsf{Cons}(\ctxt{\Gamma}{\nabla}, \tau): x \ntermeq K' \in (\nabla,x \ntermeq K)$} \\
    \bot & \text{if not $\inh{\ctxt{\Gamma}{(\nabla,x\ntermeq K)}}{x}$} \\
    \ctxt{\Gamma}{(\nabla,x\ntermeq K)} & \text{otherwise} \\
  \end{cases} \\
  \addinert{\ctxt{\Gamma}{\nabla}}{x \termeq \bot} &=& \begin{cases}
    \bot & \text{if $x \ntermeq \bot \in \nabla$} \\
    \ctxt{\Gamma}{(\nabla,x\termeq \bot)} & \text{otherwise} \\
  \end{cases} \\
  \addinert{\ctxt{\Gamma}{\nabla}}{x \ntermeq \bot} &=& \begin{cases}
    \bot & \text{if $x \termeq \bot \in \nabla$} \\
    \bot & \text{if not $\inh{\ctxt{\Gamma}{(\nabla,x\ntermeq\bot)}}{x}$} \\
    \ctxt{\Gamma}{(\nabla,x\ntermeq \bot)} & \text{otherwise} \\
  \end{cases} \\
  \addinert{\ctxt{\Gamma}{\nabla}}{\ctlet{x}{y}} &=& \begin{cases}
    \ctxt{\Gamma}{\nabla} & \text{if $\nabla(x) = z = \nabla(y)$} \\
    \addinert{\ctxt{\Gamma}{\nabla}, \ctlet{x}{y}}{\bigwedge \{ \delta \in \nabla \cap x \mid \text{x in $\delta$ renamed to y} \}} & \text{if $\nabla(x) \not= z$ or $\nabla(y) \not= z$} \\
  \end{cases} \\
  \addinert{\ctxt{\Gamma}{\nabla}}{\ctlet{x}{\genconapp{K}{\tau}{\gamma}{e'}}} &=& \addinert{\addinert{\addinert{\ctxt{\Gamma,\overline{a},\overline{y:todo}}{\nabla}}{\ctcon{\genconapp{K}{a}{\gamma}{y}}{x}}}{\overline{a \typeeq \tau}}}{\overline{\ctlet{y}{e'}}} \text{ where $\overline{a \# \Gamma}$, $\overline{y:todo \# (\Gamma, \overline{a})}$} \\ 
  \addinert{\ctxt{\Gamma}{\nabla}}{\ctlet{x}{e}} &=& \ctxt{\Gamma}{\nabla} \\

\end{array}
\]
\[ \textbf{Test if $x$ is inhabited considering $\nabla$} \]
\[ \ruleform{ \inh{\ctxt{\Gamma}{\nabla}}{x} } \]
\[
\begin{array}{c}

  \prooftree
    (\addinert{\ctxt{\Gamma}{\nabla}}{x \termeq \bot}) \not= \bot
  \justifies
    \inh{\ctxt{\Gamma}{\nabla}}{x}
  \endprooftree

  \quad

  \prooftree
    \Shortstack{{x:\tau \in \Gamma \quad K:\sigma \in \mathsf{Cons}(\ctxt{\Gamma}{\nabla},\tau)}
                {instantiate}
               {(\addinert{\ctxt{\Gamma,\overline{y:\tau'}}{\nabla}}{\ctcon{\genconapp{K}{a}{\gamma}{y}}{x}}) \not= \bot}}
  \justifies
    \inh{\ctxt{\Gamma}{\nabla}}{x}
  \endprooftree

\end{array}
\]
\end{figure}


























\begin{figure}[t]
\centering
\[ \textbf{Construct inhabited $\nabla$s from $\Delta$} \]
\[ \ruleform{ \values{\Gamma}{\Delta} = \mathcal{P}(\overline{p}) } \]
\[ \ruleform{ \values{\ctxt{\Gamma}{\nabla}}{\Delta} = \mathcal{P}(\ctxt{\Gamma}{\nabla}) } \]
\[
\begin{array}{lcl}

  \values{\Gamma}{\Delta} &=& \bigcup \left\{ \blah{\ctxt{\Gamma'}{\nabla'}}{\mathsf{fvs}(\Gamma)} \mid \forall (\ctxt{\Gamma'}{\nabla'}) \in \values{\ctxt{\Gamma}{\varnothing}}{\Delta} \right\} \\
  \values{\ctxt{\Gamma}{\nabla}}{\delta} &=& \begin{cases}
    \left\{ \ctxt{\Gamma'}{\nabla'} \right\} & \text{where $\ctxt{\Gamma'}{\nabla'} = \addinert{\ctxt{\Gamma}{\nabla}}{\delta}$} \\
    \emptyset & \text{otherwise} \\
  \end{cases} \\
  \values{\ctxt{\Gamma}{\nabla}}{\Delta_1 \wedge \Delta_2} &=& \bigcup \left\{ \values{\ctxt{\Gamma'}{\nabla'}}{\Delta_2} \mid \forall (\ctxt{\Gamma'}{\nabla'}) \in \values{\ctxt{\Gamma}{\nabla}}{\Delta_1} \right\} \\
  \values{\ctxt{\Gamma}{\nabla}}{\Delta_1 \vee \Delta_2} &=& \values{\ctxt{\Gamma}{\nabla}}{\Delta_1} \cup \values{\ctxt{\Gamma}{\nabla}}{\Delta_2}

\end{array}
\]

\[ \textbf{Expand variables to $\Pat$ with $\nabla$} \]
\[ \ruleform{ \blah{\ctxt{\Gamma}{\nabla}}{\overline{x}} = \mathcal{P}(\overline{p}) } \]
\[
\begin{array}{lcl}

  \blah{\ctxt{\Gamma}{\nabla}}{\epsilon} &=& \{ \epsilon \} \\
  \blah{\ctxt{\Gamma}{\nabla}}{x_1 ... x_n} &=& \begin{cases}
    \left\{ (K \; q_1 ... q_m) \, p_2 ... p_n \mid \forall (q_1 ... q_m \, p_2 ... p_n) \in \blah{\ctxt{\Gamma}{\nabla}}{y_1 ... y_m x_2 ... x_n} \right\} & \text{if $\ctcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x} \in \nabla$} \\
    \left\{ \_ \; p_2 ... p_n \mid \forall (p_2 ... p_n) \in \blah{\ctxt{\Gamma}{\nabla}}{x_2 ... x_n} \right\} & \text{otherwise} \\
  \end{cases} \\

\end{array}
\]
\end{figure}

%\listoftodos\relax

\nocite{*}

%\bibliography{references}

\end{document}

%                       Revision History
%                       -------- -------
%  Date         Person  Ver.    Change
%  ----         ------  ----    ------

%  2013.06.29   TU      0.1--4  comments on permission/copyright notices
