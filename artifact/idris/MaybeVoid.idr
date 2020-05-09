module MaybeVoid

%default total

v : Maybe Void -> Int
v Nothing = 0
-- v (Just _) = 1
