# SmartBook RAG — LangChain 版本

说明：
- 使用 LangChain 管理文档加载、切分、嵌入和检索流程。
- 使用 HuggingFaceEmbeddings（SentenceTransformers 后端）+ FAISS 存储向量。
- 使用 langchain-ollama 的 Ollama LLM 连接到本地 Ollama（qwen3:1.7b）。

快速启动：
1. 启动 Ollama： `ollama pull qwen3:1.7b`，`ollama serve`
2. 后端：
   ```
   cd smartbook-rag-langchain/backend
   python -m venv .venv
   source .venv/bin/activate   # Windows: .venv\\Scripts\\activate
   pip install -r requirements.txt
   uvicorn backend.main:app --reload --port 8000（在根目录运行）
   ```
3. 前端：
   ```
   cd frontend
   pip install streamlit requests
   streamlit run app.py
   ```

注意：
- 根据你的本地环境，可能需要调整 `backend/requirements.txt` 中的版本以避免 numpy/pytorch 冲突。
- LangChain 和 langchain-ollama 的版本可能随时间变化；如果遇到导入问题，我可以根据你本地的错误信息做快速修复.
- 想系统了解项目架构与面试要点，可阅读 `docs/PROJECT_GUIDE.md`，若需要逐项学习的能力清单，请看 `docs/LEARNING_CHECKLIST.md`。
