# --- Food Group Guess (Jac / OSP) ---

walker food_game {
    has dict data = {};
    has dict groups = {};
    has dict foods = {};
    has dict alias_to_canon = {};
    has str  player_name = "Player";
    has int  score = 0;

    can pretty(key: str) -> str { return key.replace("_", " ").title(); }

    can load_data() {
        groups = {};
        foods = {};
        alias_to_canon = {};
        if (!("groups" in data) or !("foods" in data)) {
            std.out("(Error) Data is missing 'groups' or 'foods'.");
            return;
        }
        for g in data["groups"] {
            if (g has "name") {
                key = g["name"].strip().upper();
                if (key) { groups[key] = pretty(key); }
            }
        }
        for f in data["foods"] {
            if (!(f has "name") or !(f has "group")) { continue; }
            name = f["name"].strip();
            gkey = f["group"].strip().upper();
            aliases = [];
            if (f has "alias") { for a in f["alias"] { aliases.append(a.strip()); } }
            foods[name] = {"name": name, "group": gkey, "alias": aliases};
            alias_to_canon[name.lower()] = name;
            for a in aliases { alias_to_canon[a.lower()] = name; }
        }
    }

    can resolve_food(txt: str) -> dict {
        key = txt.strip().lower();
        if (!key or !(key in alias_to_canon)) {
            hits = [];
            if (key) {
                for alias in alias_to_canon.keys() {
                    if (alias.find(key) != -1) {
                        canon = alias_to_canon[alias];
                        if (canon in foods) {
                            f = foods[canon];
                            seen = false;
                            for h in hits { if (h["name"] == f["name"]) { seen = true; break; } }
                            if (!seen) { hits.append(f); }
                        }
                    }
                }
            }
            if (len(hits) > 0) {
                std.out("\nDid you mean:");
                lim = 0;
                for h in hits {
                    if (lim >= 6) { break; }
                    gkey = h["group"];
                    aka = (len(h["alias"]) > 0) ? ", ".join(h["alias"]) : "—";
                    glabel = (gkey in groups) ? groups[gkey] : gkey;
                    std.out(" - " + h["name"] + "  (group: " + glabel + "; aliases: " + aka + ")");
                    lim += 1;
                }
            }
            return {};
        }
        return foods[alias_to_canon[key]];
    }

    can three_options(correct_key: str) -> list {
        opts = [];
        for k in groups.keys() { if (k != correct_key) { opts.append(k); } }
        distract = [];
        i = 0; while (i < len(opts) && len(distract) < 2) { distract.append(opts[i]); i += 1; }
        options = [correct_key]; for d in distract { options.append(d); }
        if (len(options) == 3) { options = [options[1], options[2], options[0]]; }
        return options;
    }

    can ask_guess(food: dict) -> bool {
        if (!(food has "name") or !(food has "group")) { std.out("(Warning) Unknown food record."); return false; }
        correct_key = food["group"];
        if (!(correct_key in groups)) { std.out("(Warning) Unknown group for " + food["name"] + ": " + correct_key); return false; }
        options = three_options(correct_key);
        std.out("\nWhich group does '" + food["name"] + "' belong to?");
        idx = 1; for k in options { std.out("  " + str(idx) + ". " + groups[k]); idx += 1; }
        choice = std.input("Your choice (1/2/3): ").strip();
        if (!(choice in ["1","2","3"])) { std.out("Invalid input — counted as wrong."); return false; }
        picked_idx = int(choice) - 1; picked_key = options[picked_idx];
        if (picked_key == correct_key) { std.out("✅ Correct!"); score = score + 1; return true; }
        std.out("❌ Wrong. Correct answer: " + groups[correct_key]); return false;
    }

    can run() {
        data = food_data;  # <-- now matches the global name below
        load_data();
        pname = std.input("Enter your name: ").strip(); if (pname) { player_name = pname; }
        std.out("Welcome, " + player_name + "! Type a food name (or 'quit' to stop).");
        while (true) {
            raw = std.input("\nEnter a food: ").strip();
            if (!raw) { std.out("Please type something."); continue; }
            low = raw.lower(); if (low == "quit" or low == "exit") { std.out("Goodbye! Final score: " + str(score)); break; }
            food = resolve_food(raw);
            if (len(food.keys()) == 0) { std.out("I don't recognize that food. Try again (check suggestions above)."); continue; }
            ok = ask_guess(food);
            if (!ok) { std.out("Game over. Your score: " + str(score)); break; }
        }
    }

    body { run(); }
}

# ↓↓↓ Top-level data as a GLOBAL named 'food_data' ↓↓↓
global food_data = {
  "groups": [
    {"name": "CEREALS"},
    {"name": "ROOTS_TUBERS_WHITE"},
    {"name": "VEGETABLES_VITAMIN_A"},
    {"name": "VEGETABLES_DARK_GREEN_LEAFY"},
    {"name": "VEGETABLES_OTHER"},
    {"name": "FRUITS_VITAMIN_A"},
    {"name": "FRUITS_OTHER"},
    {"name": "MEAT_ORGANS"},
    {"name": "MEAT_FLESH"},
    {"name": "EGGS"},
    {"name": "FISH_SEAFOOD"},
    {"name": "LEGUMES"},
    {"name": "NUTS"},
    {"name": "SEEDS"},
    {"name": "MILK_DAIRY"},
    {"name": "OILS"},
    {"name": "FATS"},
    {"name": "SPICES"},
    {"name": "CONDIMENTS"},
    {"name": "BEVERAGES"},
    {"name": "SWEETS"}
  ],
  "foods": [
    {"name":"maize","group":"CEREALS"},
    {"name":"rice","group":"CEREALS"},
    {"name":"sorghum","group":"CEREALS"},
    {"name":"millet","group":"CEREALS"},
    {"name":"pearl millet","group":"CEREALS"},
    {"name":"w wheat","group":"CEREALS"},
    {"name":"oats","group":"CEREALS"},
    {"name":"ugali","group":"CEREALS"},
    {"name":"porridge","group":"CEREALS"},
    {"name":"chapati","group":"CEREALS"},
    {"name":"mandazi","group":"CEREALS"},
    {"name":"bread","group":"CEREALS"},
    {"name":"pasta","group":"CEREALS"},
    {"name":"noodles","group":"CEREALS"},
    {"name":"breakfast cereal","group":"CEREALS"},

    {"name":"white potatoes","group":"ROOTS_TUBERS_WHITE","alias":["irish potatoes"]},
    {"name":"white yam","group":"ROOTS_TUBERS_WHITE"},
    {"name":"white cassava","group":"ROOTS_TUBERS_WHITE","alias":["cassava"]},
    {"name":"white sweet potato","group":"ROOTS_TUBERS_WHITE"},
    {"name":"yams","group":"ROOTS_TUBERS_WHITE"},
    {"name":"arrowroot","group":"ROOTS_TUBERS_WHITE","alias":["nduma"]},
    {"name":"green banana","group":"ROOTS_TUBERS_WHITE"},
    {"name":"plantain","group":"ROOTS_TUBERS_WHITE"},

    {"name":"pumpkin","group":"VEGETABLES_VITAMIN_A"},
    {"name":"carrot","group":"VEGETABLES_VITAMIN_A"},
    {"name":"squash","group":"VEGETABLES_VITAMIN_A"},
    {"name":"orange sweet potato","group":"VEGETABLES_VITAMIN_A"},
    {"name":"red sweet pepper","group":"VEGETABLES_VITAMIN_A","alias":["red capsicum"]},

    {"name":"spinach","group":"VEGETABLES_DARK_GREEN_LEAFY"},
    {"name":"kale","group":"VEGETABLES_DARK_GREEN_LEAFY","alias":["sukuma wiki"]},
    {"name":"cowpeas leaves","group":"VEGETABLES_DARK_GREEN_LEAFY","alias":["kunde"]},
    {"name":"bean leaves","group":"VEGETABLES_DARK_GREEN_LEAFY"},
    {"name":"black nightshade","group":"VEGETABLES_DARK_GREEN_LEAFY","alias":["managu"]},
    {"name":"amaranthus","group":"VEGETABLES_DARK_GREEN_LEAFY","alias":["terere"]},
    {"name":"stinging nettle","group":"VEGETABLES_DARK_GREEN_LEAFY","alias":["thabai","oilo"]},
    {"name":"sweet potato leaves","group":"VEGETABLES_DARK_GREEN_LEAFY","alias":["matembele"]},
    {"name":"cassava leaves","group":"VEGETABLES_DARK_GREEN_LEAFY","alias":["kisamvu"]},
    {"name":"spider plant","group":"VEGETABLES_DARK_GREEN_LEAFY","alias":["saget","dek","akeyo","sagaa"]},
    {"name":"pumpkin leaves","group":"VEGETABLES_DARK_GREEN_LEAFY","alias":["susa"]},
    {"name":"arrowroot leaves","group":"VEGETABLES_DARK_GREEN_LEAFY","alias":["matekyo"]},

    {"name":"green pepper","group":"VEGETABLES_OTHER"},
    {"name":"onion","group":"VEGETABLES_OTHER"},
    {"name":"cauliflower","group":"VEGETABLES_OTHER"},
    {"name":"cabbage","group":"VEGETABLES_OTHER"},
    {"name":"cucumber","group":"VEGETABLES_OTHER"},
    {"name":"eggplant","group":"VEGETABLES_OTHER","alias":["brinjal","aubergine"]},
    {"name":"courgette","group":"VEGETABLES_OTHER","alias":["zucchini"]},
    {"name":"french beans","group":"VEGETABLES_OTHER"},
    {"name":"okra","group":"VEGETABLES_OTHER"},
    {"name":"leek","group":"VEGETABLES_OTHER"},
    {"name":"broccoli","group":"VEGETABLES_OTHER"},
    {"name":"celery","group":"VEGETABLES_OTHER"},
    {"name":"tomato","group":"VEGETABLES_OTHER"},

    {"name":"ripe mango","group":"FRUITS_VITAMIN_A","alias":["mango"]},
    {"name":"ripe papaya","group":"FRUITS_VITAMIN_A","alias":["pawpaw"]},
    {"name":"cantaloupe","group":"FRUITS_VITAMIN_A"},
    {"name":"apricot","group":"FRUITS_VITAMIN_A"},
    {"name":"dried peach","group":"FRUITS_VITAMIN_A"},

    {"name":"guava","group":"FRUITS_OTHER","alias":["mapera"]},
    {"name":"avocado","group":"FRUITS_OTHER"},
    {"name":"pineapple","group":"FRUITS_OTHER"},
    {"name":"green plum","group":"FRUITS_OTHER"},
    {"name":"grapes","group":"FRUITS_OTHER"},
    {"name":"apple","group":"FRUITS_OTHER"},
    {"name":"gooseberries","group":"FRUITS_OTHER","alias":["nathi","cape gooseberry"]},
    {"name":"oranges","group":"FRUITS_OTHER"},
    {"name":"lemons","group":"FRUITS_OTHER"},
    {"name":"limes","group":"FRUITS_OTHER"},
    {"name":"tamarind","group":"FRUITS_OTHER"},
    {"name":"loquats","group":"FRUITS_OTHER"},
    {"name":"zambarao","group":"FRUITS_OTHER","alias":["jamun","java plum"]},
    {"name":"ripe bananas","group":"FRUITS_OTHER","alias":["bananas"]},
    {"name":"custard apples","group":"FRUITS_OTHER"},
    {"name":"peaches","group":"FRUITS_OTHER"},
    {"name":"thorn melon","group":"FRUITS_OTHER","alias":["kiwano"]},
    {"name":"melons","group":"FRUITS_OTHER"},
    {"name":"pomegranates","group":"FRUITS_OTHER","alias":["kungu manga"]},
    {"name":"wild fruits","group":"FRUITS_OTHER"},

    {"name":"liver","group":"MEAT_ORGANS"},
    {"name":"kidney","group":"MEAT_ORGANS"},
    {"name":"heart","group":"MEAT_ORGANS"},
    {"name":"blood-based foods","group":"MEAT_ORGANS"},

    {"name":"edible insects","group":"MEAT_FLESH"},
    {"name":"goat meat","group":"MEAT_FLESH"},
    {"name":"game meat","group":"MEAT_FLESH"},
    {"name":"pork","group":"MEAT_FLESH"},
    {"name":"beef","group":"MEAT_FLESH"},
    {"name":"mutton","group":"MEAT_FLESH"},
    {"name":"rabbit","group":"MEAT_FLESH"},
    {"name":"donkey","group":"MEAT_FLESH"},
    {"name":"chicken","group":"MEAT_FLESH"},
    {"name":"guinea fowl","group":"MEAT_FLESH"},
    {"name":"turkey","group":"MEAT_FLESH"},
    {"name":"geese","group":"MEAT_FLESH"},
    {"name":"ducks","group":"MEAT_FLESH"},
    {"name":"quail","group":"MEAT_FLESH"},
    {"name":"wild birds","group":"MEAT_FLESH"},
    {"name":"doves","group":"MEAT_FLESH"},

    {"name":"eggs","group":"EGGS","alias":["chicken eggs","duck eggs","quail eggs","ostrich eggs","ant eggs"]},

    {"name":"fish","group":"FISH_SEAFOOD"},
    {"name":"shellfish","group":"FISH_SEAFOOD"},
    {"name":"omena","group":"FISH_SEAFOOD","alias":["silver cyprinid"]},

    {"name":"beans","group":"LEGUMES"},
    {"name":"peas","group":"LEGUMES"},
    {"name":"cowpeas","group":"LEGUMES"},
    {"name":"pigeon peas","group":"LEGUMES","alias":["mbaazi"]},
    {"name":"soybeans","group":"LEGUMES"},
    {"name":"dolicos beans","group":"LEGUMES","alias":["njahi"]},
    {"name":"green grams","group":"LEGUMES","alias":["mung beans"]},
    {"name":"lentils","group":"LEGUMES"},

    {"name":"groundnuts","group":"NUTS","alias":["peanuts"]},
    {"name":"macadamia","group":"NUTS"},
    {"name":"cashew nuts","group":"NUTS"},

    {"name":"sesame","group":"SEEDS","alias":["simsim"]},
    {"name":"sunflower seeds","group":"SEEDS"},
    {"name":"pumpkin seeds","group":"SEEDS"},
    {"name":"amaranth","group":"SEEDS"},

    {"name":"milk","group":"MILK_DAIRY","alias":["cow milk","goat milk","camel milk","sheep milk"]},
    {"name":"fermented milk","group":"MILK_DAIRY"},
    {"name":"mursik","group":"MILK_DAIRY"},
    {"name":"amarurano","group":"MILK_DAIRY"},
    {"name":"yoghurt","group":"MILK_DAIRY"},
    {"name":"cheese","group":"MILK_DAIRY"},

    {"name":"vegetable oil","group":"OILS"},
    {"name":"cooking oil","group":"OILS"},
    {"name":"fish oil","group":"OILS","alias":["cod liver oil"]},
    {"name":"palm oil","group":"OILS"},

    {"name":"ghee","group":"FATS"},
    {"name":"butter","group":"FATS"},
    {"name":"margarine","group":"FATS"},
    {"name":"cooking fat","group":"FATS"},

    {"name":"black pepper","group":"SPICES"},
    {"name":"salt","group":"SPICES"},
    {"name":"soy sauce","group":"CONDIMENTS"},
    {"name":"hot sauce","group":"CONDIMENTS"},
    {"name":"coffee","group":"BEVERAGES"},
    {"name":"tea","group":"BEVERAGES"},
    {"name":"alcoholic beverages","group":"BEVERAGES"},

    {"name":"table sugar","group":"SWEETS","alias":["sugar"]},
    {"name":"jaggery","group":"SWEETS"},
    {"name":"sugar cane","group":"SWEETS"},
    {"name":"honey","group":"SWEETS"},
    {"name":"sugary cold drinks","group":"SWEETS"},
    {"name":"flavoured drinks","group":"SWEETS"},
    {"name":"concentrates","group":"SWEETS"},
    {"name":"candies","group":"SWEETS"},
    {"name":"cakes","group":"SWEETS"},
    {"name":"chocolate","group":"SWEETS"}
  ]
};

# entry point
walk ::food_game;
