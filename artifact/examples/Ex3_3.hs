{-# OPTIONS_GHC -Wall #-}
module Ex3_3 where

data T = A | B | C

f :: Maybe T -> Bool
f (Just A) = True
