# Minimal FastAPI dashboard backend placeholder (extend with templates/frontend)
from fastapi import FastAPI
app = FastAPI()
@app.get("/health")
def health(): return {"ok": True}
