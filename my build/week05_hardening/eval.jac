walker Evaluate { has thr:float=0.5;
  can run with entry {
    # ctx{"labels"}: [{"cell_id":"A1","occ":1}, ...]
    let labs = ctx{"labels"} ?? []; let tp=0; let fp=0; let tn=0; let fn=0;
    for l in labs {
      let c = (here-->`?Cell::id==l{"cell_id"})[0];
      if c {
        let y = int(l{"occ"} ?? 0); let yhat = int(c.p_now>=self.thr);
        if y==1 and yhat==1 { tp+=1; } if y==0 and yhat==1 { fp+=1; }
        if y==0 and yhat==0 { tn+=1; } if y==1 and yhat==0 { fn+=1; }
      }
    }
    report {"tp":tp,"fp":fp,"tn":tn,"fn":fn};
  }
}

walker NLSummary {
  can speak with entry {
    let cells = []; for c in here-->`?Cell { cells.append({"id":c.id,"p":c.p_now}); }
    cells.sort(key=lambda a: -a{"p"});
    let t = cells[:3];
    report {"text": f"Next bin: {t[0]{'id'}} (p≈{round(t[0]{'p'},2)}), {t[1]{'id'}} (p≈{round(t[1]{'p'},2)}), {t[2]{'id'}} (p≈{round(t[2]{'p'},2)})."};
  }
}
