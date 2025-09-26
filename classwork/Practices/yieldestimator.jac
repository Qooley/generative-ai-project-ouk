# ==============================
# Simple Crop Yield Estimator
# ==============================

node Estimate { can check with YieldLog entry; }

walker YieldLog {
    has user: str = "Farmer";

    can start with `root entry;
    def add_crop(crop: str, acres: float, yield_per_acre: float);
}

with entry {
    YieldLog() spawn root;
}

# ---- walker start ----
impl YieldLog.start {
    print("Crop Yield Estimator for " + self.user);
    print("Type 'done' anytime to exit.");

    end: here | Estimate = here;
    for i = 0 to i < 50 by i += 1 {
        end ++> (end := Estimate());
    }
    visit [-->];
}

# ---- interactive tick ----
impl Estimate.check {
    print("Crop name (e.g., Maize, Beans) or 'done' to finish:");
    let crop = input();
    if crop == "done" { disengage; }
    if crop == "" { crop = "Unknown"; }

    print("Acreage planted (ha):");
    let a_str = input();
    if a_str == "done" { disengage; }
    if a_str == "" { a_str = "0"; }
    let acres = float(a_str);

    print("Expected yield per acre (kg/acre):");
    let y_str = input();
    if y_str == "done" { disengage; }
    if y_str == "" { y_str = "0"; }
    let yield_per = float(y_str);

    visitor.add_crop(crop, acres, yield_per);
    visit [-->];
}

# ---- store + calculate ----
impl YieldLog.add_crop(crop: str, acres: float, yield_per_acre: float) {
    let total = acres * yield_per_acre;
    print("Crop: " + crop + " | Area: " + str(acres) + " Acre | Yield/acre: "
          + str(yield_per_acre) + " → Total = " + str(total) + " kg");
}
