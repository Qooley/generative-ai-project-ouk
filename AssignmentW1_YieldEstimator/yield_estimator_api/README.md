
---

## 2️⃣ `yield_estimator_api/README.md`
```markdown
# Yield Estimator API (Step 5)

This module implements a **Crop Yield Estimator** that works in both:
1. **CLI mode** — interactive command-line prompts for single farmers.
2. **API mode** — callable HTTP endpoints for batch yield estimation.

---

## Features
- 🌾 Input: Crop name, acreage, expected yield/ha.  
- 📊 Output: Total yield (kg) per crop.  
- 🔗 Scale-agnostic: Same code runs locally or as an API.  

---
Sample run:
👨‍🌾  Crop Yield Estimator (CLI)
🌾  Crop name: Maize
📐  Acreage planted (ha): 5
📦  Expected yield per hectare (kg/ha): 1800
✅  Crop: Maize ⇒ Total: 9000 kg

API Mode

Start the API:

jac serve yield_estimator_api/yield_api.jac

Example request:

POST /BatchSummaryAPI
{
  "crops": ["Maize", "Beans"],
  "acres_list": [5, 2],
  "yields_list": [1800, 1500]
}

Example response:

{
  "items": [
    {"crop": "Maize", "acres": 5, "yield_per_ha": 1800, "total_kg": 9000},
    {"crop": "Beans", "acres": 2, "yield_per_ha": 1500, "total_kg": 3000}
  ],
  "grand_total_kg": 12000
}

