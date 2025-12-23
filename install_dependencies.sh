#!/bin/bash

# 快速安装依赖脚本 (Linux/macOS)

echo "============================================================"
echo "SmartBook RAG - 依赖安装脚本"
echo "============================================================"
echo ""

# 检查 Python 是否安装
if ! command -v python3 &> /dev/null; then
    echo "错误: 未找到 Python3，请先安装 Python 3.11+"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo "Python 版本: $PYTHON_VERSION"
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKEND_DIR="$SCRIPT_DIR/backend"

# 检查 requirements.txt 是否存在
if [ ! -f "$BACKEND_DIR/requirements.txt" ]; then
    echo "错误: 找不到 $BACKEND_DIR/requirements.txt"
    exit 1
fi

echo "步骤 1: 升级 pip..."
python3 -m pip install --upgrade pip

echo ""
echo "步骤 2: 安装 requirements.txt 中的包..."
cd "$BACKEND_DIR"
python3 -m pip install -r requirements.txt

if [ $? -ne 0 ]; then
    echo ""
    echo "错误: 依赖安装失败"
    exit 1
fi

echo ""
echo "============================================================"
echo "依赖安装完成！"
echo "============================================================"
echo ""
echo "后续步骤:"
echo "1. 配置环境变量 (参考 REQUIREMENTS_UPDATE.md)"
echo "2. 启动 Ollama 服务"
echo "3. 运行后端: python3 -m uvicorn backend.main:app --reload"
echo "4. 运行前端: streamlit run frontend/app.py"
echo ""

