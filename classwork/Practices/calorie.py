from dataclasses import dataclass, field
from typing import List, Dict, Optional
from enum import Enum
from collections import defaultdict
import os, csv, json

# ---------- Enums ----------
class MealType(str, Enum):
    BREAKFAST = "Breakfast"
    LUNCH     = "Lunch"
    DINNER    = "Dinner"
    SNACK     = "Snack"

class FoodType(str, Enum):
    PROTEIN   = "Protein"
    CARB      = "Carb"
    FAT       = "Fat"
    VEGETABLE = "Vegetable"
    FRUIT     = "Fruit"
    DAIRY     = "Dairy"
    BEVERAGE  = "Beverage"
    OTHER     = "Other"

# ---------- Data holder (no calorie math here) ----------
@dataclass
class MealEntry:
    day: str
    meal_type: MealType
    food_item: str
    food_type: FoodType
    quantity_g: float
    kcal_per_100g: float

# ---------- Tracker (all behaviors here) ----------
@dataclass
class CalorieTracker:
    participant: str
    calorie_ceiling_per_day: float = 2000.0
    entries: List[MealEntry] = field(default_factory=list)

    # record
    def add_entry(self, day: str, meal_type: MealType, food_item: str,
                  food_type: FoodType, quantity_g: float, kcal_per_100g: float) -> None:
        self.entries.append(MealEntry(day, meal_type, food_item, food_type, quantity_g, kcal_per_100g))

    # ---- calculations ----
    def calories_of(self, e: MealEntry) -> float:
        return (e.quantity_g / 100.0) * e.kcal_per_100g

    def kcal_for_day(self, day: str) -> float:
        return sum(self.calories_of(e) for e in self.entries if e.day == day)

    def kcal_by_mealtype(self, day: str) -> Dict[MealType, float]:
        totals = defaultdict(float)
        for e in self.entries:
            if e.day == day:
                totals[e.meal_type] += self.calories_of(e)
        return dict(totals)

    def kcal_by_foodtype(self, day: Optional[str] = None) -> Dict[FoodType, float]:
        totals = defaultdict(float)
        for e in self.entries:
            if day is None or e.day == day:
                totals[e.food_type] += self.calories_of(e)
        return dict(totals)

    def kcal_for_week(self, days: List[str]) -> float:
        dayset = set(days)
        return sum(self.calories_of(e) for e in self.entries if e.day in dayset)

    # ---- ceiling (informational only) ----
    def remaining_for_day(self, day: str) -> float:
        return self.calorie_ceiling_per_day - self.kcal_for_day(day)

    def over_by(self, day: str) -> float:
        return max(0.0, self.kcal_for_day(day) - self.calorie_ceiling_per_day)

    # ---- views ----
    def show_day_detail(self, day: str) -> str:
        total = self.kcal_for_day(day)
        remain = self.remaining_for_day(day)
        lines = [f"Day: {day} — total {total:.0f} kcal (ceiling {self.calorie_ceiling_per_day:.0f}, remaining {remain:.0f})"]

        # by meal type
        for mt, val in self.kcal_by_mealtype(day).items():
            lines.append(f"  {mt.value}: {val:.0f} kcal")

        # by food type
        ft_totals = self.kcal_by_foodtype(day)
        if ft_totals:
            lines.append("  By food type:")
            for ft, val in ft_totals.items():
                lines.append(f"    {ft.value}: {val:.0f} kcal")

        # individual entries
        for e in self.entries:
            if e.day == day:
                lines.append(
                    f"    • {e.meal_type.value} [{e.food_type.value}]: "
                    f"{e.food_item}, {e.quantity_g:.0f}g @ {e.kcal_per_100g:.0f}/100g = {self.calories_of(e):.0f} kcal"
                )
        if total > self.calorie_ceiling_per_day:
            lines.append(f"  ⚠ Over by {self.over_by(day):.0f} kcal")
        return "\n".join(lines)

    def show_week_summary(self, days: List[str]) -> str:
        total = 0.0
        lines = []
        for d in days:
            day_kcal = self.kcal_for_day(d)
            total += day_kcal
            marker = f" (over by {day_kcal - self.calorie_ceiling_per_day:.0f})" if day_kcal > self.calorie_ceiling_per_day else ""
            lines.append(f"{d}: {day_kcal:.0f} kcal{marker}")
        lines.append(f"Week total ({len(days)} days): {total:.0f} kcal")
        return "\n".join(lines)

    # ---- exports (append or overwrite) ----
    def export_csv(self, filename: str = "calories.csv", append: bool = False) -> None:
        mode = "a" if append else "w"
        write_header = True
        if append and os.path.exists(filename) and os.path.getsize(filename) > 0:
            write_header = False

        with open(filename, mode, newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            if write_header:
                w.writerow(["day","meal_type","food_item","food_type","quantity_g","kcal_per_100g","kcal"])
            for e in self.entries:
                w.writerow([
                    e.day, e.meal_type.value, e.food_item, e.food_type.value,
                    e.quantity_g, e.kcal_per_100g, round(self.calories_of(e), 2)
                ])

    def export_json(self, filename: str = "calories.json", append: bool = False) -> None:
        payload = [
            {
                "day": e.day,
                "meal_type": e.meal_type.value,
                "food_item": e.food_item,
                "food_type": e.food_type.value,
                "quantity_g": e.quantity_g,
                "kcal_per_100g": e.kcal_per_100g,
                "kcal": round(self.calories_of(e), 2),
            }
            for e in self.entries
        ]

        if append and os.path.exists(filename) and os.path.getsize(filename) > 0:
            try:
                with open(filename, "r", encoding="utf-8") as f:
                    existing = json.load(f)
                if isinstance(existing, list):
                    existing.extend(payload)
                else:
                    existing = [existing] + payload
            except json.JSONDecodeError:
                existing = payload
            with open(filename, "w", encoding="utf-8") as f:
                json.dump(existing, f, ensure_ascii=False, indent=2)
        else:
            with open(filename, "w", encoding="utf-8") as f:
                json.dump(payload, f, ensure_ascii=False, indent=2)

# ---------- CLI ----------
def _choose_meal_type():
    options = {
        "1": MealType.BREAKFAST,
        "2": MealType.LUNCH,
        "3": MealType.DINNER,
        "4": MealType.SNACK,
    }
    print("\nMeal type:")
    for k, v in options.items():
        print(f"  {k}. {v.value}")
    while True:
        c = input("Choose 1-4: ").strip()
        if c in options:
            return options[c]
        print("Invalid choice, try again.")

def _choose_food_type():
    options = {
        "1": FoodType.PROTEIN,
        "2": FoodType.CARB,
        "3": FoodType.FAT,
        "4": FoodType.VEGETABLE,
        "5": FoodType.FRUIT,
        "6": FoodType.DAIRY,
        "7": FoodType.BEVERAGE,
        "8": FoodType.OTHER,
    }
    print("\nFood type:")
    for k, v in options.items():
        print(f"  {k}. {v.value}")
    while True:
        c = input("Choose 1-8: ").strip()
        if c in options:
            return options[c]
        print("Invalid choice, try again.")

def _input_float(prompt, min_val=0.0):
    while True:
        try:
            val = float(input(prompt).strip())
            if val < min_val:
                print(f"Value must be ≥ {min_val}.")
                continue
            return val
        except ValueError:
            print("Please enter a number.")

def action_add_entry(ct: CalorieTracker):
    print("\n=== Add Entry ===")
    day = input("Day (e.g., Mon or 2025-09-26): ").strip() or "Today"
    meal_type = _choose_meal_type()
    food_item = input("Food item: ").strip() or "Unknown"
    food_type = _choose_food_type()
    quantity_g = _input_float("Quantity eaten (g): ", min_val=0)
    kcal_per_100g = _input_float("kcal per 100g: ", min_val=0)

    ct.add_entry(day, meal_type, food_item, food_type, quantity_g, kcal_per_100g)
    added_kcal = (quantity_g / 100.0) * kcal_per_100g
    day_total = ct.kcal_for_day(day)
    print(f"\n✅ Added: {food_item} [{food_type.value}] "
          f"{quantity_g:.0f}g @ {kcal_per_100g:.0f}/100g = {added_kcal:.0f} kcal")
    print(f"Day {day} total now: {day_total:.0f} kcal")

def action_show_day(ct: CalorieTracker):
    day = input("\nShow details for day: ").strip()
    if not day:
        print("No day provided.")
        return
    print("\n" + ct.show_day_detail(day))

def action_week_summary(ct: CalorieTracker):
    raw = input("\nDays for week summary (comma-separated, e.g., Mon,Tue,...): ").strip()
    days = [d.strip() for d in raw.split(",") if d.strip()]
    if not days:
        print("No days provided.")
        return
    print("\n" + ct.show_week_summary(days))

def action_export(ct: CalorieTracker):
    print("\nExport options:")
    print("  1. CSV (entries + computed kcal)")
    print("  2. JSON (entries + computed kcal)")
    c = input("Choose 1-2: ").strip()

    def ask_mode():
        m = input("Mode: [O]verwrite / [A]ppend? [O]: ").strip().lower()
        if m in ("a", "append"): return True
        return False  # default overwrite

    if c == "1":
        fname = input("Filename [calories.csv]: ").strip() or "calories.csv"
        append = ask_mode()
        ct.export_csv(fname, append=append)
        print(f"✅ Exported to {fname} ({'append' if append else 'overwrite'})")
    elif c == "2":
        fname = input("Filename [calories.json]: ").strip() or "calories.json"
        append = ask_mode()
        ct.export_json(fname, append=append)
        print(f"✅ Exported to {fname} ({'append' if append else 'overwrite'})")
    else:
        print("Cancelled.")

def main_cli():
    print("=== Calorie Tracker CLI ===")
    name = input("Your name: ").strip() or "User"
    try:
        ceiling = float(input("Daily ceiling (kcal) [2000]: ").strip() or 2000)
    except ValueError:
        ceiling = 2000

    ct = CalorieTracker(participant=name, calorie_ceiling_per_day=ceiling)

    MENU = """
[1] Add entry
[2] Show day detail
[3] Show week summary
[4] Export (CSV/JSON)
[0] Quit
"""
    while True:
        print(MENU)
        choice = input("Select: ").strip()
        if choice == "1":
            action_add_entry(ct)
        elif choice == "2":
            action_show_day(ct)
        elif choice == "3":
            action_week_summary(ct)
        elif choice == "4":
            action_export(ct)
        elif choice == "0":
            print("Bye!")
            break
        else:
            print("Try 0-4.")

# run CLI if executed directly
if __name__ == "__main__":
    main_cli()
