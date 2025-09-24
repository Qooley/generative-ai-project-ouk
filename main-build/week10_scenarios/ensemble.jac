walker EnsembleBlend { has w2:float=0.5; has wpf:float=0.5;
  can blend with entry {
    for c in here-->`?Cell {
      let p2=float(c.features{"p_stage2"} ?? c.p_now);
      let pp=float(c.features{"p_pf"} ?? c.p_now);
      c.p_now = max(0.0, min(1.0, self.w2*p2 + self.wpf*pp));
    }
    report {"ok":true};
  }
}
