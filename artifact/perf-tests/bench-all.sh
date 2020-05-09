#!/bin/bash

for TEST in T11276 T11303 T11303b T11374 T11822 T11195 T17096 PmSeriesS PmSeriesT PmSeriesV
do
  echo "====="
  echo "== $TEST"
  echo "====="
  ./bench.sh $TEST
  echo ""
done
