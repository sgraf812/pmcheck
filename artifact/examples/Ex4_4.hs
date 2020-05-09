{-# LANGUAGE PatternSynonyms #-}
{-# OPTIONS_GHC -Wall #-}
module Ex4_4 where

pattern P :: ()
pattern P = ()

pattern Q :: ()
pattern Q = ()

n :: Int
n = case P of Q -> 1; P -> 2
