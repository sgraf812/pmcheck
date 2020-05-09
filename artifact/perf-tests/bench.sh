#!/bin/bash

TEST_NAME=$1

function bench {
  GHC_PATH=$1
  $GHC_PATH $TEST_NAME -package ghc -fforce-recomp -ddump-timings -Wincomplete-patterns -Woverlapping-patterns -Wincomplete-uni-patterns -Wincomplete-record-updates | grep "Desugar"
}

echo  "~~~~~ GHC 8.8.3 results ~~~~~"
bench "/opt/ghc/8.8.3/bin/ghc"
echo  "~~~~~ GHC-LYG results ~~~~~"
bench "/opt/ghc/lyg/bin/ghc"
