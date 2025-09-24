node Particle { has cell_id:str; has w:float=1.0; } edge Adj { }
walker PF { has N:int=2000; has obs_scale:float=2.0; has parts:list=[];
  def r(lst:list)->any { return lst[int(rand()*len(lst))]; }
  can init with entry {
    self.parts=[]; let cells = here-->`?Cell;
    for i in range(self.N) { let c=self.r(cells); self.parts.append(spawn here ++> Particle(cell_id=c.id, w=1.0/self.N)); }
    report {"N":self.N};
  }
  can step with entry {
    for p in self.parts {
      let c=(here-->`?Cell::id==p.cell_id)[0]; let nbr=c<->`?Cell;
      if len(nbr)>0 and rand()<0.7 { let n=self.r(nbr); p.cell_id=n.id; }
    }
    let s=0.0; for p in self.parts { let c=(here-->`?Cell::id==p.cell_id)[0]; p.w=max(1e-4, pow(c.p_now, self.obs_scale)); s+=p.w; }
    for p in self.parts { p.w/=s; }
    let newp=[]; let u0=rand()/self.N; let acc=0.0; let csum=[];
    for p in self.parts { acc+=p.w; csum.append(acc); }
    for j in range(self.N) { let u=u0+j*(1.0/self.N); let k=0; while (k<len(csum) and u>csum[k]) { k+=1; } let ch=self.parts[min(k,len(self.parts)-1)]; newp.append(spawn here ++> Particle(cell_id=ch.cell_id, w=1.0/self.N)); }
    self.parts=newp;
    let counts={}; for p in self.parts { counts{p.cell_id}=(counts{p.cell_id} ?? 0.0)+p.w; }
    for c in here-->`?Cell { c.p_now = counts{c.id} ?? 0.0; }
    report {"ok":true};
  }
}
