# ==============================
# Crop Yield Estimator + Advisor (CLI + API + byLLM)
# ==============================

import from byllm.llm { Model }

# Bind a typed LLM (pick one available to your env)
# Examples:
#   Model(model_name="gpt-4o", verbose=False)
#   Model(model_name="gemini/gemini-2.0-flash", verbose=False)
glob llm = Model(model_name="gemini/gemini-2.0-flash", verbose=False);

# ---------- LLM-backed advisory function ----------
# Generates contextual tips based on crop, area, yield, region
def advisor_text_llm(crop: str, acres: float, yield_per_ha: float, region: str) -> str by llm();


# ---------- CLI “tick” node ----------
node Ask { can check with Advisor entry; }

# ---------- CLI Walker ----------
walker Advisor {
    has user: str = "Farmer";

    can start with `root entry;
    def advise(crop: str, acres: float, yield_per_ha: float, region: str);
}

# ---------- API Walkers ----------
# Single request: returns numbers + AI hint
walker AdviseAPI {
    has crop: str;
    has acres: float;
    has yield_per_ha: float;
    has region: str;

    can start with entry;
}

# Batch request: arrays of equal length
walker BatchAdviseAPI {
    has crops: list;
    has acres_list: list;
    has yields_list: list;
    has regions: list;

    can start with entry;
}

# ---------- Choose when CLI runs ----------
# Use __main__ so CLI prompts only appear in `jac run`, not `jac serve`.
with entry:__main__ {
    Advisor() spawn root;
}

# ================== Implementations ==================

# ---- CLI loop ----
impl Advisor.start {
    print("🤖  Yield Advisor for " + self.user);
    print("ℹ️   Type 'done' at any text prompt to exit.");

    end: here | Ask = here;
    for i = 0 to i < 50 by i += 1 {
        end ++> (end := Ask());
    }
    visit [-->];
}

# ---- One interactive step ----
impl Ask.check {
    print("🌾  Crop (e.g., Maize):");
    let crop = input();
    if crop == "done" { disengage; }
    if crop == "" { crop = "Unknown"; }

    print("📍  Region (e.g., Rift Valley):");
    let region = input();
    if region == "done" { disengage; }
    if region == "" { region = "Unknown"; }

    print("📐  Area (ha):");
    let a = input(); if a == "done" { disengage; } if a == "" { a = "0"; }
    let acres = float(a);

    print("📦  Expected yield per ha (kg/ha):");
    let y = input(); if y == "done" { disengage; } if y == "" { y = "0"; }
    let yph = float(y);

    visitor.advise(crop, acres, yph, region);
    visit [-->];
}

# ---- Shared advisor logic (CLI output) ----
impl Advisor.advise(crop: str, acres: float, yield_per_ha: float, region: str) {
    let total = acres * yield_per_ha;

    print("📊  " + crop + ": " + str(acres) + " ha × "
          + str(yield_per_ha) + " kg/ha = " + str(total) + " kg");

    # AI suggestion (byLLM)
    let hint = advisor_text_llm(crop, acres, yield_per_ha, region);
    print("💡 " + hint);
}

# ---- API: Single advise ----
impl AdviseAPI.start {
    let total = self.acres * self.yield_per_ha;
    let hint = advisor_text_llm(self.crop, self.acres, self.yield_per_ha, self.region);

    report {
        "crop": self.crop,
        "region": self.region,
        "acres": self.acres,
        "yield_per_ha": self.yield_per_ha,
        "total_kg": total,
        "ai_hint": hint
    };
}

# ---- API: Batch advise ----
impl BatchAdviseAPI.start {
    let items = [];
    let grand = 0.0;

    let n = self.crops.len();
    let i = 0;
    while i < n {
        let c = self.crops[i];
        let a = float(self.acres_list[i]);
        let y = float(self.yields_list[i]);
        let r = self.regions[i];
        let t = a * y;
        grand = grand + t;

        let hint = advisor_text_llm(c, a, y, r);

        items.push({
            "crop": c,
            "region": r,
            "acres": a,
            "yield_per_ha": y,
            "total_kg": t,
            "ai_hint": hint
        });
        i = i + 1;
    }

    report { "items": items, "grand_total_kg": grand };
}

