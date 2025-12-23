#!/bin/bash
echo "确保 ollama serve 已运行并 qwen3:1.7b 可用"
cd backend
pip install -r requirements.txt
uvicorn backend.main:app --reload --port 8000 &
sleep 1
cd ../frontend
pip install streamlit requests
streamlit run app.py &
wait
