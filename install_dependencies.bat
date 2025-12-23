@echo off
REM 快速安装依赖脚本 (Windows)

echo ============================================================
echo SmartBook RAG - 依赖安装脚本
echo ============================================================
echo.

REM 检查 Python 是否安装
python --version >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到 Python，请先安装 Python 3.11+
    pause
    exit /b 1
)

echo 正在安装依赖包...
echo.

REM 升级 pip
echo 步骤 1: 升级 pip...
python -m pip install --upgrade pip

REM 安装依赖
echo.
echo 步骤 2: 安装 requirements.txt 中的包...
cd /d "%~dp0backend"
python -m pip install -r requirements.txt

if errorlevel 1 (
    echo.
    echo 错误: 依赖安装失败
    pause
    exit /b 1
)

echo.
echo ============================================================
echo 依赖安装完成！
echo ============================================================
echo.
echo 后续步骤:
echo 1. 配置环境变量 (参考 REQUIREMENTS_UPDATE.md)
echo 2. 启动 Ollama 服务
echo 3. 运行后端: python -m uvicorn backend.main:app --reload
echo 4. 运行前端: streamlit run frontend/app.py
echo.
pause

