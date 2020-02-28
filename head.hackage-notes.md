I ran GHC HEAD (commit
https://gitlab.haskell.org/ghc/ghc/commit/59c023ba5ccb10fff62810591f20608bd73c97af)
against `head.hackage` (commit
https://gitlab.haskell.org/ghc/head.hackage/commit/30a310fd8033629e1cbb5a9696250b22db5f7045)
and recorded how many packages gave new
coverage warnings (as opposed to GHC 8.8.3, which implements GMTM).

`head.hackage` has approximately 361 libraries. (I obtained this number by
going through
[this `head.hackage` CI log](https://gitlab.haskell.org/ghc/head.hackage/-/jobs/269094)
and counting the number of lines that being with `Downloading  `.)
Of these 361 libraries, I found 7 that gave new warnings under HEAD, which are
documented below:

# Packages that give new warnings under HEAD

## `Cabal-2.4.1.0`

"Debugging" cases:

```hs
    ppIf (CondBranch c thenTree (Just elseTree)) =
          case (False, False) of
 --       case (isEmpty thenDoc, isEmpty elseDoc) of
              (True,  True)  -> mempty
              (False, True)  -> ppIfCondition c $$ nest indentWith thenDoc
              (True,  False) -> ppIfCondition (cNot c) $$ nest indentWith elseDoc
              (False, False) -> (ppIfCondition c $$ nest indentWith thenDoc)
                                $+$ (text "else" $$ nest indentWith elseDoc)
```
```
[168 of 220] Compiling Distribution.PackageDescription.PrettyPrint ( Distribution/PackageDescription/PrettyPrint.hs, interpreted )

Distribution/PackageDescription/PrettyPrint.hs:128:15: error: [-Woverlapping-patterns, -Werror=overlapping-patterns]
    Pattern match is redundant
    In a case alternative: (True, True) -> ...
    |
128 |               (True,  True)  -> mempty
    |               ^^^^^^^^^^^^^^^^^^^^^^^^

Distribution/PackageDescription/PrettyPrint.hs:129:15: error: [-Woverlapping-patterns, -Werror=overlapping-patterns]
    Pattern match is redundant
    In a case alternative: (False, True) -> ...
    |
129 |               (False, True)  -> ppIfCondition c $$ nest indentWith thenDoc
    |               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Distribution/PackageDescription/PrettyPrint.hs:130:15: error: [-Woverlapping-patterns, -Werror=overlapping-patterns]
    Pattern match is redundant
    In a case alternative: (True, False) -> ...
    |
130 |               (True,  False) -> ppIfCondition (cNot c) $$ nest indentWith elseDoc
    |               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
```

## `generic-data-0.8.1.0`

Bang patterns that should have been `EmptyCase`:

```hs
data V1 x

absurd1 :: V1 x -> a
absurd1 !_ = error "impossible"
```
```
[10 of 17] Compiling Generic.Data.Internal.Utils ( src/Generic/Data/Internal/Utils.hs, interpreted )

src/Generic/Data/Internal/Utils.hs:43:1: error: [-Woverlapping-patterns, -Werror=overlapping-patterns]
    Pattern match has inaccessible right hand side
    In an equation for ‘absurd1’: absurd1 !_ = ...
   |
43 | absurd1 !_ = error "impossible"
   | ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
```

## `geniplate-mirror-0.7.6`

Long-distance info:

```hs
instanceTransformBiMT' :: Mode -> [TypeQ] -> TypeQ -> Type -> Q [Dec]
instanceTransformBiMT' doDescend stops mndq (ForallT _ _ t) = instanceTransformBiMT' doDescend stops mndq t
instanceTransformBiMT'  MDescend stops mndq ty = do
    mnd <- mndq

    f <- newName "_f"
    x <- newName "_x"
    (ds, tr) <- trBiQ MDescend raMonad stops f ty ty
    let e = LamE [VarP f, VarP x] $ LetE ds $ AppE tr (VarE x)
    return $ instDef ''DescendM [mnd, ty] 'descendM e
instanceTransformBiMT' doDescend stops mndq ty | (TupleT _, [ft, st]) <- splitTypeApp ty = do
--    qRunIO $ do putStrLn "************"; hFlush stdout
    mnd <- mndq

    f <- newName "_f"
    x <- newName "_x"
    (ds, tr) <- trBiQ doDescend raMonad stops f ft st
    let e = LamE [VarP f, VarP x] $ LetE ds $ AppE tr (VarE x)
        cls = case doDescend of MTransformBi -> ''TransformBiM; MDescendBi -> ''DescendBiM; MDescend -> error "MDescend"
        met = case doDescend of MTransformBi ->  'transformBiM; MDescendBi ->  'descendBiM; MDescend -> error "MDescend"
    return $ instDef cls [mnd, ft, st] met e
instanceTransformBiMT' _ _ _ t = genError "instanceTransformBiMT: the argument should be of the form [t| (S, T) |]"
```
```
[1 of 1] Compiling Data.Generics.Geniplate ( Data/Generics/Geniplate.hs, interpreted )

Data/Generics/Geniplate.hs:173:93: error: [-Woverlapping-patterns, -Werror=overlapping-patterns]
    Pattern match is redundant
    In a case alternative: MDescend -> ...
    |
173 |         cls = case doDescend of MTransformBi -> ''TransformBiM; MDescendBi -> ''DescendBiM; MDescend -> error "MDescend"
    |                                                                                             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Data/Generics/Geniplate.hs:174:93: error: [-Woverlapping-patterns, -Werror=overlapping-patterns]
    Pattern match is redundant
    In a case alternative: MDescend -> ...
    |
174 |         met = case doDescend of MTransformBi ->  'transformBiM; MDescendBi ->  'descendBiM; MDescend -> error "MDescend"
    |                                                                                             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
```

## `HsYAML-0.2.1.0`

"Debugging" cases:

```hs
        go' _ _ _ xs | False = error (show xs)
        go' _ _ _ xs = err xs
```
```
src/Data/YAML/Event.hs:412:24: error: [-Woverlapping-patterns, -Werror=overlapping-patterns]
    Pattern match is redundant
    In an equation for ‘go'’: go' _ _ _ xs | False = ...
    |
412 |         go' _ _ _ xs | False = error (show xs)
    |                        ^^^^^
```

## `network-3.1.1.1`

CPP:

```hs
packSocketType' :: SocketType -> Maybe CInt
packSocketType' stype = case Just stype of
    -- the Just above is to disable GHC's overlapping pattern
    -- detection: see comments for packSocketOption
    Just NoSocketType -> Just 0
#ifdef SOCK_STREAM
    Just Stream -> Just #const SOCK_STREAM
#endif
#ifdef SOCK_DGRAM
    Just Datagram -> Just #const SOCK_DGRAM
#endif
#ifdef SOCK_RAW
    Just Raw -> Just #const SOCK_RAW
#endif
#ifdef SOCK_RDM
    Just RDM -> Just #const SOCK_RDM
#endif
#ifdef SOCK_SEQPACKET
    Just SeqPacket -> Just #const SOCK_SEQPACKET
#endif
    _ -> Nothing
```
```
[ 6 of 24] Compiling Network.Socket.Types ( /home/rgscott/Documents/Hacking/Haskell/pmcheck-eval/dist-newstyle/build/x86_64-linux/ghc-8.11.0.20200227/network-3.1.1.1/build/Network/Socket/Types.hs, /tmp/ghc22056_0/ghc_34.o )

Network/Socket/Types.hsc:331:5: error: [-Woverlapping-patterns, -Werror=overlapping-patterns]
    Pattern match is redundant
    In a case alternative: _ -> ...
    |
331 |     _ -> Nothing
    |     ^^^^^^^^^^^^
```

## `pandoc-2.9.2`

Adapting to GMTM shortcomings:

```hs
blockToOpenDocument :: PandocMonad m => WriterOptions -> Block -> OD m (Doc Text)
blockToOpenDocument o bs
    | Plain          b <- bs = ...
    | ...
    | Null             <- bs = ...
    | otherwise              = ...

...

textStyleAttr :: Map.Map Text Text
              -> TextStyle
              -> Map.Map Text Text
textStyleAttr m s
    | Italic <- s = ...
    | ...
    | Language lang <- s
                  = ...
    | otherwise   = ...
```
```
[104 of 161] Compiling Text.Pandoc.Writers.OpenDocument

src/Text/Pandoc/Writers/OpenDocument.hs:373:7: error: [-Woverlapping-patterns, -Werror=overlapping-patterns]
    Pattern match is redundant
    In an equation for ‘blockToOpenDocument’:
        blockToOpenDocument o bs | otherwise = ...
    |
373 |     | otherwise              = return empty
    |       ^^^^^^^^^

src/Text/Pandoc/Writers/OpenDocument.hs:723:7: error: [-Woverlapping-patterns, -Werror=overlapping-patterns]
    Pattern match is redundant
    In an equation for ‘textStyleAttr’:
        textStyleAttr m s | otherwise = ...
    |
723 |     | otherwise   = m
    |       ^^^^^^^^^
```
```hs
inlineToAsciiDoc _ il@(RawInline f s)
  | f == "asciidoc" = return $ literal s
  | otherwise         = do
      report $ InlineNotRendered il
      return empty
  | otherwise       = return empty
```
```
[118 of 161] Compiling Text.Pandoc.Writers.AsciiDoc

src/Text/Pandoc/Writers/AsciiDoc.hs:495:5: error: [-Woverlapping-patterns, -Werror=overlapping-patterns]
    Pattern match is redundant
    In an equation for ‘inlineToAsciiDoc’:
        inlineToAsciiDoc _ il@(RawInline f s) | otherwise = ...
    |
495 |   | otherwise       = return empty
    |     ^^^^^^^^^
```

The latter is most likely a programmer error. See https://github.com/jgm/pandoc/pull/6146.

## `pandoc-types-1.20`

Adapting to a GMTM shortcomings:

```hs
        numcols  = case headers:rows of
                        [] -> 0
                        xs -> maximum (map length xs)
```
```
[3 of 9] Compiling Text.Pandoc.Builder ( Text/Pandoc/Builder.hs, interpreted )

Text/Pandoc/Builder.hs:497:25: error: [-Woverlapping-patterns, -Werror=overlapping-patterns]
    Pattern match is redundant
    In a case alternative: [] -> ...
    |
497 |                         [] -> 0
    |                         ^^^^^^^
```
