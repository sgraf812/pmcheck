{-# OPTIONS_GHC -Wall #-}
module Ex7_1_2 where

safeLast2 :: [a] -> Maybe a
safeLast2 xs
  | (x:_) <- reverse xs = Just x
  | []    <- reverse xs = Nothing
