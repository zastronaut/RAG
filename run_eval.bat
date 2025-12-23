@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

rem ==============================================
rem RAG Evaluation: MMR + optional re-rank + short output
rem Usage:
rem   - Double-click or run in CMD from project root
rem   - Optional overrides before run (examples):
rem       set BUILD_N=200
rem       set TOP_K=5
rem       set OUT_FILE=eval_set_lite.jsonl
rem       set DETAILS_FILE=details_mmr_rerank.jsonl
rem       set INSTALL_DEPS=1
rem ==============================================

if "%BUILD_N%"=="" set BUILD_N=150
if "%TOP_K%"=="" set TOP_K=5
if "%OUT_FILE%"=="" set "OUT_FILE=eval_set_lite.jsonl"
if "%DETAILS_FILE%"=="" set "DETAILS_FILE=details_mmr_rerank.jsonl"
if "%INSTALL_DEPS%"=="" set INSTALL_DEPS=0
if "%LOG_MD%"=="" set "LOG_MD=eval_results.md"
if "%REPORT_JSON%"=="" set "REPORT_JSON=last_report.json"
if "%TAG%"=="" set TAG=run
if "%PROGRESS_EVERY%"=="" set PROGRESS_EVERY=10
if "%EMBED_MODEL%"=="" set EMBED_MODEL=BAAI/bge-m3
if "%PROGRESS_EVERY%"=="" set PROGRESS_EVERY=10

rem Core evaluation/runtime env
set EVAL_MODE=1

rem Retrieval: default to MMR for both runtime and eval
set RETRIEVAL_METHOD=mmr
set RETRIEVAL_FETCH_K=40

rem Cross-encoder re-ranking (optional, enabled by default here)
set RERANK=1
set RERANKER_MODEL=BAAI/bge-reranker-base
set RERANK_CANDIDATES=40
set RERANK_MAX_LENGTH=1024

rem LLM latency controls (Ollama)
set LLM_NUM_PREDICT=24
set LLM_NUM_CTX=2048
set OLLAMA_KEEP_ALIVE=30m

rem Use Qwen 2.5 3B instruct by default (better instruction-following and short-form extraction)
set OLLAMA_MODEL=qwen2.5:3b-instruct

echo ==== Eval settings ====
echo BUILD_N=%BUILD_N%  OUT_FILE=%OUT_FILE%
echo TOP_K=%TOP_K%      DETAILS_FILE=%DETAILS_FILE%
echo METHOD=%RETRIEVAL_METHOD%  FETCH_K=%RETRIEVAL_FETCH_K%  RERANK=%RERANK%
echo RERANKER=%RERANKER_MODEL%  CANDIDATES=%RERANK_CANDIDATES%  MAX_LEN=%RERANK_MAX_LENGTH%
echo LLM_NUM_PREDICT=%LLM_NUM_PREDICT%  KEEP_ALIVE=%OLLAMA_KEEP_ALIVE%
echo OLLAMA_MODEL=%OLLAMA_MODEL%
echo =======================

if "%INSTALL_DEPS%"=="1" (
  echo [+] Installing/Updating dependencies...
  pip install -U -r backend\requirements.txt || goto :fail
)

rem Build eval set if missing
if not exist "%OUT_FILE%" (
  echo [+] Building eval set: %BUILD_N% items -> %OUT_FILE%
  python -m backend.eval_lite --build %BUILD_N% --out "%OUT_FILE%" || goto :fail
) else (
  echo [=] Using existing eval set: %OUT_FILE%
)

echo [+] Running evaluation...
python -m backend.eval_lite --run --file "%OUT_FILE%" --k %TOP_K% --coverage --details "%DETAILS_FILE%" --progress_every %PROGRESS_EVERY% > "%REPORT_JSON%"
if errorlevel 1 goto :fail

echo [=] Report saved to %REPORT_JSON%

rem Append to Markdown log
if not exist "%LOG_MD%" (
  echo # RAG Evaluation Runs> "%LOG_MD%"
  echo.>> "%LOG_MD%"
)

echo ## %date% %time% >> "%LOG_MD%"
rem Parameters snapshot
echo - tag: %TAG% >> "%LOG_MD%"
echo - model: %OLLAMA_MODEL% >> "%LOG_MD%"
echo - embed_model: %EMBED_MODEL% >> "%LOG_MD%"
echo - top_k: %TOP_K% >> "%LOG_MD%"
echo - retrieval_method: %RETRIEVAL_METHOD% >> "%LOG_MD%"
echo - retrieval_fetch_k: %RETRIEVAL_FETCH_K% >> "%LOG_MD%"
echo - rerank: %RERANK% >> "%LOG_MD%"
echo - reranker_model: %RERANKER_MODEL% >> "%LOG_MD%"
echo - rerank_candidates: %RERANK_CANDIDATES% >> "%LOG_MD%"
echo - rerank_max_length: %RERANK_MAX_LENGTH% >> "%LOG_MD%"
echo - llm_num_predict: %LLM_NUM_PREDICT% >> "%LOG_MD%"
echo - llm_num_ctx: %LLM_NUM_CTX% >> "%LOG_MD%"
echo - keep_alive: %OLLAMA_KEEP_ALIVE% >> "%LOG_MD%"
echo - out_file: %OUT_FILE% >> "%LOG_MD%"
echo - details_file: %DETAILS_FILE% >> "%LOG_MD%"
echo.>> "%LOG_MD%"
echo Results JSON: >> "%LOG_MD%"
echo ```json>> "%LOG_MD%"
type "%REPORT_JSON%" >> "%LOG_MD%"
echo ```>> "%LOG_MD%"
echo.>> "%LOG_MD%"

echo.
echo [OK] Evaluation completed. Appended to %LOG_MD%
type "%REPORT_JSON%"
goto :eof

:fail
echo.
echo [ERR] Evaluation failed. See messages above.
exit /b 1

