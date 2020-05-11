module Ex7_4

%default total

v : Maybe Void -> Int
v Nothing = 0

v_modified : Maybe Void -> Int
v_modified Nothing = 0
v_modified (Just _) = 1
