# Generative AI Project – OUK × BCS Jaseci Labs  

This repository contains coursework, practice code, and project development for the **Building Generative AI Applications** short course, jointly offered by **The Open University of Kenya (OUK)** and **BCS Technology International Pty Limited (Jaseci Labs, Australia)**.  

---

## 🎯 About the Course  
This program equips learners with practical skills to design and deploy **Generative AI applications** across diverse domains such as healthcare, agriculture, finance, education, and creative industries.  

Through the **BCS Jaseci Lab ecosystem**, learners gain hands-on experience in:  
- ⚡ Building AI applications with **Jaclang** and Python  
- 🧑‍💻 Developing solutions with pre-trained models for text, images, music, and video  
- 🌍 Applying Generative AI to real-world challenges  
- 🚀 Participating in a final **hackathon project**  

---

## 📂 Repository Contents  
- `src/` → All source code  
  - `assignments/` → Coursework tasks and solutions (Jaclang + Python)  
  - `tutorials/` → Weekly practice notebooks and Jaclang scripts  
  - `project/` → Hackathon final project (code + documentation)  
- `docs/` → Reports, write-ups, and supporting materials  
- `builds/` → Versioned builds (Build 1, Build 2, …)  
- `tests/` → Unit tests and validation scripts  
- `requirements.txt` → Python/Jaclang dependencies  
- `.gitignore`, `LICENSE`, `README.md`  

---

## ⚙️ Setup Instructions  

Clone the repo and set up your environment:  
```bash
# clone repository
git clone https://github.com/Qooley/generative-ai-project-ouk.git
cd generative-ai-project-ouk

# create virtual environment (custom name allowed, e.g., genai-env)
python3 -m venv genai-env
source genai-env/bin/activate   # Linux/Mac
# OR
genai-env\Scripts\activate      # Windows PowerShell

# upgrade pip
pip install --upgrade pip

# install dependencies
pip install -r requirements.txt

