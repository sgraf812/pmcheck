{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE EmptyCase #-}
{-# OPTIONS_GHC -Wall #-}
module Ex4_2 where

data Void

absurd1, absurd2, absurd3 :: Void -> a
absurd1 _  = undefined
absurd2 !_ = undefined
absurd3 x  = case x of {}
