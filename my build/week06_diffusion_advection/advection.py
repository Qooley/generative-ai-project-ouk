def advect(p_map, coords, adj, alpha=0.1, wind_u=0.0, wind_v=0.0):
    out = dict(p_map)
    for cid, p in p_map.items():
        nbrs = adj.get(cid, [])
        if not nbrs: continue
        x,y = coords[cid]
        best=None; bestdot=-1e9
        for n in nbrs:
            xn,yn = coords[n]
            dot = (xn-x)*wind_u + (yn-y)*wind_v
            if dot>bestdot: best=n; bestdot=dot
        if best is not None:
            t = alpha * out[cid]
            out[cid] -= t; out[best] += t
    return out
