import json
def blend(p_stage2: dict, p_pf: dict, w2=0.5, wpf=0.5):
    cells = set(p_stage2) | set(p_pf)
    return {c: max(0.0, min(1.0, w2*p_stage2.get(c,0.0) + wpf*p_pf.get(c,0.0))) for c in cells}
