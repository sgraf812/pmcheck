%include custom.fmt

\renewcommand\thefigure{\thesection.\arabic{figure}}

\subsection{Literals}

The source syntax in \Cref{fig:newtypes} deliberately left out literal
patterns $l$. Literals are very similar to nullary data constructors, with one
caveat: They don't come with a builtin \texttt{COMPLETE} set. Before Section
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

\subsection{newtypes}

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
                {\highlight{x:\tau \in \Gamma \quad \text{$\tau$ not a newtype}}}}
  \justifies
    \inhabited{\nreft{\Gamma}{\Delta}}{x}
  \using
    \inhabitedbot
  \endprooftree

  \qquad

  \prooftree
    \Shortstack{{x:\tau \in \Gamma \quad \cons(\nreft{\Gamma}{\Delta}, \tau)=\overline{C_1,...,C_{n_i}}^i}
                {\overline{\inst(\nreft{\Gamma}{\Delta}, x, C_j) \not= \false}^i \quad \highlight{\text{$\tau$ not a newtype}}}}
  \justifies
    \inhabited{\nreft{\Gamma}{\Delta}}{x}
  \using
    \inhabitedinst
  \endprooftree

  \\
  \\

  \highlight{\prooftree
    \Shortstack{{\text{$\tau$ newtype with constructor |N| wrapping $\sigma$}}
                {x:\tau \in \Gamma \quad y \freein \Gamma \quad \inhabited{\nreft{\Gamma,y:\sigma}{\Delta} \adddelta x \termeq |N y|}{|y|}}}
  \justifies
    \inhabited{\nreft{\Gamma}{\Delta}}{x}
  \using
    \inhabitednt
  \endprooftree}
\end{array}
\]

\[
\begin{array}{r@@{\,}c@@{\,}lcl}
  \nreft{\Gamma}{\Delta} &\adddelta& x \termeq \bot &=& \begin{cases}
    \false & \text{if $\rep{\Delta}{x} \ntermeq \bot \in \Delta$} \\
    \highlight{\nreft{\Gamma}{\Delta} \adddelta x \termeq |N y| \adddelta y \termeq \bot} & \parbox{0.6\textwidth}{if $x:\tau \in \Gamma$, $\tau$ newtype with \\ constructor |N| wrapping $\sigma$} \\
    \nreft{\Gamma}{(\Delta,\rep{\Delta}{x}\termeq \bot)} & \text{otherwise} \\
  \end{cases} \\
  \nreft{\Gamma}{\Delta} &\adddelta& x \ntermeq \bot &=& \begin{cases}
    \false & \text{if $\rep{\Delta}{x} \termeq \bot \in \Delta$} \\
    \false & \text{if not $\inhabited{\nreft{\Gamma}{(\Delta,\rep{\Delta}{x}\ntermeq\bot)}}{\rep{\Delta}{x}}$} \\
    \highlight{\nreft{\Gamma}{\Delta} \adddelta x \termeq |N y| \adddelta y \ntermeq \bot} & \parbox{0.6\textwidth}{if $x:\tau \in \Gamma$, $\tau$ newtype with \\ constructor |N| wrapping $\sigma$} \\
    \nreft{\Gamma}{(\Delta,\rep{\Delta}{x} \ntermeq \bot)} & \text{otherwise} \\
  \end{cases} \\
\end{array}
\]

\caption{Extending coverage checking to handle newtypes}
\label{fig:newtypes}
\end{figure}

In Haskell, a newtype declares a new type that is completely
isomorphic to, but distinct from, an existing type. For example
\begin{code}
newtype NT a = MkNT [a]

dup :: NT a -> NT a
dup (MkNT xs) = MkNT (xs ++ xs)
\end{code}
Here the type |NT a| is isomorphic to |[a]|.  We convert to and fro
using the ``data constructor'' |MkNT|, either as in a term or in a pattern.

To a first approximation, then, programmers interact with a newtype
as if it was a data type with a single constructor with a single field.
But their pattern-matching semantics is different!
Here are three key examples that distinguish newtypes from data types.
Functions |g1|,|g2|,|g3| match on a \emph{newtype} |N|, while functions
|h1|,|h2|,|h3| match on a \emph{data type} |D|:

\begin{minipage}{\textwidth}
\begin{minipage}[b]{0.33\textwidth}
\centering
\begin{code}
newtype N a = MkN a
g1 :: N Void -> Bool -> Int
g1 _        True   = 1
g1 (MkN _)  True   = 2  -- R
g1 !_       True   = 3  -- I
\end{code}
\end{minipage}%
\begin{minipage}[b]{0.33\textwidth}
\centering
\begin{code}
g2 :: N () -> Bool -> Int
g2 !!(MkN _)   True  = 1
g2   (MkN !_)  True  = 2  -- R
g2         _   _     = 3
\end{code}
\end{minipage}%
\begin{minipage}[b]{0.33\textwidth}
\centering
\begin{code}
g3 :: N () -> Bool -> Int
g3   (MkN !_)  True  = 1
g3 !!(MkN _)   True  = 2  -- R
g3       _     _     = 3
\end{code}
\end{minipage}
\begin{minipage}[b]{0.33\textwidth}
\centering
\begin{code}
data D a = MkD a
h1 :: D Void -> Bool -> Int
h1 _        True   = 1
h1 (MkD _)  True   = 2  -- I
h1 !_       True   = 3  -- R
\end{code}
\end{minipage}%
\begin{minipage}[b]{0.33\textwidth}
\centering
\begin{code}
h2 :: D () -> Bool -> Int
h2 !!(MkD _)   True  = 1
h2   (MkD !_)  True  = 2  -- I
h2         _   _     = 3
\end{code}
\end{minipage}%
\begin{minipage}[b]{0.33\textwidth}
\centering
\begin{code}
h3 :: D () -> Bool -> Int
h3   (MkD !_)  True  = 1
h3 !!(MkD _)   True  = 2  -- R
h3       _     _     = 3
\end{code}
\end{minipage}
\end{minipage}
\noindent
If the first equation of |h1| fails to match (because the second argument is |False|),
the second equation may diverge when matching against |(MkD _)|,
or may fail (because of the |False|), so the equation is inaccessible (marked I).
The third equation is redundant (marked R).
But for a newtype, the second equation of |g1| will not evaluate the argument
when matching against |(MkN _)|, and hence is redundant (R).
The third equation will evaluate the first argument, wihch is surely bottom,
so matching will diverge and the equation is inaccessible (I).
A perhaps surprising consequence is that
the definition of |g1| is exhaustive, because after |N Void| was deprived of its
sole inhabitant $\bot \equiv MkN\,\bot$ by the third GRHS, there is nothing left
to match on.

Similar subtle reasoning applies to |g2|/|h2| and |g3|/|h3|.

\Cref{fig:newtypes} outlines a solution (based on that for pattern synonyms for
brevity) that handles |g1| correctly. The idea is to treat newtype pattern
matches lazily (so compared to data constructor matches, $\ds$ omits the
$\grdbang{x}$). The other significant change is to the $\inhabited{}{}$
judgment form, where we introduce a new rule \inhabitednt that is specific to
newtypes, which can no longer be proven inhabited by either \inhabitedinst or
\inhabitedbot.

But |g2| crushes this simple hack. We would mark its second GRHS as
inaccessible when it is clearly redundant, because the $x \ntermeq \bot$
constraint on the match variable |x| wasn't propagated to the wrapped |()|.
The inner bang pattern has nothing to evaluate.

\sg{We could save about 1/4 of a page by stopping here and omitting the
changes to $\adddelta$.}

We counter that with another refinement: We just add $|x| \termeq MkN y$ and $|y|
\ntermeq \bot$ constraints whenever we add $|x| \ntermeq \bot$ constraints when
we know that |x| is a newtype with constructor |MkN| (similarly for $|x| \termeq
\bot$). Both |g2| and |g3| will be handled correctly.

\sg{Needless to say, we won't propagate $\bot$ constraints when we only find
out (by additional type info) that something is a newtype \emph{after} adding
the constraints (think |SMaybe a| and we later find that $a \typeeq |MkN Void|$),
but let's call it a day.}

An alternative, less hacky solution would be treating newtype wrappers as
coercions and at the level of $\Delta$ consider equivalence classes modulo
coercions. That entails a slew of modifications and has deep ramifications
throughout the presentation.

\subsection{Strictness and totality}

Instead of extending the source language, let's discuss ripping out a language
feature, for a change! So far, we have focused on Haskell as the source
language, which is lazy by default. Although after desugaring  the difference
in evaluation strategy of the source language becomes irrelevant, it raises the
question of how much our approach could be simplified if we targeted a source
language that was strict by default, such as OCaml or Idris (or even Rust).

First off, both languages offer language support for laziness and lazy pattern
matches, so the question rather becomes whether the gained simplification is
actually worth risking unusable or even unsound warning messages when making
use of laziness. If the answer is ``No'', then there isn't anything to
simplify, just relatively more $x \ntermeq \bot$ constraints to handle.

Otherwise, in a completely eager language we could simply drop $\grdbang{x}$
from $\Grd$ and $\antbang{}{\hspace{-0.6em}}$ from $\Ant$. Actually, $\Ant$ and
$\red$ could go altogether and $\ann$ could just collect the redundant GRHS
directly! Since there wouldn't be any bang guards, there is no reason to have
$x \termeq \bot$ and $x \ntermeq \bot$ constraints either. Most importantly,
the \inhabitedbot judgment form has to go, because $\bot$ does not inhabit any
types anymore.

Note that in a total language such as Agda, reasoning about $x \termeq \bot$
makes no sense to begin with! All the same simplifications apply.
