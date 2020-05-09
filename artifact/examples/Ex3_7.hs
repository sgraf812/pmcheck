{-# OPTIONS_GHC -Wall #-}
module Ex3_7 where

data SMaybe a = SJust !a | SNothing

data T = MkT !T

f :: SMaybe T -> ()
f SNothing = ()
