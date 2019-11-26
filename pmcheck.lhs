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
\usepackage{qtree}
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
  \Delta &\Coloneqq& \noDelta \mid \nodelta \mid \Delta, \delta \mid \Delta_1 \vee \Delta_2 & \text{Delta} \\
  \delta &\Coloneqq& \gamma \mid x_1 \termeq x_2 \mid \ctcon{K\;\overline{x:\tau}}{y} \mid x \ntermeq K \mid x \termeq \bot \mid x \ntermeq \bot \mid \ctlet{x}{e} & \text{Constraints} \\
\end{array}
\]
\end{figure}

\pagebreak

\begin{figure}[t]
\centering
\[ \textbf{Clause tree} \]
\[
\begin{array}{rcl}
  \T[r] &\Coloneqq& \trhs \\
        &\mid     & \tmany{\overline{r}} \\
  \\
  t_G \in \Gdt &\Coloneqq& \T[t_G] \\
               &\mid&      \gdtguard{g}{t_G} \\
  \\
  t_C \in \Ctt &\Coloneqq& \T[t_C] \\
               &\mid&      \cttdiv{\delta}{t_C} \\
               &\mid&      \cttft{\delta}{t_C} \\
               &\mid&      \cttref{\delta}{t_C} \\
  \\
  t_A \in \Ant &\Coloneqq& \T[t_A] \\
               &\mid&      \antdiv{t_A} \\
               &\mid&      \antred{t_A} \\
\end{array}
\]

\[ \textbf{Compiling constraint trees} \]
\[ \ruleform{ \cct{\Gdt} = \Ctt } \]
\[
\begin{array}{lcl}
\cct{\trhs{}} &=& \trhs{} \\
\cct{\tmany{\overline{t_G}}} &=& \tmany{\overline{\cct{t_G}}} \\
\cct{\gdtguard{(\grdlet{x}{e})}{t_G}} &=& \cctg{g}{(\cct{t_G})} \\
\cctg{(\grdlet{x}{e})} &=& \cttref{(\ctlet{x}{e})} \\
\cctg{(\grdbang{x})} &=& \cttdiv{(x\termeq\bot)} \circ \cttref{(x\ntermeq\bot)} \\
\cctg{\gdtguard{(\grdbang{x})}} &=& \cttdiv{(x\termeq\bot)} \circ \cttref{(x\ntermeq\bot)} \\
\cct{\gdtguard{(\grdcon{\genconapp{K}{a}{\gamma}{y:\tau}}{x})}{t_G}} &=& \cttdiv{(x\termeq\bot)}{(\cttdiv{(x\termeq\bot)}{(\cttref{(x\termeq \ctcon{K\;\overline{x:\tau}}{y})}{\ctt{t_G}})})} \\
\end{array}
\]

\end{figure}

\section{Problems with \ctt{}{}}

\ctt is rather simple now, but it assumes that the incoming $\Delta$ is
basically unconstrained (e.g. \nodelta). But that certainly is not true for any
clause after the first! Intuitively, we replace all leafs in the incoming
$\Delta$ (which are \nodelta, since we can immediately prune $\noDelta$).
Example:

\begin{verbatim}
data T = A | B | C
f A A = ()
f B B = ()
f C C = ()
\end{verbatim}

We start with $\{ (x, y) | \nodelta \}$ for the uncovered set. After the first
clause, we have $\{ (x, y) | (x \ntermeq A,\nodelta) \vee (\ctcon{A}{x},y
\ntermeq A, \nodelta) \}$ for the uncovered set flowing into the second clause.

The result of \ctt applied to the second clause is $(x \ntermeq B,\nodelta)
\vee (\ctcon{B}{x},y \ntermeq B, \nodelta)$. But that doesn't consider the
incoming uncovered set! For that, we have to substitute every \nodelta in the
incoming uncovered set by the constraint tree we just computed.

In tree form. Incoming $\Delta$:

\Tree[.$\vee$ 
  [.\texttt{x/=A} [.$\nodelta$ ]]
  [.\texttt{A<-x} [.\texttt{y/=A} [.$\nodelta$ ]]]
]

$\Delta$ from \ctt on the second clause:

\Tree[.$\vee$ 
  [.\texttt{x/=B} [.$\nodelta$ ]]
  [.\texttt{B<-x} [.\texttt{y/=B} [.$\nodelta$ ]]]
]

Substituted into the first $\Delta$:

\Tree[.$\vee$ 
  [.\texttt{x/=A}
    [.$\vee$ 
      [.\texttt{x/=B} [.$\nodelta$ ]]
      [.\texttt{B<-x} [.\texttt{y/=B} [.$\nodelta$ ]]]]]
  [.\texttt{A<-x}
    [.\texttt{y/=A}
      [.$\vee$ 
        [.\texttt{x/=B} [.$\nodelta$ ]]
        [.\texttt{B<-x} [.\texttt{y/=B} [.$\nodelta$ ]]]]]]]

Note that we now have 4 \nodelta{}s. So this substitution step reintroduces the exponential blowup.

That alone wouldn't be a problem: Currently, we also would have 4 $\Delta$s in
flight for this program. But if we execute on the plan here to separately
translate $\Grd$ into $\Con$ trees for each clause, and then only
\emph{afterwards} (after the substitution step, that is) check for inhabitants (which is conceptually very beautiful),
we run into efficiency problems in the implementation, because we have no way
to share the work involved with checking the \emph{very similar} branches we
just substituted.

It's a lot like choosing the most efficient evaluation strategy, really! Doing
the substitution before we digest the tree into a more computably tractable
form (like in the current implementation where we cache residual COMPLETE
sets) is a lot like call-by-name and we get asymptotically behavior in
supposedly trivial cases. The current implementation is more like call-by-value
in that regard.

Example, inspired by the test case \texttt{ManyAlternatives}:

\begin{verbatim}
data T = T1 | ... | T1000
f T1    = ()
...
f T1000 = ()
\end{verbatim}

The constraint tree of the \emph{covered} set of the 1000th clause will look like this:

\Tree[.\texttt{T1000<-x} [.... [.\texttt{x/=T999} [.\texttt{x/=T1} [.$\nodelta$ ]]]]]

The other covered sets are similar. In order to determine whether a clause is
redundant, we have to check each of these covered sets for inhabitants! But
with COMPLETE sets, we have to constantly check whether the negative
constraints form a COMPLETE set. That's very inefficient! And it's the reason
we currently have the \texttt{vi\_cache} field in \texttt{VarInfo}: For
gradually deleting candidates from the residual COMPLETE sets when we move from
clause to clause instead of always beginning from scratch (the full COMPLETE
set) at each clause and thinning it out with linearly many negative constraints.

So we definitely want the same kind of caching in our new constraint tree
representation. Now here's the problem: I don't currently see how! Intuitively,
sharing of work is only possible along the shared path from the root of the
final constraint tree we check for inhabitants to one of its leafs. Note how
that's not possible in the tree above, because each tree will have a different
root, so no sharing on any such paths! If we had the following constraint trees
instead:

\Tree[.\texttt{x/=T1} [.... [.\texttt{x/=T999} [.\texttt{T1000<-x} [.$\nodelta$ ]]]]]

I.e. with the order of inner nodes reversed, we could share residual COMPLETE
sets along the shared path prefix. E.g. the the clause for \texttt{T500} could
re-use the residual COMPLETE sets from \texttt{T499}, like it's currently the
case.

To achieve this, we have to roll back to the old constraint tree generation
scheme, where we pass the incoming $\Delta$ to \ctt.
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
