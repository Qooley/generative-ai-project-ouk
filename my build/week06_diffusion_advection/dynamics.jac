edge Adj { }
walker DiffuseAdvect { has gamma:float=0.2; has alpha:float=0.1; has wind_u:float=0.0; has wind_v:float=0.0;
  def nmean(c: node(`Cell)) -> float { let nbr=c<->`?Cell; if len(nbr)==0 { return c.p_now; } let s=0.0; for n in nbr { s+=n.p_now; } return s/len(nbr); }
  can step with entry {
    for c in here-->`?Cell { let m=self.nmean(c); c.p_next=(1.0-self.gamma)*c.p_now + self.gamma*m; }
    for c in here-->`?Cell {
      let best=null; let bestdot=-1e9;
      for n in c<->`?Cell { let vx=n.x-c.x; let vy=n.y-c.y; let dot=vx*self.wind_u + vy*self.wind_v; if dot>bestdot { best=n; bestdot=dot; } }
      if best { let t=self.alpha*c.p_next; c.p_next-=t; best.p_next+=t; }
    }
    for c in here-->`?Cell { c.p_now=max(0.0,min(1.0,c.p_next)); c.p_next=0.0; }
    report {"ok":true};
  }
}
