{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE GADTs #-}
{-# OPTIONS_GHC -Wall #-}
module Ex2_3 where

-- 2.3

data Void -- No data constructors; only inhabitant is bottom
data SMaybe a = SJust !a | SNothing

v :: SMaybe Void -> Int
v SNothing  = 0
v (SJust _) = 1

-- 2.3.1

u :: () -> Int
u () | False = 1
     | True  = 2
u _          = 3

u' :: () -> Int
u' () | False = 1
      | False = 2
u' _          = 3

-- Like u, but without the first and third cases
u_modified :: () -> Int
u_modified () | True = 2

-- Like u', but without the first and second cases
u'_modified :: () -> Int
u'_modified _ = 3

-- 2.3.2

v' :: Maybe Void -> Int
v' Nothing   = 0
v' (Just !_) = 1

-- 2.4

data T a b where
  T1 :: T Int Bool
  T2 :: T Char Bool

g1 :: T Int b -> b -> Int
g1 T1 False = 0
g1 T1 True  = 1

g2 :: T a b -> T a b -> Int
g2 T1 T1 = 0
g2 T2 T2 = 1
