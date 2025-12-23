#!/usr/bin/env bash
# Linux sweep script equivalent to run_sweep.bat
# - Re-ingests corpus for two splitter settings (800/120 and 350/80)
# - For each, runs several eval configs and logs to eval_results.md
# Usage:
#   chmod +x run_sweep.sh
#   ./run_sweep.sh
# Overrides (examples):
#   BUILD_N=60 PROGRESS_EVERY=10 DOCS="backend/data/uploads/Dive-into-DL-Pytorch.pdf" OLLAMA_MODEL=qwen2:7b-instruct ./run_sweep.sh
#   DOCS="backend/data/uploads/Dive-into-DL-Pytorch.pdf backend/data/uploads/084810-01.pdf" ./run_sweep.sh

set -euo pipefail

# -------------------------
# Defaults (can be overridden by env)
# -------------------------
INSTALL_DEPS=${INSTALL_DEPS:-0}
BUILD_N=${BUILD_N:-60}
PROGRESS_EVERY=${PROGRESS_EVERY:-10}
DOCS=${DOCS:-"backend/data/uploads/Dive-into-DL-Pytorch.pdf"}
LOG_MD=${LOG_MD:-"eval_results.md"}
export OLLAMA_MODEL=${OLLAMA_MODEL:-"qwen2:7b-instruct"}

# Global runtime/eval env (can still be overridden before calling)
export EVAL_MODE=${EVAL_MODE:-1}
export RETRIEVAL_METHOD=${RETRIEVAL_METHOD:-mmr}
export RETRIEVAL_FETCH_K=${RETRIEVAL_FETCH_K:-60}
export RERANK=${RERANK:-1}
export RERANK_CANDIDATES=${RERANK_CANDIDATES:-40}
export RERANK_MAX_LENGTH=${RERANK_MAX_LENGTH:-1024}
export LLM_NUM_PREDICT=${LLM_NUM_PREDICT:-128}
export LLM_NUM_CTX=${LLM_NUM_CTX:-2048}
export OLLAMA_KEEP_ALIVE=${OLLAMA_KEEP_ALIVE:-"30m"}
export EMBED_MODEL=${EMBED_MODEL:-"BAAI/bge-m3"}

if [[ "$INSTALL_DEPS" == "1" ]]; then
  echo "[+] Installing/Updating dependencies..."
  pip install -U -r backend/requirements.txt
fi

# -------------------------
# Helper functions
# -------------------------
clean_vectors() {
  echo "[+] Cleaning vector store..."
  rm -rf backend/data/vectors backend/data/index.faiss backend/data/index.pkl 2>/dev/null || true
}

ingest() {
  echo "[+] Ingesting docs with CHUNK_SIZE=${CHUNK_SIZE} CHUNK_OVERLAP=${CHUNK_OVERLAP}"
  for f in $DOCS; do
    echo "    - $f"
    python - <<PY
from backend.rag import add_documents_from_file as add
print(add("$f"))
PY
  done
}

build_eval_set() {
  local tag="$1"
  local out="eval_set_${tag}.jsonl"
  if [[ ! -f "$out" ]]; then
    echo "[+] Building eval set: $BUILD_N items -> $out"
    python -m backend.eval_lite --build "$BUILD_N" --out "$out"
  else
    echo "[=] Using existing eval set: $out"
  fi
  echo "$out"
}

run_case() {
  # Args: base suf top_k rerank [cand] [maxlen] [num_predict]
  local base="$1"; shift
  local suf="$1"; shift
  local top_k="$1"; shift
  local rerank_flag="$1"; shift
  local cand="${1:-}"; [[ $# -ge 1 ]] && shift || true
  local maxlen="${1:-}"; [[ $# -ge 1 ]] && shift || true
  local np="${1:-}"; [[ $# -ge 1 ]] && shift || true

  export RERANK="$rerank_flag"
  [[ -n "$cand" ]] && export RERANK_CANDIDATES="$cand"
  [[ -n "$maxlen" ]] && export RERANK_MAX_LENGTH="$maxlen"
  [[ -n "$np" ]] && export LLM_NUM_PREDICT="$np"

  local tag="${base}-${suf}"
  local out_file="eval_set_${base}.jsonl"
  local details_file="details_${tag}.jsonl"

  echo "[+] Running case: $tag (top_k=$top_k, rerank=$RERANK, cand=$RERANK_CANDIDATES, maxlen=$RERANK_MAX_LENGTH, np=$LLM_NUM_PREDICT)"
  python -m backend.eval_lite \
    --run --file "$out_file" --k "$top_k" --coverage \
    --details "$details_file" --progress_every "$PROGRESS_EVERY" \
    > last_report.json

  # Append to Markdown log
  if [[ ! -f "$LOG_MD" ]]; then
    echo "# RAG Evaluation Runs" > "$LOG_MD"
    echo >> "$LOG_MD"
  fi
  {
    echo "## $(date +'%F %T')"
    echo "- tag: $tag"
    echo "- model: $OLLAMA_MODEL"
    echo "- embed_model: $EMBED_MODEL"
    echo "- chunk_size: ${CHUNK_SIZE}"
    echo "- chunk_overlap: ${CHUNK_OVERLAP}"
    echo "- top_k: $top_k"
    echo "- retrieval_method: $RETRIEVAL_METHOD"
    echo "- retrieval_fetch_k: $RETRIEVAL_FETCH_K"
    echo "- rerank: $RERANK"
    echo "- reranker_model: ${RERANKER_MODEL:-BAAI/bge-reranker-base}"
    echo "- rerank_candidates: $RERANK_CANDIDATES"
    echo "- rerank_max_length: $RERANK_MAX_LENGTH"
    echo "- llm_num_predict: $LLM_NUM_PREDICT"
    echo "- llm_num_ctx: $LLM_NUM_CTX"
    echo "- keep_alive: $OLLAMA_KEEP_ALIVE"
    echo "- out_file: $out_file"
    echo "- details_file: $details_file"
    echo
    echo '```json'
    cat last_report.json
    echo '```'
    echo
  } >> "$LOG_MD"
}

# -------------------------
# Sweep
# -------------------------

# A) Ingest with chunk 800/120
export CHUNK_SIZE=800
export CHUNK_OVERLAP=120
base="cs800-ov120"
clean_vectors
ingest
build_eval_set "$base" >/dev/null
run_case "$base" k5-norerank 5 0 "" "" 24
run_case "$base" k3-norerank-np16 3 0 "" "" 16
run_case "$base" k5-rerank32 5 1 32 512 24
run_case "$base" k5-rerank40 5 1 40 512 24

# B) Ingest with chunk 350/80
export CHUNK_SIZE=350
export CHUNK_OVERLAP=80
base="cs350-ov80"
clean_vectors
ingest
build_eval_set "$base" >/dev/null
run_case "$base" k5-norerank 5 0 "" "" 24
run_case "$base" k3-norerank-np16 3 0 "" "" 16
run_case "$base" k5-rerank32 5 1 32 512 24

echo "[OK] Sweep finished. See $LOG_MD and last_report.json"
