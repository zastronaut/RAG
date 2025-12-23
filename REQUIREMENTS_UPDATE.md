# Requirements.txt 更新说明

## 概述
根据项目的实际代码需求，重新编写了 `backend/requirements.txt`，解决了原有的版本冲突问题，并升级到较新的包版本。

## 主要变更

### 1. **FastAPI 和 Web 框架**
| 包 | 旧版本 | 新版本 | 原因 |
|---|---|---|---|
| fastapi | 0.110.0 | ≥0.115.0 | 获得最新的性能优化和安全补丁 |
| uvicorn | 0.22.0 | ≥0.30.0 | 支持最新的 ASGI 标准和性能改进 |
| python-multipart | 0.0.6 | ≥0.0.7 | 修复文件上传相关的 bug |
| pydantic | 2.6.4 | ≥2.8.0 | 更好的验证和序列化性能 |

### 2. **向量数据库和嵌入**
| 包 | 旧版本 | 新版本 | 原因 |
|---|---|---|---|
| faiss-cpu | 1.7.4 | ≥1.8.0 | 改进的向量搜索性能和 bug 修复 |
| sentence-transformers | 2.6.1 | ≥3.0.0 | 主要版本升级，支持更新的 Hugging Face 模型 |
| numpy | 1.26.4 | ≥1.26.4 | 保持稳定版本（已是较新版本） |

### 3. **PDF 处理和 OCR**
| 包 | 旧版本 | 新版本 | 原因 |
|---|---|---|---|
| pymupdf | ≥1.23.0 | ≥1.24.0 | 更好的 PDF 解析和 OCR 支持 |
| Pillow | ≥10.0.0 | ≥11.0.0 | 主要版本升级，性能和安全改进 |
| pytesseract | ≥0.3.10 | ≥0.3.10 | 保持稳定版本 |

### 4. **LangChain 生态（关键变更）**

**原有问题：**
- `langchain-community>=0.3.9,<1.0.0` 与其他包版本不兼容
- 混合使用旧版本 LangChain 和新版本 LangChain-community 导致冲突

**新方案：**
```
langchain>=0.3.0,<0.4.0
langchain-core>=0.3.0,<0.4.0
langchain-community>=0.3.0,<0.4.0
langchain-text-splitters>=0.2.0
langchain-huggingface>=0.1.0
langchain-ollama>=0.2.0
```

**优势：**
- 所有 LangChain 相关包统一为 0.3.x 版本系列
- 完全兼容 Python 3.11+
- 支持最新的 LCEL（LangChain Expression Language）
- 消除弃用警告
- 更好的流式输出支持

### 5. **其他包**
| 包 | 旧版本 | 新版本 | 原因 |
|---|---|---|---|
| requests | 2.31.0 | ≥2.32.0 | 安全和性能更新 |
| python-dotenv | 1.0.0 | ≥1.0.1 | 小版本更新，bug 修复 |
| FlagEmbedding | ≥1.2.10 | ≥1.3.0 | 支持更新的重排序模型 |
| streamlit | 新增 | ≥1.40.0 | 前端依赖，确保与最新版本兼容 |

## 版本冲突解决方案

### 问题 1：LangChain 版本不一致
**原因：** 原文件中 `langchain>=1.1.0,<2.0.0` 与 `langchain-community>=0.3.9` 版本跨度过大

**解决：** 统一使用 0.3.x 系列，确保所有子包版本一致

### 问题 2：Sentence-Transformers 与 Transformers 兼容性
**原因：** 旧版本 sentence-transformers 2.6.1 对 transformers 的依赖版本较低

**解决：** 升级到 3.0.0，自动依赖最新的 transformers

### 问题 3：PyMuPDF 和 Pillow 版本过旧
**原因：** 原版本可能在某些 PDF 解析和 OCR 场景中出现问题

**解决：** 升级到最新版本，获得更好的稳定性

## 安装说明

### 方式 1：直接安装（推荐）
```bash
cd backend
pip install -r requirements.txt
```

### 方式 2：使用虚拟环境（最佳实践）
```bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
cd backend
pip install -r requirements.txt
```

### 方式 3：如果需要 GPU 加速（可选）
取消注释 requirements.txt 中的 torch 相关行：
```bash
# 取消注释以下行
# torch>=2.0.0
# torchvision>=0.15.0
# torchaudio>=2.0.0
```

## 验证安装

安装完成后，运行以下命令验证：

```bash
# 检查关键包版本
python -c "import langchain; print(f'LangChain: {langchain.__version__}')"
python -c "import langchain_core; print(f'LangChain-Core: {langchain_core.__version__}')"
python -c "import langchain_community; print(f'LangChain-Community: {langchain_community.__version__}')"
python -c "import sentence_transformers; print(f'Sentence-Transformers: {sentence_transformers.__version__}')"
python -c "import fastapi; print(f'FastAPI: {fastapi.__version__}')"
```

## 运行项目

### 启动后端
```bash
cd backend
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 启动前端
```bash
cd frontend
streamlit run app.py
```

## 环境变量配置

项目支持以下环境变量（可在 `.env` 文件中配置）：

```env
# Ollama 配置
OLLAMA_HOST=http://localhost:11434
OLLAMA_MODEL=qwen2.5:3b-instruct
OLLAMA_KEEP_ALIVE=30m

# 嵌入模型
EMBED_MODEL=BAAI/bge-m3

# LLM 参数
LLM_TEMPERATURE=0.0
LLM_NUM_PREDICT=24
LLM_NUM_CTX=2048

# 检索参数
RETRIEVAL_METHOD=mmr
RETRIEVAL_FETCH_K=40
CHUNK_SIZE=500
CHUNK_OVERLAP=100

# 重排序
RERANK=1
RERANKER_MODEL=BAAI/bge-reranker-base
RERANK_CANDIDATES=40
RERANK_MAX_LENGTH=512

# OCR 配置（可选）
OCR_SCALE=3.0
TESSERACT_CMD=/usr/bin/tesseract  # Linux
# TESSERACT_CMD=C:\Program Files\Tesseract-OCR\tesseract.exe  # Windows
```

## 已知兼容性

- ✅ Python 3.11+
- ✅ Windows 10/11
- ✅ macOS 12+
- ✅ Linux (Ubuntu 20.04+)
- ✅ Ollama 0.1.0+
- ✅ CUDA 11.8+ (可选，用于 GPU 加速)

## 故障排除

### 1. 导入错误：`ModuleNotFoundError: No module named 'langchain_text_splitters'`
**解决：** 确保安装了 `langchain-text-splitters>=0.2.0`
```bash
pip install langchain-text-splitters>=0.2.0
```

### 2. Ollama 连接失败
**解决：** 检查 Ollama 服务是否运行，确认 `OLLAMA_HOST` 环境变量正确
```bash
# 测试连接
curl http://localhost:11434/api/tags
```

### 3. 向量化速度慢
**解决：** 
- 检查是否使用了 GPU（安装 torch 并配置 CUDA）
- 减小 `CHUNK_SIZE` 或 `RETRIEVAL_FETCH_K`
- 使用更小的嵌入模型（如 `BAAI/bge-small-zh`）

### 4. OCR 不工作
**解决：** 确保安装了 Tesseract-OCR 和中文语言包
```bash
# Ubuntu/Debian
sudo apt-get install tesseract-ocr tesseract-ocr-chi-sim

# macOS
brew install tesseract

# Windows：下载安装程序
# https://github.com/UB-Mannheim/tesseract/wiki
```

## 更新历史

| 日期 | 版本 | 变更 |
|---|---|---|
| 2025-12-09 | 1.0 | 初始版本，解决依赖冲突，升级到最新稳定版本 |

## 许可证

本项目遵循原有许可证。详见 LICENSE 文件。

