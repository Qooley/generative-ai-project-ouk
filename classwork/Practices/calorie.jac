# =========================================
# Calorie Logger — object-spatial, robust numeric parsing
# =========================================

# ---------- NODES ----------
node Day { has name: str = ""; }

node MealEntry {
    has meal_type: str = "";
    has food_item: str = "";
    has food_type: str = "";
    has quantity_g: float = 0.0;
    has kcal_per_100g: float = 0.0;

    def kcal() -> float;
}

# prompt “tick” node (mirrors GuessGame.turn)
node turn { can check with CalorieLog entry; }

# ---------- WALKER ----------
walker CalorieLog {
    has user: str = "User";
    has ceiling: float = 2000.0;

    can start_log with `root entry;

    def add_entry(day: str, meal_type: str, food_item: str, food_type: str,
                  quantity_g: float, kcal_per_100g: float);

    def show_day(day: str);
}

# ---------- RUN ON LOAD ----------
with entry {
    CalorieLog() spawn root;
}

# ================== impl blocks ==================

impl MealEntry.kcal {
    return (self.quantity_g / 100.0) * self.kcal_per_100g;
}

# ---- Start loop (like GuessGame.start_game) ----
impl CalorieLog.start_log {
    print("👤 User: " + self.user + " (ceiling " + str(int(self.ceiling)) + " kcal)");
    print("📋 Logging started. Type 'done' at any TEXT prompt to exit.");

    # build a chain of prompt nodes; 'done' exits early
    end: here | turn = here;
    for i = 0 to i < 200 by i += 1 {
        end ++> (end := turn());
    }
    visit [-->];
}

# ---- One interactive prompt “tick” ----
impl turn.check {
    # ---- Day ----
    print("Day (e.g., Mon or 2025-09-26) or 'done' to finish:");
    let day = input();
    if day == "done" { disengage; }
    if day == "" { day = "Today"; }

    # ---- Meal type ----
    print("Meal type (Breakfast/Lunch/Dinner/Snack):");
    let mt = input();
    if mt == "done" { disengage; }
    if mt == "" { mt = "Snack"; }

    # ---- Food item ----
    print("Food item:");
    let fi = input();
    if fi == "done" { disengage; }
    if fi == "" { fi = "Unknown"; }

    # ---- Food type ----
    print("Food type (Protein/Carb/Fat/Vegetable/Fruit/Dairy/Beverage/Other):");
    let ft = input();
    if ft == "done" { disengage; }
    if ft == "" { ft = "Other"; }

    # ---- Quantity eaten (g) ----
    let qty = 0.0;
    while 1 == 1 {
        print("Quantity eaten (g): ");
        let s = input();
        if s == "done" { disengage; }

        # parse numeric prefix
        let t = ""; let dots = 0;
        for ch in s {
            if ch >= "0" and ch <= "9" { t = t + ch; }
            elif ch == "." { dots = dots + 1; if dots <= 1 { t = t + "."; } else { break; } }
            else { break; }
        }
        if t == "" { t = "0"; }
        qty = float(t);
        print("  -> parsed qty = " + str(qty));   # DEBUG
        if qty >= 0.0 { break; }
        print("  Please enter a number >= 0");
    }

    # ---- kcal per 100g ----
    let k100 = 0.0;
    while 1 == 1 {
        print("kcal per 100g: ");
        let s2 = input();
        if s2 == "done" { disengage; }

        let t2 = ""; let dots2 = 0;
        for ch in s2 {
            if ch >= "0" and ch <= "9" { t2 = t2 + ch; }
            elif ch == "." { dots2 = dots2 + 1; if dots2 <= 1 { t2 = t2 + "."; } else { break; } }
            else { break; }
        }
        if t2 == "" { t2 = "0"; }
        k100 = float(t2);
        print("  -> parsed kcal/100g = " + str(k100));   # DEBUG
        if k100 >= 0.0 { break; }
        print("  Please enter a number >= 0");
    }

    # confirm we got here
    print("Saving: day=" + day + ", mt=" + mt + ", item=" + fi + ", ft=" + ft
          + ", qty=" + str(qty) + "g, k/100g=" + str(k100));

    # store
    visitor.add_entry(day, mt, fi, ft, qty, k100);

    # optional quick summary
    print("Show summary for this day now? (y/N):");
    let ans = input();
    if ans == "y" or ans == "Y" { visitor.show_day(day); }

    visit [-->];
}

# ---- Persist one entry (scan graph; no `root.out()`) ----
impl CalorieLog.add_entry(day: str, meal_type: str, food_item: str, food_type: str,
                          quantity_g: float, kcal_per_100g: float) {
    # upsert Day by name: scan entire graph for Day node with that name
    let found_days = [];
    for n in g.nodes {
        if typeof(n) == Day {
            if n.name == day { found_days.push(n); }
        }
    }

    # choose first or create
    let d_list = [];
    if found_days.len() > 0 {
        d_list.push(found_days[0]);
    } else {
        let dnew = spawn Day;
        if day == "" { dnew.name = "Today"; } else { dnew.name = day; }
        d_list.push(dnew);
    }
    let d = d_list[0];

    # create the entry
    let e = spawn MealEntry;
    if meal_type == "" { e.meal_type = "Snack"; } else { e.meal_type = meal_type; }
    if food_item == "" { e.food_item = "Unknown"; } else { e.food_item = food_item; }
    if food_type == "" { e.food_type = "Other"; } else { e.food_type = food_type; }
    e.quantity_g = quantity_g;
    e.kcal_per_100g = kcal_per_100g;

    # wire it: Entry -> Day (untyped edges)
    e ++> d;

    # feedback
    let kcal_val = e.kcal();
    print("✅ Added " + e.food_item + " (" + e.food_type + ") "
          + str(int(e.quantity_g)) + "g @ " + str(int(e.kcal_per_100g))
          + "/100g = " + str(int(kcal_val)) + " kcal on " + d.name);
}

# ---- Summarize a day ----
impl CalorieLog.show_day(day: str) {
    let day_name = day;
    if day_name == "" { day_name = "Today"; }

    # collect entries for that day by scanning the graph
    let entries = [];
    for n in g.nodes {
        if typeof(n) != MealEntry { continue; }
        let e = n;
        for m in e.out() {
            if typeof(m) != Day { continue; }
            if m.name == day_name { entries.push(e); }
        }
    }

    # compute totals
    let total = 0.0;
    let by_meal = {};
    let by_food = {};

    for e in entries {
        let k = e.kcal();
        total = total + k;

        if by_meal.has(e.meal_type) { by_meal[e.meal_type] = by_meal[e.meal_type] + k; }
        else { by_meal[e.meal_type] = k; }

        if by_food.has(e.food_type) { by_food[e.food_type] = by_food[e.food_type] + k; }
        else { by_food[e.food_type] = k; }
    }

    print("Day: " + day_name + " - total " + str(int(total)) + " kcal "
          + "(ceiling " + str(int(self.ceiling)) + ", remaining " + str(int(self.ceiling - total)) + ")");

    for mt in by_meal.keys() {
        print("  " + mt + ": " + str(int(by_meal[mt])) + " kcal");
    }

    if by_food.keys().len() > 0 {
        print("  By food type:");
        for ft in by_food.keys() {
            print("    " + ft + ": " + str(int(by_food[ft])) + " kcal");
        }
    }

    for e in entries {
        print("    • " + e.meal_type + " [" + e.food_type + "]: " + e.food_item + ", "
              + str(int(e.quantity_g)) + "g @ " + str(int(e.kcal_per_100g))
              + "/100g = " + str(int(e.kcal())) + " kcal");
    }

    if total > self.ceiling {
        print("  ⚠ Over by " + str(int(total - self.ceiling)) + " kcal");
    }
}
