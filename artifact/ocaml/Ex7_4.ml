type void = |;;

let v (None : void option) : int = 0;;

let v' (o : void option) : int =
      match o with
        None    -> 0
      | Some _  -> 1;;

type t = MkT of t;;

let f (None : t option) : int = 0;;
