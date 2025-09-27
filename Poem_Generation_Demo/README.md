📖 Poem Generator — Jac + by llm() Showcase

This folder contains a small project demonstrating Jac’s Meaning-Typed Programming (MTP) with the by llm() operator, and how Jac semantics can be imported into Python and wrapped with FastAPI.

⚡ What’s Inside

generate_poem.jac → Jac semantic defining the Poem type with by llm().

poem_server.py → FastAPI server exposing the Jac function as an API.

Example usage in Python (import generate_poem as poem_mod).

📝 Jac Semantic
sem Poem {
    has title: str;
    has subject: str;
    has person_for: str;
    has body: str by llm();
}

can generate_poem(title: str, subject: str, person_for: str) -> Poem by llm() {
    => { return Poem(title=title, subject=subject, person_for=person_for); }
}

🐍 Python Integration
import jaclang          # enables importing .jac files as modules
import generate_poem as poem_mod   # imports generate_poem.jac

poem = poem_mod.generate_poem(
    "My Cherry",
    "Love and desire to have her this very moment",
    "Cherry"
)

print(poem.body)


This shows that Jac semantics run just as easily in Python.

🌐 FastAPI Wrapper
uvicorn poem_server:app --host 0.0.0.0 --port 8000 --reload


Then call with:

curl -X POST http://127.0.0.1:8000/generate_poem \
  -H "Content-Type: application/json" \
  -d '{"title":"My Cherry","subject":"Love and desire to have her this very moment","person_for":"Cherry"}'

📌 Notes

Jac Cloud didn’t render with serve, so this project is run locally with uvicorn.

Can also be run on Colab with pyngrok for quick sharing.