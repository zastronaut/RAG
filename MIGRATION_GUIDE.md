# 依赖升级迁移指南

## 快速开始

如果你已经有一个旧版本的项目，按照以下步骤升级：

### 步骤 1: 备份当前环境（可选但推荐）

```bash
# 导出当前已安装的包列表
pip freeze > requirements_backup.txt
```

### 步骤 2: 删除旧的虚拟环境（推荐）

```bash
# Windows
rmdir /s venv

# Linux/macOS
rm -rf venv
```

### 步骤 3: 创建新的虚拟环境

```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/macOS
python3 -m venv venv
source venv/bin/activate
```

### 步骤 4: 安装新的依赖

```bash
cd backend
pip install -r requirements.txt
```

### 步骤 5: 验证安装

```bash
# 运行验证脚本
python ../install_and_verify.py

# 或手动检查关键包
python -c "import langchain; print(f'LangChain: {langchain.__version__}')"
python -c "import langchain_community; print(f'LangChain-Community: {langchain_community.__version__}')"
```

## 常见问题解决

### 问题 1: 安装时出现 "conflicting dependencies" 错误

**原因：** pip 无法解决依赖冲突

**解决方案：**
```bash
# 清除 pip 缓存
pip cache purge

# 重新安装
pip install -r requirements.txt --no-cache-dir
```

### 问题 2: "ModuleNotFoundError: No module named 'langchain_text_splitters'"

**原因：** 某个依赖没有正确安装

**解决方案：**
```bash
# 单独安装缺失的包
pip install langchain-text-splitters>=0.2.0

# 或重新安装所有包
pip install -r requirements.txt --force-reinstall
```

### 问题 3: Sentence-Transformers 下载模型时很慢

**原因：** 默认从 Hugging Face 官方源下载，网络可能较慢

**解决方案：**
```bash
# 方案 A: 使用国内镜像
pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/

# 方案 B: 预先下载模型到本地
python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('BAAI/bge-m3')"

# 方案 C: 使用环境变量指定本地模型
export EMBED_LOCAL_DIR=/path/to/local/model
```

### 问题 4: 安装 PyTorch 时出错

**原因：** PyTorch 的 CUDA 版本与系统不匹配

**解决方案：**
```bash
# 检查 CUDA 版本
nvidia-smi

# 根据 CUDA 版本安装对应的 PyTorch
# CUDA 11.8:
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# CUDA 12.1:
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# CPU only:
pip install torch torchvision torchaudio
```

## 版本对应关系

### LangChain 生态版本对应

| 版本 | 发布日期 | 主要特性 | 支持状态 |
|---|---|---|---|
| 0.3.x | 2024-12 | 最新特性，完整 LCEL 支持 | ✅ 推荐 |
| 0.2.x | 2024-10 | 稳定版本 | ⚠️ 可用但不推荐 |
| 0.1.x | 2024-08 | 旧版本 | ❌ 不支持 |
| 1.x | 2024-06 | 过时版本 | ❌ 不支持 |

### Python 版本要求

| 包 | Python 3.9 | Python 3.10 | Python 3.11 | Python 3.12 |
|---|---|---|---|---|
| langchain 0.3.x | ⚠️ | ✅ | ✅ | ✅ |
| sentence-transformers 3.0 | ⚠️ | ✅ | ✅ | ✅ |
| fastapi 0.115+ | ✅ | ✅ | ✅ | ✅ |
| pydantic 2.8+ | ✅ | ✅ | ✅ | ✅ |

## 性能优化建议

### 1. 启用 GPU 加速

```bash
# 安装 PyTorch with CUDA 支持
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# 在代码中会自动检测并使用 GPU
```

### 2. 使用更小的嵌入模型

```bash
# 在 .env 中配置
EMBED_MODEL=BAAI/bge-small-zh  # 更快，精度略低
# 或
EMBED_MODEL=BAAI/bge-base-zh   # 平衡方案
```

### 3. 调整检索参数

```bash
# 在 .env 中配置
CHUNK_SIZE=300              # 减小 chunk 大小
RETRIEVAL_FETCH_K=20        # 减少初始召回数
RERANK=0                    # 禁用重排序（如果不需要）
```

### 4. 启用缓存

```python
# 在 rag.py 中可以添加缓存装饰器
from functools import lru_cache

@lru_cache(maxsize=128)
def _get_embeddings():
    # ...
```

## 回滚到旧版本

如果新版本出现问题，可以回滚到旧版本：

```bash
# 恢复备份的依赖
pip install -r requirements_backup.txt

# 或手动指定旧版本
pip install langchain==1.1.0 langchain-community==0.0.13
```

## 测试清单

升级后，请运行以下测试确保一切正常：

- [ ] 后端启动成功：`python -m uvicorn backend.main:app --reload`
- [ ] 前端启动成功：`streamlit run frontend/app.py`
- [ ] 能连接到 Ollama 服务
- [ ] 能加载嵌入模型
- [ ] 能上传和处理 PDF 文件
- [ ] 能执行 RAG 查询并获得回答
- [ ] 流式输出正常工作

## 获取帮助

如果遇到问题，请：

1. 查看 `REQUIREMENTS_UPDATE.md` 中的故障排除部分
2. 检查项目的 GitHub Issues
3. 查看 LangChain 官方文档：https://python.langchain.com/
4. 查看相关包的官方文档

## 更新日志

### 2025-12-09
- ✅ 初始版本发布
- ✅ 升级到 LangChain 0.3.x
- ✅ 升级到 sentence-transformers 3.0
- ✅ 升级到 fastapi 0.115+
- ✅ 解决所有已知的版本冲突

## 许可证

本迁移指南遵循项目原有许可证。

