node Crops {
  has Name: str;
  has Volume: int;
}

node Market {
  has Price: int;
}

edge sold_to {}

walker Demo {
  can run with `root entry {
    maize = Crops(Name="Maize", Volume=100);
    town  = Market(Price=50);

    maize +>:sold_to:+> town;

    # NEW traversal: collect markets via the sold_to edge
    markets = [maize->:sold_to:->(`?Market)];

    for m in markets {
      revenue = maize.Volume * m.Price;
      print(maize.Name, "Revenue:", revenue);
    }
  }
}

with entry { root spawn Demo(); }