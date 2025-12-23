# 快速开始指南

## 📋 前置要求

- Python 3.11+ （推荐 3.11 或 3.12）
- Ollama（用于 LLM）
- Git（可选）

## 🚀 5 分钟快速安装

### 1️⃣ 克隆或下载项目

```bash
git clone <repo-url>
cd smartbook-rag-langchain
```

### 2️⃣ 创建虚拟环境

```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/macOS
python3 -m venv venv
source venv/bin/activate
```

### 3️⃣ 安装依赖

```bash
# 自动安装脚本（推荐）
# Windows
install_dependencies.bat

# Linux/macOS
bash install_dependencies.sh

# 或手动安装
cd backend
pip install -r requirements.txt
```

### 4️⃣ 配置环境变量

```bash
# 复制示例配置
cp backend/.env.example backend/.env

# 编辑 .env 文件（可选，使用默认值也可以）
# 重要配置项：
# - OLLAMA_HOST=http://localhost:11434
# - OLLAMA_MODEL=qwen2.5:3b-instruct
# - EMBED_MODEL=BAAI/bge-m3
```

### 5️⃣ 启动 Ollama

```bash
# 在另一个终端运行
ollama serve

# 拉取模型（如果还没有）
ollama pull qwen2.5:3b-instruct
```

### 6️⃣ 启动后端

```bash
cd backend
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

访问 http://localhost:8000/docs 查看 API 文档

### 7️⃣ 启动前端（新终端）

```bash
cd frontend
streamlit run app.py
```

访问 http://localhost:8501 使用前端界面

## 📚 常用命令

### 验证安装

```bash
python install_and_verify.py
```

### 查看 API 文档

```
http://localhost:8000/docs
```

### 查看日志

```bash
# 后端日志会在启动的终端中显示
# 前端日志也会在启动的终端中显示
```

## 🎯 第一次使用

1. **打开前端界面**：http://localhost:8501

2. **上传文档**：
   - 点击左侧 "上传 PDF 或 TXT"
   - 选择文件
   - 点击 "上传/更新向量库"
   - 等待处理完成

3. **提问**：
   - 在文本框输入问题
   - 点击 "提问"
   - 等待 AI 回答

## ⚙️ 常见配置

### 使用不同的 LLM 模型

```bash
# 在 .env 中修改
OLLAMA_MODEL=llama2:13b  # 更强大但更慢
OLLAMA_MODEL=neural-chat:7b  # 更快但精度略低
```

### 使用不同的嵌入模型

```bash
# 在 .env 中修改
EMBED_MODEL=BAAI/bge-large-zh  # 更精准但更慢
EMBED_MODEL=BAAI/bge-small-zh  # 更快但精度略低
```

### 启用 GPU 加速

```bash
# 安装 PyTorch with CUDA
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# 代码会自动检测并使用 GPU
```

### 调整检索参数

```bash
# 在 .env 中修改
CHUNK_SIZE=300              # 减小 chunk 大小（更快）
RETRIEVAL_FETCH_K=20        # 减少初始召回数（更快）
RERANK=0                    # 禁用重排序（更快）
```

## 🔧 故障排除

### 后端无法启动

```bash
# 检查端口是否被占用
# Windows
netstat -ano | findstr :8000

# Linux/macOS
lsof -i :8000

# 使用不同的端口
python -m uvicorn backend.main:app --port 8001
```

### 无法连接到 Ollama

```bash
# 检查 Ollama 是否运行
curl http://localhost:11434/api/tags

# 如果失败，启动 Ollama
ollama serve

# 检查模型是否存在
ollama list

# 如果没有，拉取模型
ollama pull qwen2.5:3b-instruct
```

### 嵌入模型下载很慢

```bash
# 方案 1: 使用国内镜像
pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/

# 方案 2: 预先下载
python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('BAAI/bge-m3')"

# 方案 3: 使用本地模型
# 将模型文件放在本地，设置环境变量
export EMBED_LOCAL_DIR=/path/to/model
```

### 内存不足

```bash
# 使用更小的模型
EMBED_MODEL=BAAI/bge-small-zh
OLLAMA_MODEL=neural-chat:7b

# 减少 chunk 大小
CHUNK_SIZE=300

# 禁用重排序
RERANK=0
```

## 📖 更多文档

- [完整的 Requirements 更新说明](REQUIREMENTS_UPDATE.md)
- [版本对比详细分析](VERSION_COMPARISON.md)
- [迁移指南](MIGRATION_GUIDE.md)
- [项目代码说明](docs/CODE_WALKTHROUGH.md)

## 🆘 获取帮助

1. 查看 [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. 查看项目 GitHub Issues
3. 查看相关包的官方文档：
   - [LangChain](https://python.langchain.com/)
   - [Ollama](https://ollama.ai/)
   - [Streamlit](https://docs.streamlit.io/)

## 💡 提示

- 第一次运行会下载模型，可能需要几分钟
- 建议在 GPU 上运行以获得更好的性能
- 可以同时上传多个文档
- 支持 PDF 和 TXT 文件
- 自动处理扫描 PDF 的 OCR

## 📊 系统要求

| 组件 | 最低要求 | 推荐配置 |
|---|---|---|
| CPU | 4 核 | 8 核+ |
| RAM | 8GB | 16GB+ |
| GPU | 无 | NVIDIA RTX 3060+ |
| 磁盘 | 20GB | 50GB+ |
| 网络 | 10Mbps | 100Mbps+ |

## 🎓 学习资源

- [RAG 优化指南](docs/RAG_optimization_bge_small_zh.md)
- [项目学习清单](docs/LEARNING_CHECKLIST.md)
- [项目指南](docs/PROJECT_GUIDE.md)

---

**祝你使用愉快！** 🎉

如有问题，欢迎提交 Issue 或 PR。

