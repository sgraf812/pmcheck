{-# OPTIONS_GHC -Wall #-}
module Ex4_1 where

f :: Bool -> Int
f True = 1
f x    = g (case x of { False -> 2; True -> 3 }) ()
  where
    g a _ = a
