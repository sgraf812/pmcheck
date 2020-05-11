{-# OPTIONS_GHC -Wall #-}
module Ex7_1_1 where

data Void -- No data constructors; only inhabitant is bottom
data SMaybe a = SJust !a | SNothing

v :: SMaybe Void -> Int
v SNothing  = 0
