{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE ViewPatterns #-}
{-# OPTIONS_GHC -Wall #-}
module Ex3_1 where

f :: Maybe (a, b) -> Maybe c -> Int
f (Just (!xs, _)) ys@Nothing  = 1
f Nothing         (g -> True) = 2

liftEq :: Eq a => Maybe a -> Maybe a -> Bool
liftEq Nothing Nothing  = True
liftEq mx      (Just y) | Just x <- mx, x == y = True
                        | otherwise            = False

-------------------------------------------------------------------------------

-- The implementation of this function isn't of particular importance—it's
-- just used to illustrate an example of a view pattern in `f` above.
g :: Maybe a -> Bool
g _ = True
