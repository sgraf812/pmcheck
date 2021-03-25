%include custom.fmt

\renewcommand\thefigure{\thesection.\arabic{figure}}

\subsection{Literals}

The source syntax in \Cref{fig:newtypes} deliberately left out literal
patterns $l$. Literals are very similar to nullary data constructors, with one
caveat: they don't come with a builtin \texttt{COMPLETE} set. Before Section
4.5, that would have meant quite a bit of hand waving and complication to the
$\inhabited{}{}$ judgment. Now, literals can be handled like disjoint pattern
synonyms (\ie $l_1 \cap l_2 = \emptyset$ for any two literals $l_1, l_2$)
without a \texttt{COMPLETE} set!

We can even handle overloaded literals, but we will find ourselves in a similar
situation as with pattern synonyms:
\begin{code}
instance Num () where
  fromInteger _ = ()
n = case (0 :: ()) of 1 -> 1; 0 -> 2
\end{code}

\noindent
Considering overloaded literals to be disjoint would mean marking the first
alternative as redundant, which is unsound. Hence we regard overloaded literals
as possibly overlapping, so they behave exactly like nullary pattern synonyms
without a \extension{COMPLETE} set.

\subsection{Newtypes}

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
  \ds(x, N \; pat_1\,...\,pat_n) = \grdcon{N \; y_1\,...\,y_n}{x}, \ds(y_1, pat_1), ..., \ds(y_n, pat_n)
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
Functions |g1|, |g2|, |g3| match on a \emph{newtype} |N|, while functions
|h1|, |h2|, |h3| match on a \emph{data type} |D|:

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
because after |N Void| was deprived of its sole inhabitant $\bot \equiv
MkN\,\bot$ by the third GRHS, there is nothing left to match on (similarly for
|h1|).
Analogous subtle reasoning justifies the difference in warnings for |g2| and
|h2|.

\Cref{fig:newtypes} outlines a solution that handles all these cases correctly:

\begin{itemize}

  \item A newtype pattern match $N \; pat_1\,...\,pat_n$ is lazy: it does not
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
  constraints by immediately rejecting. The reason it doesn't consider $\bot$
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

Instead of extending the source language, let's discuss ripping out a language
feature for a change! So far, we have focused on Haskell as the source
language, which is lazy by default. Although the difference in evaluation
strategy of the source language becomes irrelevant after desugaring, it raises the
question of how much our approach could be simplified if we targeted a source
language that was strict by default, such as OCaml or Idris (or even Rust).

On first thought, it is tempting to simply drop all parts related to laziness
from the formalism, such as $\grdbang{x}$ from $\Grd$ and
$\antbang{}{\hspace{-0.6em}}$ from $\Ant$. Actually, $\Ant$ and $\red$ could
vanish altogether and $\ann$ could just collect the redundant GRHS directly!
Since there wouldn't be any bang guards, there is no reason to have $x
\termeq \bot$ and $x \ntermeq \bot$ constraints either. Most importantly, the
\inhabitedbot judgment form has to go, because $\bot$ does not inhabit any types
anymore.

And compiler writers for total languages such as Idris or Agda would live
happily after: Talking about $x \ntermeq \bot$ constraints made no sense there
to begin with. Not so with OCaml or Rust, which are strict, non-total languages
and allow arbitrary side-effects in expressions. Here's an example in OCaml:

\begin{code}
let rec f p x =
  match x with
    []                         -> []
  | hd::_ when p hd && x = []  -> [hd]
  | _::tl                      -> f p tl;;
\end{code}

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
$\grdbang{|x|}$ can be understood as an \emph{effect handler} for \emph{one
specific effect}, namely divergence. We have shown in this work that divergence
is an ambient side-effect of a non-total, lazy language that is worth worrying
about and gave a formalism that handles that specific effect with respect to
pattern-match coverage checking. We believe that a very similar formalism could
scale to arbitrary side-effects such as releasing a mutex.
