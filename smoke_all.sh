#!/bin/bash
LLAMA=/workspace/gguf/llama.cpp/build/bin/llama-cli
OUT=/workspace/gguf/out
BASE=Nemotron-3-Super-64B-A12B-Math-REAP
PROMPT="What is 12 times 15?"
NGEN=60

declare -A NGL=(
  [Q8_0]=20
  [Q6_K]=25
  [Q4_K_M]=28
  [IQ4_XS]=35
  [IQ3_M]=37
  [IQ2_M]=42
)

for variant in Q8_0 Q6_K Q4_K_M IQ4_XS IQ3_M IQ2_M; do
  echo "======================================================================"
  echo "=== $(date '+%Y-%m-%d %H:%M:%S') smoke-testing $variant (ngl=${NGL[$variant]}) ==="
  echo "======================================================================"
  LOG=$OUT/smoke-$variant.log
  $LLAMA -m $OUT/$BASE.$variant.gguf \
    -ngl ${NGL[$variant]} -n $NGEN -p "$PROMPT" -st -t 18 \
    </dev/null > $LOG 2>&1
  echo "--- output ---"
  tr '\r' '\n' < $LOG | grep -vE "^[\\\\|/-]+\s*$|^\s*$|Loading model\.\.\.|^(build|model|modalities|available commands|  /|llama_|ggml_|print_info|sched_|system_info|compute_|common_|load_|tensor_|llm_|main|tokenize)" | tail -40
  echo
done
echo "=== $(date '+%Y-%m-%d %H:%M:%S') ALL SMOKE TESTS DONE ==="
