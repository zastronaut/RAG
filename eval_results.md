# RAG Evaluation Runs
ECHO is off.
## 周六 2025/12/06 23:52:41.41 
- tag: reingest-cs800-ov120 
- model: qwen2.5:3b-instruct 
- embed_model:  
- top_k: 5 
- retrieval_method: mmr 
- retrieval_fetch_k: 40 
- rerank: 1 
- reranker_model: BAAI/bge-reranker-base 
- rerank_candidates: 40 
- rerank_max_length: 512 
- llm_num_predict: 24 
- llm_num_ctx: 2048 
- keep_alive: 30m 
- out_file: eval_set_lite.jsonl 
- details_file: details_mmr_rerank.jsonl 
ECHO is off.
Results JSON: 
```json 
{
  "N": 150,
  "retrieval_Hit@5": 0.37333333333333335,
  "gen_F1": 0.10515114060694117,
  "gen_semantic_sim": 0.4878927036558509,
  "latency_p50_s": 3.6521944999694824,
  "latency_p95_s": 4.109228479862213,
  "coverage": 0.5533333333333333,
  "max_sim_avg": 0.6352360190492533
}
``` 
ECHO is off.
