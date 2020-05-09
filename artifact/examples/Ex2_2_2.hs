{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE ViewPatterns #-}
{-# OPTIONS_GHC -Wall #-}
module Ex2_2_2 where

import qualified Data.Text as Text
import Data.Text (Text)
import Prelude hiding (length)

pattern Nil :: Text
pattern Nil <- (Text.null -> True)

pattern Cons :: Char -> Text -> Text
pattern Cons x xs <- (Text.uncons -> Just (x, xs))

{-# COMPLETE Nil, Cons #-}

length :: Text -> Int
length Nil         = 0
length (Cons _ xs) = 1 + length xs
