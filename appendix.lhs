%include custom.fmt

\renewcommand\thefigure{\thesection.\arabic{figure}}

\subsection{Literals}

The source syntax in fig. 1 deliberately left out literal
patterns $l$. Literals are very similar to nullary data constructors, with one
caveat: They don't come with a builtin \texttt{COMPLETE} set. Before section
4.5, that would have meant quite a bit of hand waving and complication to the
$\inhabited{}{}$ judgment. Now, literals can be handled like disjunct pattern
synonyms (\ie $l_1 \cap l_2 = \emptyset$ for any two literals $l_1, l_2$)
without a \texttt{COMPLETE} set!

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
\begin{array}{c}
  \prooftree
    \Shortstack{{(\nreft{\Gamma}{\Delta} \adddelta x \termeq \bot) \not= \false}
                {\highlight{x:\tau \in \Gamma \quad \text{$\tau$ not a Newtype}}}}
  \justifies
    \inhabited{\nreft{\Gamma}{\Delta}}{x}
  \using
    \inhabitedbot
  \endprooftree

  \qquad

  \prooftree
    \Shortstack{{x:\tau \in \Gamma \quad \cons(\nreft{\Gamma}{\Delta}, \tau)=\overline{C_1,...,C_{n_i}}^i}
                {\overline{\inst(\nreft{\Gamma}{\Delta}, x, C_j) \not= \false}^i \quad \highlight{\text{$\tau$ not a Newtype}}}}
  \justifies
    \inhabited{\nreft{\Gamma}{\Delta}}{x}
  \using
    \inhabitedinst
  \endprooftree

  \\
  \\

  \highlight{\prooftree
    \Shortstack{{\text{$\tau$ Newtype with constructor |N| wrapping $\sigma$}}
                {x:\tau \in \Gamma \quad y \freein \Gamma \quad \inhabited{\nreft{\Gamma,y:\sigma}{\Delta} \adddelta x \termeq |N y|}{|y|}}}
  \justifies
    \inhabited{\nreft{\Gamma}{\Delta}}{x}
  \using
    \inhabitedinst
  \endprooftree}
\end{array}
\]

\[
\begin{array}{r@@{\,}c@@{\,}lcl}
  \nreft{\Gamma}{\Delta} &\adddelta& x \termeq \bot &=& \begin{cases}
    \false & \text{if $\rep{\Delta}{x} \ntermeq \bot \in \Delta$} \\
    \highlight{\nreft{\Gamma}{\Delta} \adddelta x \termeq |N y| \adddelta y \termeq \bot} & \parbox{0.6\textwidth}{if $x:\tau \in \Gamma$, $\tau$ Newtype with \\ constructor |N| wrapping $\sigma$} \\
    \nreft{\Gamma}{(\Delta,\rep{\Delta}{x}\termeq \bot)} & \text{otherwise} \\
  \end{cases} \\
  \nreft{\Gamma}{\Delta} &\adddelta& x \ntermeq \bot &=& \begin{cases}
    \false & \text{if $\rep{\Delta}{x} \termeq \bot \in \Delta$} \\
    \false & \text{if not $\inhabited{\nreft{\Gamma}{(\Delta,\rep{\Delta}{x}\ntermeq\bot)}}{\rep{\Delta}{x}}$} \\
    \highlight{\nreft{\Gamma}{\Delta} \adddelta x \termeq |N y| \adddelta y \ntermeq \bot} & \parbox{0.6\textwidth}{if $x:\tau \in \Gamma$, $\tau$ Newtype with \\ constructor |N| wrapping $\sigma$} \\
    \nreft{\Gamma}{(\Delta,\rep{\Delta}{x} \ntermeq \bot)} & \text{otherwise} \\
  \end{cases} \\
\end{array}
\]

\caption{Extending coverage checking to handle Newtypes}
\label{fig:newtypes}
\end{figure}

Newtypes have strange semantics. Here are three key examples that distinguish
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
lead to divergence for a call site like |f bot False|, so the third GRHS is
\emph{inaccessible} (because every value it could cover was already covered by
the first GRHS), but not redundant. A perhaps surprising consequence is that
the definition of |f| is exhaustive, because after |N Void| was deprived of its
sole inhabitant $\bot \equiv N\,\bot$ by the third GRHS, there is nothing left
to match on.

\Cref{fig:newtypes} outlines a solution (based on that for pattern synonyms for
brevity) that handles |f| correctly. The idea is to treat Newtype pattern
matches lazily (so compared to data constructor matches, $\ds$ omits the
$\grdbang{x}$). The other significant change is to the $\inhabited{}{}$
judgment form, where we introduce a new rule \inhabitednt that is specific to
Newtypes, which can no longer be proven inhabited by either \inhabitedinst or
\inhabitedbot.

But |g1| crushes this simple hack. We would mark its second GRHS as
inaccessible when it is clearly redundant, because the $x \ntermeq \bot$
constraint on the match variable |x| wasn't propagated to the wrapped |()|.
The inner bang pattern has nothing to evaluate.

\sg{We could save about 1/4 of a page by stopping here and omitting the
changes to $\adddelta$.}

We counter that with another refinement: We just add $|x| \termeq N y$ and $|y|
\ntermeq \bot$ constraints whenever we add $|x| \ntermeq \bot$ constraints when
we know that |x| is a Newtype with constructor |N| (similarly for $|x| \termeq
\bot$). Both |g1| and |g2| will be handled correctly.

\sg{Needless to say, we won't propagate $\bot$ constraints when we only find
out (by additional type info) that something is a Newtype \emph{after} adding
the constraints (think |SMaybe a| and we later find that $a \typeeq |N Void|$),
but let's call it a day.}

An alternative, less hacky solution would be treating Newtype wrappers as
coercions and at the level of $\Delta$ consider equivalence classes modulo
coercions. That entails a slew of modifications and has deep ramifications
throughout the presentation.

\subsection{Strictness and totality}

Instead of extending the source language, let's discuss ripping out a language
feature, for a change! So far, we have focused on Haskell as the source
language, which is lazy by default. Although after desugaring  the difference
in evaluation strategy of the source language becomes irrelevant, it raises the
question of how much our approach could be simplified if we targeted a source
language that was strict by default, such as OCaml or
Idris.

First off, both languages offer language support for laziness and lazy pattern
matches, so the question rather becomes whether the gained simplification is
actually worth risking unusable or even unsound warning messages when making
use of laziness. If the answer is ``No'', then there isn't anything to
simplify, just relatively more $x \termeq \bot$ constraints to handle.

Otherwise, in a completely eager language we could simply drop $\grdbang{x}$
from $\Grd$ and $\antbang{}{\hspace{-0.6em}}$ from $\Ant$. Actually, $\Ant$ and
$\red$ could go altogether and $\ann$ could just collect the redundant GRHS
directly! Since there wouldn't be any bang guards, there is no reason to have
$x \termeq \bot$ and $x \ntermeq \bot$ constraints either. Most importantly,
the \inhabitedbot judgment form has to go, because $\bot$ does not inhabit any
types anymore.

Note that in a total language, reasoning about $x \termeq \bot$ makes no sense
to begin with! All the same simplifications apply.
