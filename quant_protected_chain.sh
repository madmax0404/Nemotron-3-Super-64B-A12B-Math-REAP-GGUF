#!/bin/bash
set -e
LLAMA=/workspace/gguf/llama.cpp/build/bin/llama-quantize
SRC=/workspace/gguf/out/Nemotron-3-Super-64B-A12B-Math-REAP.bf16.gguf
IMAT=/workspace/gguf/out/imatrix.dat
OUT=/workspace/gguf/out
BASE=Nemotron-3-Super-64B-A12B-Math-REAP

# Common ignore-list (tensors to keep at BF16)
IGNORE=(
  --output-tensor-type bf16
  --tensor-type "attn_q\.=bf16"
  --tensor-type "attn_k\.=bf16"
  --tensor-type "attn_v\.=bf16"
  --tensor-type "attn_output\.=bf16"
  --tensor-type "ssm_in\.=bf16"
  --tensor-type "ssm_out\.=bf16"
  --tensor-type "ffn_up_shexp\.=bf16"
  --tensor-type "ffn_down_shexp\.=bf16"
  --tensor-type "ffn_latent_up\.=bf16"
  --tensor-type "ffn_latent_down\.=bf16"
)

run_quant() {
  local variant=$1
  local use_imatrix=$2
  local outfile=$OUT/$BASE.${variant}.gguf
  echo "=== $(date '+%Y-%m-%d %H:%M:%S') starting $variant -> $outfile ==="
  if [ "$use_imatrix" = "yes" ]; then
    $LLAMA --imatrix $IMAT "${IGNORE[@]}" $SRC $outfile $variant 18
  else
    $LLAMA "${IGNORE[@]}" $SRC $outfile $variant 18
  fi
  ls -lh $outfile
  echo
}

# Near-lossless: no imatrix benefit
run_quant Q8_0 no
run_quant Q6_K no

# Imatrix helps at 4-bit and below
run_quant Q4_K_M yes
run_quant IQ4_XS yes
run_quant IQ3_M yes
run_quant IQ2_M yes

echo "=== $(date '+%Y-%m-%d %H:%M:%S') ALL DONE ==="
