def diffuse(p_map, adj, gamma=0.2):
    out = {}
    for cid, p in p_map.items():
        nbrs = adj.get(cid, [])
        if nbrs:
            m = sum(p_map[n] for n in nbrs)/len(nbrs)
        else:
            m = p
        out[cid] = (1-gamma)*p + gamma*m
    return out
