# 📖 Poem Generator — Jac + `by llm()` Showcase  

This is a small project demonstrating **Jac’s Meaning-Typed Programming (MTP)** with the **`by llm()`** operator, and how Jac semantics can be imported into Python and wrapped with FastAPI.  

---

## ⚡ What’s Inside  
- `generate_poem.jac` → Jac semantic defining the `Poem` type with `by llm()`.  
- `poem_server.py` → FastAPI server exposing the Jac function as an API.  

---

## 📝 Jac Semantic  
```jac
sem Poem {
    has title: str;
    has subject: str;
    has person_for: str;
    has body: str by llm();
}

can generate_poem(title: str, subject: str, person_for: str) -> Poem by llm() {
    => { return Poem(title=title, subject=subject, person_for=person_for); }
}
```
---
## 🐍 Python Integration
```python
import jaclang
import generate_poem as poem_mod

poem = poem_mod.generate_poem(
    "My Cherry",
    "Love and desire to have her this very moment",
    "Cherry"
)
print(poem.body)
```
---
## 🌐 Run Locally with FastAPI
```bash
uvicorn poem_server:app --host 0.0.0.0 --port 8000 --reload

