module Ex7_4

%default total

-- Void is defined as
--
--   data Void
--
-- And is in scope in Idris by default

v : Maybe Void -> Int
v Nothing = 0

v' : Maybe Void -> Int
v' Nothing = 0
v' (Just _) = 1

data T : Type where
  MkT : T -> T

f : Maybe T -> Int
f Nothing = 0
