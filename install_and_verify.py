#!/usr/bin/env python3
"""
快速安装和验证脚本
用于安装依赖并验证关键包的版本
"""

import subprocess
import sys
from pathlib import Path

def run_command(cmd, description=""):
    """运行命令并返回结果"""
    if description:
        print(f"\n📦 {description}...")
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"❌ 失败: {result.stderr}")
            return False
        if result.stdout:
            print(result.stdout)
        return True
    except Exception as e:
        print(f"❌ 错误: {e}")
        return False

def check_version(module_name, import_name=None):
    """检查模块版本"""
    if import_name is None:
        import_name = module_name
    
    try:
        mod = __import__(import_name)
        version = getattr(mod, '__version__', 'unknown')
        print(f"✅ {module_name}: {version}")
        return True
    except ImportError:
        print(f"❌ {module_name}: 未安装")
        return False

def main():
    print("=" * 60)
    print("SmartBook RAG - 依赖安装和验证")
    print("=" * 60)
    
    # 检查 Python 版本
    print(f"\n🐍 Python 版本: {sys.version}")
    if sys.version_info < (3, 11):
        print("⚠️  警告: 建议使用 Python 3.11 或更高版本")
    
    # 获取项目根目录
    project_root = Path(__file__).parent
    backend_dir = project_root / "backend"
    requirements_file = backend_dir / "requirements.txt"
    
    if not requirements_file.exists():
        print(f"❌ 找不到 requirements.txt: {requirements_file}")
        return False
    
    print(f"\n📄 Requirements 文件: {requirements_file}")
    
    # 安装依赖
    print("\n" + "=" * 60)
    print("第 1 步: 安装依赖包")
    print("=" * 60)
    
    if not run_command(
        f"{sys.executable} -m pip install -r {requirements_file}",
        "安装 requirements.txt 中的所有包"
    ):
        print("❌ 依赖安装失败")
        return False
    
    # 验证关键包
    print("\n" + "=" * 60)
    print("第 2 步: 验证关键包版本")
    print("=" * 60)
    
    critical_packages = [
        ("fastapi", "fastapi"),
        ("uvicorn", "uvicorn"),
        ("pydantic", "pydantic"),
        ("langchain", "langchain"),
        ("langchain-core", "langchain_core"),
        ("langchain-community", "langchain_community"),
        ("sentence-transformers", "sentence_transformers"),
        ("faiss-cpu", "faiss"),
        ("pymupdf", "fitz"),
        ("Pillow", "PIL"),
        ("streamlit", "streamlit"),
    ]
    
    all_ok = True
    for pkg_name, import_name in critical_packages:
        if not check_version(pkg_name, import_name):
            all_ok = False
    
    # 验证 LangChain 子模块
    print("\n🔗 LangChain 子模块:")
    try:
        from langchain_text_splitters import RecursiveCharacterTextSplitter
        print("✅ langchain-text-splitters: 可用")
    except ImportError:
        print("❌ langchain-text-splitters: 未安装")
        all_ok = False
    
    try:
        from langchain_huggingface import HuggingFaceEmbeddings
        print("✅ langchain-huggingface: 可用")
    except ImportError:
        print("❌ langchain-huggingface: 未安装")
        all_ok = False
    
    try:
        from langchain_ollama import ChatOllama
        print("✅ langchain-ollama: 可用")
    except ImportError:
        print("❌ langchain-ollama: 未安装")
        all_ok = False
    
    # 最终结果
    print("\n" + "=" * 60)
    if all_ok:
        print("✅ 所有依赖验证通过！")
        print("=" * 60)
        print("\n📝 后续步骤:")
        print("1. 配置环境变量 (参考 REQUIREMENTS_UPDATE.md)")
        print("2. 启动 Ollama 服务")
        print("3. 运行后端: python -m uvicorn backend.main:app --reload")
        print("4. 运行前端: streamlit run frontend/app.py")
        return True
    else:
        print("❌ 某些依赖验证失败，请检查上述错误")
        print("=" * 60)
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)

