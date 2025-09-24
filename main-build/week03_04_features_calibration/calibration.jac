walker CalibratePlatt { has a:float=1.0; has b:float=0.0;
  def sigmoid(x: float) -> float { return 1.0/(1.0+exp(-x)); }
  can apply with entry {
    for c in here-->`?Cell {
      let p = max(1e-6, min(1-1e-6, c.p_now));
      let logit = log(p/(1-p));
      c.p_now = self.sigmoid(self.a*logit + self.b);
    }
    report {"ok":true};
  }
}
