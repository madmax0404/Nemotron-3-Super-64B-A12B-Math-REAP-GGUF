#!/bin/bash
set -e
LLAMA=/workspace/gguf/llama.cpp/build/bin/llama-quantize
SRC=/workspace/gguf/out/Nemotron-3-Super-64B-A12B-Math-REAP.bf16.gguf
IMAT=/workspace/gguf/out/imatrix.dat
OUT=/workspace/gguf/out
BASE=Nemotron-3-Super-64B-A12B-Math-REAP

for variant in IQ4_XS Q4_K_M IQ3_M IQ2_M; do
  OUTFILE=$OUT/$BASE.${variant}-imat.gguf
  echo "=== $(date '+%H:%M:%S') starting $variant -> $OUTFILE ==="
  $LLAMA --imatrix $IMAT $SRC $OUTFILE $variant 18
  ls -lh $OUTFILE
  echo
done
echo "=== ALL DONE ==="
