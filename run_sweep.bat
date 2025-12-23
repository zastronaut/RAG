@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem =============================================================
rem Parameter sweep to find best performance combos.
rem - Re-ingests corpus for two splitter settings (800/120 and 350/80)
rem - For each, runs several eval configs and logs to eval_results.md
rem - Progress lines are printed every PROGRESS_EVERY samples to stderr.
rem
rem You can override before running, e.g.:
rem   set BUILD_N=60
rem   set PROGRESS_EVERY=10
rem   set DOCS="backend\data\uploads\Dive-into-DL-Pytorch.pdf"
rem   set OLLAMA_MODEL=qwen2.5:3b-instruct
rem   run_sweep.bat
rem =============================================================

if "%INSTALL_DEPS%"=="" set INSTALL_DEPS=0
if "%BUILD_N%"=="" set BUILD_N=60
if "%PROGRESS_EVERY%"=="" set PROGRESS_EVERY=10
if "%DOCS%"=="" set DOCS="backend\data\uploads\Dive-into-DL-Pytorch.pdf"
if "%LOG_MD%"=="" set LOG_MD=eval_results.md
if "%OLLAMA_MODEL%"=="" set OLLAMA_MODEL=qwen2.5:3b-instruct

rem Global defaults (can override per-case)
set EVAL_MODE=1
set RETRIEVAL_METHOD=mmr
set RETRIEVAL_FETCH_K=60
set RERANK=1
set RERANK_CANDIDATES=40
set RERANK_MAX_LENGTH=1024
set LLM_NUM_PREDICT=128
set LLM_NUM_CTX=2048
set OLLAMA_KEEP_ALIVE=30m

echo ==== SWEEP SETTINGS ====
echo BUILD_N=%BUILD_N%  PROGRESS_EVERY=%PROGRESS_EVERY%
echo DOCS=%DOCS%
echo MODEL=%OLLAMA_MODEL%
echo LOG_MD=%LOG_MD%
echo ========================

if "%INSTALL_DEPS%"=="1" (
  echo [+] Installing/Updating dependencies...
  pip install -U -r backend\requirements.txt || goto :fail
)

rem ---------- Helper to run a single eval case on current ingestion ----------
rem Args: %1=BASE_TAG  %2=SUFFIX  %3=TOP_K  %4=RERANK  %5=RERANK_CANDIDATES  %6=RERANK_MAX_LENGTH  %7=LLM_NUM_PREDICT
:case
set BASE_TAG=%~1
set SUFFIX=%~2
set TOP_K=%~3
set RERANK=%~4
if not "%~5"=="" set RERANK_CANDIDATES=%~5
if not "%~6"=="" set RERANK_MAX_LENGTH=%~6
if not "%~7"=="" set LLM_NUM_PREDICT=%~7

set TAG=%BASE_TAG%-%SUFFIX%
set OUT_FILE=eval_set_%BASE_TAG%.jsonl
call run_eval.bat || goto :fail
exit /b 0

rem ---------- A) Ingest with chunk 800/120 ----------
set CHUNK_SIZE=800
set CHUNK_OVERLAP=120
set TAG=cs800-ov120
set OUT_FILE=eval_set_%TAG%.jsonl
set INSTALL_DEPS=%INSTALL_DEPS%
set DOCS=%DOCS%
call run_eval_reingest.bat || goto :fail

rem Cases on cs800-ov120 (reuse same eval set)
call :case cs800-ov120 k5-norerank 5 0 "" "" 24
call :case cs800-ov120 k3-norerank-np16 3 0 "" "" 16
call :case cs800-ov120 k5-rerank32 5 1 32 512 24
call :case cs800-ov120 k5-rerank40 5 1 40 512 24

rem ---------- B) Ingest with chunk 350/80 ----------
set CHUNK_SIZE=350
set CHUNK_OVERLAP=80
set TAG=cs350-ov80
set OUT_FILE=eval_set_%TAG%.jsonl
call run_eval_reingest.bat || goto :fail

rem Cases on cs350-ov80 (reuse same eval set)
call :case cs350-ov80 k5-norerank 5 0 "" "" 24
call :case cs350-ov80 k3-norerank-np16 3 0 "" "" 16
call :case cs350-ov80 k5-rerank32 5 1 32 512 24

echo.
echo [OK] Sweep finished. See %LOG_MD% for consolidated logs and last_report.json for last run.
goto :eof

:fail
echo.
echo [ERR] Sweep failed. See messages above.
exit /b 1

