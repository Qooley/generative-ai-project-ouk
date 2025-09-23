node Cell { has id:str; has x:float; has y:float; has features:dict; has p_now:float=0.0; has p_next:float=0.0; }
node Area { has name:str; has dt_minutes:int=5; } edge Adj { }

walker GridBuild {
  can build with entry {
    # ctx: {"cells":[{"id":"A1","x":0,"y":0,"features":{...}}, ...]}
    let cells = ctx{"cells"} ?? [];
    for c in cells { spawn here ++> Cell(id=c{"id"}, x=c{"x"}, y=c{"y"}, features=(c{"features"} ?? {})); }
    report {"ok":true, "n":len(cells)};
  }
}

walker OccupancyBaseline {
  has beta: dict = {"bias": -1.0, "flower_ndvi": 2.0, "shade_index": 0.3, "wind_u": -0.1, "wind_v": -0.1, "hour_sin": 0.2, "hour_cos": 0.1};
  def sigmoid(x: float) -> float { return 1.0/(1.0+exp(-x)); }
  can predict with entry {
    for c in here-->`?Cell {
      let z = self.beta{"bias"} ?? 0.0;
      for k in keys(self.beta) { if k!="bias" and (k in c.features) { z += (self.beta{k} ?? 0.0) * float(c.features{k}); } }
      c.p_now = self.sigmoid(z);
    }
    report {"updated": len(here-->`?Cell)};
  }
}
