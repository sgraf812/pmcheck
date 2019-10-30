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
\[ \textbf{Pattern Syntax} \]
\[
\begin{array}{rlcl}
  K           \in &\Con &         & \\
  x,y,a,b     \in &\Var &         & \\
  \tau,\sigma \in &\Type&         & \\
  e \in           &\Expr&\Coloneqq& x:\tau \\
                  &     &\mid     & \genconapp{K}{a}{\gamma}{e:\tau} \\
                  &     &\mid     & ... \\

  \gamma \in      &\TyCt&\Coloneqq& \tau_1 \typeeq \tau_2 \mid ... \\

  g \in           &\Grd &\Coloneqq& \grdlet{x:\tau}{e} \\
                  &     &\mid     & \grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x} \\
                  &     &\mid     & \grdbang{x} \\
\end{array}
\]
\[ \textbf{Oracle Syntax} \]
\[
\begin{array}{rcll}
  \Gamma &\Coloneqq& \varnothing \mid \Gamma, x:\tau \mid \Gamma, a & \text{Context} \\
  \Theta &\Coloneqq& \noDelta \mid \Gamma \vdash \Delta \mid \Theta_1 \vee \Theta_2 & \text{"Deltas"} \\
  \Delta &\Coloneqq& \nodelta \mid \Delta \wedge \delta & \text{Delta} \\
  \delta &\Coloneqq& \gamma \mid x_1 \termeq x_2 \mid x \termeq K\;\overline{y} \mid x \ntermeq K \mid x \termeq \bot \mid x \ntermeq \bot \mid x \termeq e & \text{Constraints} \\
\end{array}
\]
\[ \textbf{Adding Constraints} \]
\[
\begin{array}{rcrcl}
  \noDelta &\plustheta& \delta &=& \noDelta \\
  \Gamma \vdash \Delta&\plustheta& \delta &=& \Gamma \vdash \Delta \wedge \delta \\
  \Theta_1 \vee \Theta_2 &\plustheta& \delta &=& (\Theta_1 \plustheta \delta) \vee (\Theta_2 \plustheta \delta) \\
\end{array}
\]
\[ \textbf{Binding Free Variables} \]
\[
\begin{array}{rcrcl}
  \noDelta &\plusgamma& x:\tau &=& \noDelta \\
  \Gamma \vdash \Delta&\plusgamma& x:\tau &=& \Gamma,x:\tau \vdash \Delta \\
  \Theta_1 \vee \Theta_2 &\plusgamma& x:\tau &=& (\Theta_1 \plusgamma x:\tau) \vee (\Theta_2 \plusgamma x:\tau) \\
\end{array}
\]
\end{figure}

\pagebreak

\begin{figure}[t]
\centering
\[ \textbf{Pattern-match Result} \]
\[
\begin{array}{c}
  r \Coloneqq \langle \Theta_u, \Theta_d, \Theta_c \rangle \\
  \\
  \langle \Theta_u, \Theta_d, \Theta_c \rangle \extunc \Theta = \langle \Theta_u \vee \Theta, \Theta_d, \Theta_c \rangle \\
  \langle \Theta_u, \Theta_d, \Theta_c \rangle \extdiv \Theta = \langle \Theta_u, \Theta_d \vee \Theta, \Theta_c \rangle \\
  %\langle \Theta_u, \Theta_d, \Theta_c \rangle \extcov \Theta = \langle \Theta_u, \Theta_d, \Theta_c \vee \Theta \rangle \\
\end{array}
\]
\[ \textbf{Pattern-match checking} \]
\[ \ruleform{ \pmc{\overline{\Theta}}{\overline{\Grd}} = r } \]
\[
\begin{array}{lcl}

\pmc{\Gamma}{\Theta}{\epsilon} &=& \langle \noDelta, \noDelta, \Theta \rangle \\
\pmc{\Gamma}{\Theta}{(\grdlet{x:\tau}{e}\:\overline{g})} &=& \pmc{\Gamma}{(\Theta \plusgamma x:\tau \plustheta x \termeq e)}{\overline{g}} \\
\pmc{\Gamma}{\Theta}{(\grdbang{x}\:\overline{g})} &=& \pmc{\Gamma}{(\Theta \plustheta x \ntermeq \bot)}{\overline{g}} \\
                                                     & & \enspace \extdiv\;\Theta \plustheta x \termeq \bot \\
\pmc{\Gamma}{\Theta}{(\grdcon{\genconapp{K}{a}{\gamma}{x:\tau}}{y}\:\overline{g})} &=& \pmc{\Gamma}{(\Theta \overline{\plusgamma a} \, \overline{\plusgamma x:\tau} \, \overline{\plustheta \gamma} \plustheta y \termeq K\;\overline{x})}{\overline{g}} \\
                                                  & & \enspace \extdiv\;\Theta \plustheta x \termeq \bot \\
                                                  & & \enspace \extunc\;\Theta \plustheta x \ntermeq K \\

\end{array}
\]
\end{figure}

\pagebreak

\begin{figure}[t]
\centering
\[ \textbf{Pattern-match Result} \]
\[ \ruleform{ \texttt{ClauseResult} } \]
\[
\begin{array}{rlcl}
  c \in &\texttt{Coverage}     &\Coloneqq& \texttt{Redundant} \\
        &                      &\mid     & \texttt{RhsInaccessible} \\
        &                      &\mid     & \texttt{RhsReachable} \\
  \\
  r \in &\texttt{ClauseResult} &\Coloneqq& \langle \overline{\Delta}, \texttt{Coverage} \rangle \\
  \\
        &       \texttt{empty} & =       & \langle \noDelta, \texttt{Redundant} \rangle \\
  \\
\end{array}
\]
\[ \ruleform{ r \extdiv \overline{\Delta} } \]
\[
\begin{array}{rclcl}
  \langle \overline{\Delta_u}, \texttt{Redundant} \rangle &\extdiv& \overline{\Delta_d} &=& \langle \overline{\Delta_u}, \texttt{RhsInaccessible} \rangle \text{  if any $\Delta_d$ inhabited} \\
  r                                                       &\extdiv& \textunderscore{}     &=& r \\
\end{array}
\]
\[ \ruleform{ r \extcov \overline{\Delta} } \]
\[
\begin{array}{rclcl}
  \langle \overline{\Delta_u}, \textunderscore \rangle    &\extcov& \overline{\Delta_c} &=& \langle \overline{\Delta_u}, \texttt{Covered} \rangle \text{  if any $\Delta_c$ inhabited} \\
  r                                                       &\extcov& \textunderscore{}     &=& r \\
\end{array}
\]
\[ \ruleform{ r \extunc \overline{\Delta} } \]
\[
\begin{array}{rclcl}
  \langle \overline{\Delta_u}, c               \rangle    &\extunc& \overline{\Delta_{u'}} &=& \langle \overline{\Delta_u}\,\overline{\Delta_{u'}}, c \rangle
\end{array}
\]
\[ \textbf{Pattern-match checking} \]
\[ \ruleform{ \pmc{\overline{\Delta}}{\overline{\Grd}} = r } \]
\[
\begin{array}{lcl}

\pmc{\overline{\Delta}}{\epsilon} &=& \texttt{empty} \extcov \overline{\Delta} \\
\pmc{\overline{\Delta}}{(\grdlet{x:\tau}{e}\:\overline{g})} &=& \pmc{\overline{\Delta \plustheta x:\tau \plustheta x \termeq e}}{\overline{g}} \\
\pmc{\overline{\Delta}}{(\grdbang{x}\:\overline{g})} &=& \pmc{\overline{\Delta \plustheta x \ntermeq \bot}}{\overline{g}} \\
                                                     & & \enspace \extdiv\;\overline{\Delta \plustheta x \termeq \bot} \\
\pmc{\overline{\Delta}}{(\grdcon{\genconapp{K}{a}{\gamma}{x:\tau}}{y}\:\overline{g})} &=& \pmc{\overline{\Delta \plustheta \overline{a} \plustheta \overline{\gamma} \plustheta \overline{x:\tau} \plustheta x \termeq \genconapp{K}{a}{\gamma}{x:\tau}}}{\overline{g}} \\
                                                                                        & & \enspace \extdiv\;\overline{\Delta \plustheta x \termeq \bot} \\
                                                                                        & & \enspace \extunc\;\overline{\Delta \plustheta x \ntermeq K} \\

\end{array}
\]
\end{figure}

\pagebreak










































% TODO: mention the vs? I don't think so, satisfiability of Delta should
% implicitly cover *every* variable in Gamma. But we might want to reduce
% this to explictly passed vs anyway, because how would we recurse otherwise?
\begin{figure}[t]
\centering
\[ \textbf{Test if Oracle state Delta is unsatisfiable} \]
\[\ruleform{ \unsat{\Gamma \vdash \Delta} }  \]
\[
\begin{array}{c}

  % TODO: Fix unforunate kind of ambiguous syntax
  \prooftree
    \unsat{\vtupnew{\Gamma}{fvs \Gamma}{\Delta}}
  \justifies
    \unsat{\Gamma \vdash \Delta}
  \endprooftree

  \\ \\

\end{array}
\]
\[ \textbf{Test a list of SAT roots for inhabitants} \]
\[\ruleform{ \unsat{\vtupnew{\Gamma}{\overline{x}}{\Delta}} }  \]
\[
\begin{array}{c}

  \prooftree
    \unsat{\vtupnew{\Gamma}{x_i}{\Delta}}
  \justifies
    \unsat{\vtupnew{\Gamma}{\overline{x}}{\Delta}}
  \endprooftree

  \\ \\

\end{array}
\]
\[ \textbf{Test a single SAT root for inhabitants} \]
\[\ruleform{ \unsat{\vtupnew{\Gamma}{x}{\Delta}} }  \]
\[
\begin{array}{c}

  \prooftree
    \unsat{\Gamma \vdash \plustheta{\Delta}{x \termeq \bot}}
    \quad
    \text{$\{\overline{K}\}$ COMPLETE set}
    \quad
    % TODO: Lacks bindings for K's type variables
    % TODO: \forall instantiation :( Although type-checker helps here
    \overline{\forall\overline{y:\tau}.\unsat{\Gamma,\overline{y:\tau} \vdash \plustheta{\Delta}{x \termeq K\;\overline{y}}}}
  \justifies
    \unsat{\vtupnew{\Gamma}{x}{\Delta}}
  \endprooftree

  \\ \\

\end{array}
\]
\[ \textbf{Add a single equality to $\Delta$} \]
\[\ruleform{ \unsat{\Gamma \vdash \plustheta{\Delta}{\delta}} }  \]
\[
\begin{array}{c}
  \text{Term stuff: Bottom, negative info, positive info + generativity, positive info + univalence}

  \\ \\

  \prooftree
    x \ntermeq sth \in \Delta
  \justifies
    \unsat{\Gamma \vdash \plustheta{\Delta}{x \termeq \bot}}
  \endprooftree

  \qquad

  \prooftree
    x \termeq K\;\overline{y} \in \Delta
  \justifies
    \unsat{\Gamma \vdash \plustheta{\Delta}{x \termeq \bot}}
  \endprooftree

  \\ \\

  \prooftree
    x \ntermeq K \in \Delta
  \justifies
    % TODO: well-formedness... Gamma must bind x and ys
    \unsat{\Gamma \vdash \plustheta{\Delta}{x \termeq K\;\overline{y}}}
  \endprooftree

  \qquad

  \prooftree
    x \termeq K_i\;\overline{y}\in \Delta \quad i \neq j \quad \text{$K_i$ and $K_j$ generative}
  \justifies
    \unsat{\Gamma \vdash \plustheta{\Delta}{x \termeq K_j \;\overline{z}}}
  \endprooftree

  \\ \\

  \prooftree
    x \termeq K\;\overline{\tau}\;\overline{y}\in \Delta \quad \unsat{\Gamma \vdash \plustheta{\Delta}{\tau_i \typeeq \sigma_i}}
  \justifies
    \unsat{\Gamma \vdash \plustheta{\Delta}{x \termeq K \;\overline{\sigma} \;\overline{z}}}
  \endprooftree

  \qquad

  \prooftree
    x \termeq K\;\overline{\tau}\;\overline{y}\in \Delta \quad \unsat{\Gamma \vdash \plustheta{\Delta}{y_i \termeq z_i}}
  \justifies
    \unsat{\Gamma \vdash \plustheta{\Delta}{x \termeq K \;\overline{\sigma} \;\overline{z}}}
  \endprooftree

  \\ \\

  \text{Type stuff: Hand over to unspecified type oracle}

  \\ \\

  \prooftree
    \text{$\tau_1$ and $\tau_2$ incompatible to Givens in $\Delta$ according to type oracle}
  \justifies
    \unsat{\Gamma \vdash \plustheta{\Delta}{\tau_1 \typeeq \tau_2}}
  \endprooftree

  \\ \\

  \text{Mixed: Instantiate K and see if that leads to a contradiction TODO: Proper instantiation}

  \\ \\

  \prooftree
    \overline{\unsat{\vtupnew{\Gamma}{y}{\Delta \cup y \ntermeq \bot}}}
    \quad
  \justifies
    \unsat{\Gamma \vdash \plustheta{\Delta}{x \termeq K\;\overline{y}}}
  \endprooftree

\end{array}
\]
\end{figure}

\listoftodos\relax

\nocite{*}

\bibliography{references}

\end{document}

%                       Revision History
%                       -------- -------
%  Date         Person  Ver.    Change
%  ----         ------  ----    ------

%  2013.06.29   TU      0.1--4  comments on permission/copyright notices
