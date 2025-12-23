# SmartBook RAG 项目故障排除指南

## 问题：无法访问 localhost:8501（ERR_CONNECTION_REFUSED）

### 问题描述
浏览器显示错误信息：
```
嗯… 无法访问此页面
localhost 拒绝连接。
ERR_CONNECTION_REFUSED
```

### 问题原因
这个错误通常表示：
1. **前端服务（Streamlit）未启动** - 最常见的原因
2. **端口被占用** - 8501 端口被其他程序占用
3. **服务启动失败** - Streamlit 启动时遇到错误
4. **防火墙阻止** - Windows 防火墙阻止了端口访问

---

## 解决方案

### 方案 1：启动前端服务（最常用）

#### 方法 A：从项目根目录启动（推荐）

1. 打开 PowerShell 或 CMD 终端
2. 进入项目根目录：
   ```powershell
   cd C:\Users\16094\Desktop\smartbook-rag-langchain
   ```
3. 启动 Streamlit 前端：
   ```powershell
   streamlit run frontend/app.py
   ```
4. 等待看到以下输出：
   ```
   You can now view your Streamlit app in your browser.
   Local URL: http://localhost:8501
   ```
5. 在浏览器中访问 http://localhost:8501

#### 方法 B：进入 frontend 目录启动

1. 打开 PowerShell 或 CMD 终端
2. 进入 frontend 目录：
   ```powershell
   cd C:\Users\16094\Desktop\smartbook-rag-langchain\frontend
   ```
3. 启动 Streamlit：
   ```powershell
   streamlit run app.py
   ```

#### 方法 C：使用批处理脚本（Windows）

1. 双击运行 `run_smartbook.bat`
2. 脚本会自动启动后端和前端服务
3. 等待两个命令行窗口都显示服务已启动

---

### 方案 2：检查端口占用情况

如果端口被占用，可以：

#### 检查端口占用
```powershell
netstat -ano | findstr ":8501"
```

#### 如果端口被占用，有两种选择：

**选择 A：停止占用端口的进程**
1. 找到占用端口的进程 ID（PID）
2. 结束进程：
   ```powershell
   taskkill /PID <进程ID> /F
   ```
3. 重新启动 Streamlit

**选择 B：使用其他端口**
```powershell
streamlit run frontend/app.py --server.port 8502
```
然后访问 http://localhost:8502

---

### 方案 3：检查服务依赖

确保所有服务都已正确启动：

#### 1. 检查后端服务（FastAPI）

在浏览器中访问：http://localhost:8000/health

应该看到：
```json
{"status":"ok"}
```

如果无法访问，启动后端：
```powershell
cd backend
uvicorn main:app --reload --port 8000
```

或者从项目根目录：
```powershell
uvicorn backend.main:app --reload --port 8000
```

#### 2. 检查 Ollama 服务

确保 Ollama 正在运行：
```powershell
ollama serve
```

在另一个终端检查模型是否可用：
```powershell
ollama list
```

如果没有 qwen3:1.7b 模型，下载它：
```powershell
ollama pull qwen3:1.7b
```

---

### 方案 4：检查防火墙设置

如果服务已启动但仍无法访问，可能是防火墙问题：

1. 打开 Windows 安全中心
2. 进入"防火墙和网络保护"
3. 点击"允许应用通过防火墙"
4. 确保 Python 和 Pythonw 被允许通过防火墙
5. 或者临时关闭防火墙测试（不推荐长期使用）

---

### 方案 5：检查依赖安装

确保所有依赖都已正确安装：

#### 检查前端依赖
```powershell
pip list | findstr streamlit
pip list | findstr requests
```

如果没有，安装：
```powershell
pip install streamlit requests
```

#### 检查后端依赖
```powershell
cd backend
pip install -r requirements.txt
```

---

## 完整启动流程

### 步骤 1：启动 Ollama（如果未运行）

打开第一个终端：
```powershell
ollama serve
```

### 步骤 2：启动后端服务

打开第二个终端：
```powershell
cd C:\Users\16094\Desktop\smartbook-rag-langchain\backend
uvicorn main:app --reload --port 8000
```

验证后端运行：
- 访问 http://localhost:8000/health
- 应该返回 `{"status":"ok"}`

### 步骤 3：启动前端服务

打开第三个终端：
```powershell
cd C:\Users\16094\Desktop\smartbook-rag-langchain
streamlit run frontend/app.py
```

验证前端运行：
- 访问 http://localhost:8501
- 应该看到 SmartBook RAG 界面

---

## 常见错误及解决方法

### 错误 1：`File does not exist: app.py`

**原因**：当前目录不正确

**解决**：
```powershell
# 确保在正确的目录
cd C:\Users\16094\Desktop\smartbook-rag-langchain\frontend
# 或者从根目录使用完整路径
cd C:\Users\16094\Desktop\smartbook-rag-langchain
streamlit run frontend/app.py
```

### 错误 2：`ImportError: attempted relative import with no known parent package`

**原因**：相对导入问题（已修复）

**解决**：代码已更新，支持两种导入方式。如果仍有问题，确保使用正确的启动命令。

### 错误 3：`ModuleNotFoundError: No module named 'xxx'`

**原因**：缺少依赖包

**解决**：
```powershell
# 安装后端依赖
cd backend
pip install -r requirements.txt

# 安装前端依赖
pip install streamlit requests
```

### 错误 4：`Address already in use`

**原因**：端口被占用

**解决**：
- 找到占用端口的进程并结束它
- 或使用其他端口（见方案 2）

### 错误 5：后端连接失败

**原因**：后端服务未启动或端口不匹配

**解决**：
1. 检查后端是否在 8000 端口运行
2. 检查前端配置的 Backend URL 是否正确（默认是 http://localhost:8000）
3. 确保后端服务已启动

---

## 快速诊断命令

### 检查所有服务状态
```powershell
# 检查端口占用
netstat -ano | findstr ":8000 :8501"

# 检查后端健康状态
curl http://localhost:8000/health

# 检查 Ollama 状态
ollama list
```

### 查看服务日志
- **后端日志**：查看运行 `uvicorn` 的终端窗口
- **前端日志**：查看运行 `streamlit` 的终端窗口
- 错误信息通常会显示在这些终端中

---

## 验证服务正常运行

### 后端验证
1. 访问 http://localhost:8000/docs - 应该看到 FastAPI 文档界面
2. 访问 http://localhost:8000/health - 应该返回 `{"status":"ok"}`

### 前端验证
1. 访问 http://localhost:8501 - 应该看到 SmartBook RAG 界面
2. 界面应该显示：
   - 标题："📘 SmartBook RAG — LangChain 版本"
   - 侧边栏有文件上传功能
   - 主区域有提问输入框

### 完整功能测试
1. 上传一个 PDF 或 TXT 文件
2. 输入一个问题
3. 点击"提问"按钮
4. 应该看到回答和来源信息

---

## 获取帮助

如果以上方法都无法解决问题，请提供以下信息：

1. **错误信息**：完整的错误日志
2. **服务状态**：运行 `netstat -ano | findstr ":8000 :8501"` 的结果
3. **Python 版本**：`python --version`
4. **依赖版本**：`pip list`
5. **操作系统**：Windows 版本信息

---

## 预防措施

为了避免将来出现类似问题：

1. **使用虚拟环境**：
   ```powershell
   python -m venv .venv
   .venv\Scripts\activate
   pip install -r backend/requirements.txt
   pip install streamlit requests
   ```

2. **使用启动脚本**：
   - Windows: `run_smartbook.bat`
   - Linux/Mac: `run_all.sh`

3. **检查服务状态**：
   - 启动前检查端口是否被占用
   - 使用健康检查端点验证服务

4. **保持依赖更新**：
   - 定期更新 requirements.txt
   - 注意版本兼容性

---

## 总结

**最常见的问题**：前端服务（Streamlit）未启动

**最快的解决方法**：
```powershell
cd C:\Users\16094\Desktop\smartbook-rag-langchain
streamlit run frontend/app.py
```

**完整的服务启动顺序**：
1. Ollama 服务
2. 后端服务（FastAPI）
3. 前端服务（Streamlit）

按照这个顺序启动，通常可以解决大部分连接问题。

