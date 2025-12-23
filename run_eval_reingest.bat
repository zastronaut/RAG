@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

rem =============================================================
rem Re-ingest docs with specified CHUNK_SIZE/OVERLAP, rebuild FAISS,
rem then run evaluation and append results to Markdown (via run_eval.bat)
rem 
rem Usage examples (in CMD from project root):
rem   - run_eval_reingest.bat
rem   - set CHUNK_SIZE=350 && set CHUNK_OVERLAP=80 && run_eval_reingest.bat
rem   - set DOCS="backend\data\uploads\Dive-into-DL-Pytorch.pdf" "backend\data\uploads\084810-01.pdf" && run_eval_reingest.bat
rem   - set TAG=my-exp && run_eval_reingest.bat
rem =============================================================

if "%CHUNK_SIZE%"=="" set CHUNK_SIZE=800
if "%CHUNK_OVERLAP%"=="" set CHUNK_OVERLAP=120
if "%DOCS%"=="" set DOCS="backend\data\uploads\Dive-into-DL-Pytorch.pdf"
if "%INSTALL_DEPS%"=="" set INSTALL_DEPS=0
if "%TAG%"=="" set TAG=reingest-cs%CHUNK_SIZE%-ov%CHUNK_OVERLAP%
if "%OUT_FILE%"=="" set OUT_FILE=eval_set_%TAG%.jsonl

echo ==== Re-ingest settings ====
echo CHUNK_SIZE=%CHUNK_SIZE%  CHUNK_OVERLAP=%CHUNK_OVERLAP%
echo DOCS=%DOCS%
echo TAG=%TAG%
echo ============================

rem Ensure deps if requested (includes FlagEmbedding etc.)
if "%INSTALL_DEPS%"=="1" (
  echo [+] Installing/Updating dependencies...
  pip install -U -r backend\requirements.txt || goto :fail
)

rem 1) Clean vector store
echo [+] Cleaning vector store...
if exist backend\data\vectors (
  rmdir /s /q backend\data\vectors
)
if exist backend\data\index.faiss del /q backend\data\index.faiss
if exist backend\data\index.pkl del /q backend\data\index.pkl

rem 2) Export splitting params for ingestion
set CHUNK_SIZE=%CHUNK_SIZE%
set CHUNK_OVERLAP=%CHUNK_OVERLAP%

rem 3) Ingest each document
for %%F in (%DOCS%) do (
  echo [+] Ingesting: %%~F
  python -c "import sys; from backend.rag import add_documents_from_file as add; n=add(sys.argv[1]); print(n)" "%%~F" || goto :fail
)

echo [=] Ingestion done. Running evaluation with current env...

rem 4) Propagate a meaningful tag to run_eval logging
set TAG=%TAG%

call run_eval.bat
if errorlevel 1 goto :fail

echo.
echo [OK] Re-ingest + Evaluation completed.
goto :eof

:fail
echo.
echo [ERR] Re-ingest or Evaluation failed. See messages above.
exit /b 1

