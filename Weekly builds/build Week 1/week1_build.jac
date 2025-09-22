node Crops {
  has Name: str;
  has Volume: int;
}

node Market {
  has Price: int;
}

walker Demo {
  can run with `root entry {
    maize = Crops(Name="Maize", Volume=100);

    town1 = Market(Price=50);
    town2 = Market(Price=69);
    town3 = Market(Price=75);

    # create generic edge
    maize ++> town1;
    maize ++> town2;
    maize ++> town3;

    # collect all Market nodes reachable from maize
    markets = [maize-->(`?Market)];

    # Revenue Accumulation
    total_revenue = 0;
    for mk in markets {
      revenue = maize.Volume * mk.Price;
      total_revenue += revenue;
      
    }

    print("FINAL total:", total_revenue);
  }
}

with entry { root spawn Demo(); }
