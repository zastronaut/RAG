@echo off
REM ==========================
REM SmartBook-RAG 重启脚本
REM 停止所有服务并重新启动
REM ==========================

echo ========================================
echo 正在停止现有服务...
echo ========================================

REM 停止占用 8000 端口的进程（后端）
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8000" ^| findstr "LISTENING"') do (
    echo 停止后端服务 (PID: %%a)...
    taskkill /PID %%a /F >nul 2>&1
)

REM 停止占用 8501 端口的进程（前端）
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8501" ^| findstr "LISTENING"') do (
    echo 停止前端服务 (PID: %%a)...
    taskkill /PID %%a /F >nul 2>&1
)

REM 等待服务完全停止
timeout /t 2 /nobreak >nul

echo.
echo ========================================
echo 检查 Ollama 服务...
echo ========================================
echo 请确保 ollama serve 正在运行
echo 如果未运行，请在另一个命令行执行: ollama serve
echo.
pause

echo.
echo ========================================
echo 正在启动后端服务...
echo ========================================
cd backend
start cmd /k "title SmartBook Backend && uvicorn main:app --reload --port 8000"
cd ..

REM 等待后端启动
timeout /t 3 /nobreak >nul

echo.
echo ========================================
echo 正在启动前端服务...
echo ========================================
cd frontend
start cmd /k "title SmartBook Frontend && streamlit run app.py"
cd ..

echo.
echo ========================================
echo 服务启动完成！
echo ========================================
echo 后端 API: http://localhost:8000
echo 前端界面: http://localhost:8501
echo API 文档: http://localhost:8000/docs
echo.
echo 请查看新弹出的两个命令行窗口查看服务状态
echo.
pause


