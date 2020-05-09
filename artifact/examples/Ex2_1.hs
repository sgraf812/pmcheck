{-# OPTIONS_GHC -Wall #-}
module Ex2_1 where

guardDemo :: Char -> Char -> Int
guardDemo c1 c2
  | c1 == 'a'                           = 0
  | 'b' <- c1                           = 1
  | let c1' = c1, 'c' <- c1', c2 == 'd' = 2
  | otherwise                           = 3

signum :: Int -> Int
signum x | x > 0  = 1
         | x == 0 = 0
         | x < 0  = -1

not :: Bool -> Bool
not b | False <- b = True
      | True  <- b = False

not2 :: Bool -> Bool
not2 False = True
not2 True  = False

not3 :: Bool -> Bool
not3 x | False <- x = True
not3 True           = False
