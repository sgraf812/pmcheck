#!/bin/bash

function gen_contents {
  PKG_NAME=$1
  PKG_VER=$2

  FULL_PKG_NAME=$1-$2

  cabal get --pristine $FULL_PKG_NAME
  echo "packages: ./"                                 > $FULL_PKG_NAME/cabal.project
  echo "package *"                                   >> $FULL_PKG_NAME/cabal.project
  echo "  ghc-options: -w"                           >> $FULL_PKG_NAME/cabal.project
  echo "package $PKG_NAME"                           >> $FULL_PKG_NAME/cabal.project
  echo "  ghc-options: -Werror=overlapping-patterns" >> $FULL_PKG_NAME/cabal.project
  echo "allow-newer: Cabal, base, time, template-haskell, ghc, ghc-boot, ghc-boot-th, ghci, ghc-prim" >> $FULL_PKG_NAME/cabal.project
}

function patch_it {
  PKG_NAME=$1
  PKG_VER=$2
  DIR=$3

  FULL_PKG_NAME=$1-$2

  ( cd "$DIR/$FULL_PKG_NAME" && patch -p1 -i /root/head.hackage/patches/$FULL_PKG_NAME.patch )
}

function get_dep_and_patch {
  PKG_NAME=$1
  PKG_VER=$2

  FULL_PKG_NAME=$1-$2

  cabal get --pristine $FULL_PKG_NAME -d patched-deps
  patch_it "$PKG_NAME" "$PKG_VER" "patched-deps"
  echo "packages: ../patched-deps/$FULL_PKG_NAME" >> pandoc-2.9.2/cabal.project
}

gen_contents "Cabal" "2.4.1.0"
gen_contents "generic-data" "0.8.1.0"
gen_contents "geniplate-mirror" "0.7.6"
gen_contents "HsYAML" "0.2.1.0"
gen_contents "network" "3.1.1.1"
gen_contents "pandoc" "2.9.2"
gen_contents "pandoc-types" "1.20"
patch_it "Cabal" "2.4.1.0" "."
patch_it "geniplate-mirror" "0.7.6" "."
patch_it "pandoc" "2.9.2" "."

get_dep_and_patch "HTTP" "4000.3.14"
get_dep_and_patch "basement" "0.0.11"
get_dep_and_patch "hxt" "9.3.1.18"
get_dep_and_patch "hxt-regex-xmlschema" "9.2.0.3"
get_dep_and_patch "memory" "0.15.0"
get_dep_and_patch "regex-base" "0.94.0.0"
get_dep_and_patch "regex-tdfa" "1.2.3.2"
