# ===================================
# Crop Yield Estimator — CLI + API
# ===================================

# ---------- CLI bits ----------
node Estimate { can check with YieldLog entry; }

walker YieldLog {
    has user: str = "Farmer";
    can start with `root entry;
    def add_crop(crop: str, acres: float, yield_per_acre: float);
}

# ---------- API bits ----------
walker AddCropAPI {
    has crop: str;
    has acres: float;
    has yield_per_acre: float;
    can start with entry;         # callable without interactivity
}

walker BatchSummaryAPI {
    # simple in-memory aggregation approach:
    # pass arrays of same length; returns per-crop and grand totals
    has crops: list;
    has acres_list: list;
    has yields_list: list;
    can start with entry;
}

with entry {
    # optional CLI flow; comment out if you only want API mode
    YieldLog() spawn root;
}

# ---------- CLI walker impls ----------
impl YieldLog.start {
    print("👨‍🌾  Crop Yield Estimator (CLI)");
    print("ℹ️   'done' to exit.");

    end: here | Estimate = here;
    for i = 0 to i < 50 by i += 1 { end ++> (end := Estimate()); }
    visit [-->];
}

impl Estimate.check {
    print("🌾  Crop name or 'done':");
    let crop = input();
    if crop == "done" { disengage; }
    if crop == "" { crop = "Unknown"; }

    print("📐  Acreage planted (ha):");
    let a = input(); if a == "done" { disengage; } if a == "" { a = "0"; }
    let acres = float(a);

    print("📦  Expected yield per hectare (kg/ha):");
    let y = input(); if y == "done" { disengage; } if y == "" { y = "0"; }
    let ypa = float(y);

    visitor.add_crop(crop, acres, ypa);
    visit [-->];
}

impl YieldLog.add_crop(crop: str, acres: float, yield_per_acre: float) {
    let total = acres * yield_per_acre;
    print("✅  Crop: " + crop
          + "   •  📐 " + str(acres) + " ha"
          + "   •  📦 " + str(yield_per_acre) + " kg/ha"
          + "   ⇒  📊 Total: " + str(total) + " kg");
}

# ---------- API walker impls ----------
impl AddCropAPI.start {
    let total = self.acres * self.yield_per_acre;
    report {
        "crop": self.crop,
        "acres": self.acres,
        "yield_per_ha": self.yield_per_acre,
        "total_kg": total
    };
}

impl BatchSummaryAPI.start {
    let items = [];
    let grand = 0.0;

    let n = self.crops.len();
    let i = 0;
    while i < n {
        let c = self.crops[i];
        let a = float(self.acres_list[i]);
        let y = float(self.yields_list[i]);
        let t = a * y;
        grand = grand + t;
        items.push({
            "crop": c,
            "acres": a,
            "yield_per_ha": y,
            "total_kg": t
        });
        i = i + 1;
    }

    report {
        "items": items,
        "grand_total_kg": grand
    };
}
