"""Render traces.jsonl through the model's chat template for llama-imatrix."""
import json
from transformers import AutoTokenizer

SNAP = "/workspace/.hf_home/hub/models--Max-and-Omnis--Nemotron-3-Super-64B-A12B-Math-REAP-BF16/snapshots/f2aa688ffe76d60b8cd94b45f7c417b7c36284c3"
INPUT = "/workspace/aimo3-fine-tuning/pruning/traces.jsonl"
OUTPUT = "/workspace/gguf/out/calibration.txt"

tok = AutoTokenizer.from_pretrained(SNAP, trust_remote_code=True, fix_mistral_regex=True)

total_chars = 0
n = 0
with open(OUTPUT, "w") as out:
    for line in open(INPUT):
        rec = json.loads(line)
        text = tok.apply_chat_template(
            rec["conversation"], tokenize=False, add_generation_prompt=False
        )
        out.write(text)
        out.write("\n\n")
        total_chars += len(text) + 2
        n += 1

# Estimate token count by sampling
sample = open(OUTPUT).read(200000)
sample_tokens = len(tok.encode(sample, add_special_tokens=False))
est_total_tokens = int(sample_tokens * total_chars / len(sample))

print(f"wrote {n} conversations → {OUTPUT}")
print(f"total chars: {total_chars:,}")
print(f"estimated tokens: {est_total_tokens:,} (from {len(sample):,}-char sample)")
