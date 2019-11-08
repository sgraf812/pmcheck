# pmcheck

- The syntax of Delta currently doesn't allow unrestricted
  conjunction of two Deltas. for example `(x~T + x~F) * (y ~T + y~F)`
  is not allowed, because `*` only works between a Delta and a delta.
- Yet to use `ctt` for multiple clauses, we need exactly that operation: We
  have to `*` the incoming Delta with the Delta produced by the current clause.
- we get a series of Deltas: $\Delta_n = \Delta_{n-1}, ..., \Delta'_{n-1}$,
  where $\Delta'_n$ is the uncovered set of ctt'ing the nth clause.
- For efficiency purposes, we should really cache the result of checking
  $\Delta_n$. E.g. after checking the second clause, we shouldn't re-compute
  satisfiability of the $\Delta_1$ when checking redundancy of the third clause
  (testing $\Delta_2$, that is)
- We can achieve this by testing all clauses in one go! The following (strangely familiar) data structure would work:
  ```haskell
data Clauses a
  = Many a (Clauses a) -- Caching prefix of GRHSs
  | Single { uncov :: a, div :: a, cov :: a }
  | End
