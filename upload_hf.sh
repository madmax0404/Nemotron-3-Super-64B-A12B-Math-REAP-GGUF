#!/bin/bash
set -e
cd /workspace/gguf

# Load HF_TOKEN without printing it
set -a
source .env
set +a

export HF_HUB_ENABLE_HF_TRANSFER=1

REPO=Max-and-Omnis/Nemotron-3-Super-64B-A12B-Math-REAP-GGUF
STAGE=/workspace/gguf/upload_stage

source /workspace/gguf/.venv/bin/activate

# Stage only the files we want to publish — symlinks, no disk duplication
mkdir -p "$STAGE"
rm -f "$STAGE"/*
for f in \
  Nemotron-3-Super-64B-A12B-Math-REAP.bf16.gguf \
  Nemotron-3-Super-64B-A12B-Math-REAP.Q8_0.gguf \
  Nemotron-3-Super-64B-A12B-Math-REAP.Q6_K.gguf \
  Nemotron-3-Super-64B-A12B-Math-REAP.Q4_K_M.gguf \
  Nemotron-3-Super-64B-A12B-Math-REAP.IQ4_XS.gguf \
  Nemotron-3-Super-64B-A12B-Math-REAP.IQ3_M.gguf \
  Nemotron-3-Super-64B-A12B-Math-REAP.IQ2_M.gguf \
  imatrix.dat \
  calibration.txt ; do
  ln -s /workspace/gguf/out/$f "$STAGE/$f"
done
ls -lh "$STAGE"

# Create repo (idempotent)
python -c "
from huggingface_hub import create_repo
import os
create_repo('$REPO', token=os.environ['HF_TOKEN'], repo_type='model', exist_ok=True, private=False)
print('repo ready: $REPO')
"

# Upload with large-folder uploader (handles multi-commit, resume, parallel)
hf upload-large-folder \
  "$REPO" \
  "$STAGE" \
  --repo-type=model \
  --num-workers=4
