
---

## 3️⃣ `yield_ai_advisor/README.md`
```markdown
# Yield AI Advisor (Step 6)

This module extends the yield estimator by integrating **advisory intelligence**.  
It calculates yield AND provides management advice, either:
- via **heuristics** (default, no external API needed), or  
- via **byLLM** (optional, if LLM API is available and configured).  

---

## Features
- 🌾 Input: Crop, region, acreage, expected yield/ha.  
- 📊 Output: Total yield (kg).  
- 🧠 Advisory: Contextual tips for soil, pest, and management practices.  

---

## Usage
Run interactively:
```bash
jac run yield_ai_advisor/yield_ai.jac

Example run:

🤖  Yield Advisor
🌾  Crop: Maize
📍  Region: Rift Valley
📐  Area (ha): 10
📦  Expected yield per ha (kg/ha): 1500
📊  Maize: 10.0 ha × 1500.0 kg/ha = 15000.0 kg

🧠 Advice for Maize in Rift Valley:
• Yield is moderate. Watch moisture and weed pressure during early growth.
• For 10.0 ha, plan logistics: labor, shelling/drying capacity, and storage.
• Use certified seed and rotate crops to manage pests/diseases.

