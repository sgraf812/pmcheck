{-# LANGUAGE ViewPatterns #-}
{-# OPTIONS_GHC -Wall #-}
module Ex2_2_1 where

import qualified Data.Text as Text
import Data.Text (Text)
import Prelude hiding (length)

length :: Text -> Int
length (Text.null   -> True)         = 0
length (Text.uncons -> Just (_, xs)) = 1 + length xs

safeLast :: [a] -> Maybe a
safeLast (reverse -> [])    = Nothing
safeLast (reverse -> (x:_)) = Just x
