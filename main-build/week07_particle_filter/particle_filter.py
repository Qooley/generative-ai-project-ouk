import numpy as np
from collections import Counter

def particle_filter(p_init, adj, N=2000, steps=3, move_prob=0.7, obs_scale=2.0):
    cells = list(p_init.keys())
    probs = np.array([p_init[c] for c in cells], dtype=float)
    probs = probs / (probs.sum() if probs.sum()>0 else 1.0)
    parts = list(np.random.choice(cells, size=N, p=probs))
    for _ in range(steps):
        for i in range(N):
            cid = parts[i]
            nbrs = adj.get(cid, [])
            if nbrs and np.random.rand() < move_prob:
                parts[i] = np.random.choice(nbrs)
        w = np.array([max(1e-6, p_init[c])**obs_scale for c in parts]); w/=w.sum()
        parts = list(np.random.choice(parts, size=N, p=w))
    counts = Counter(parts)
    return {c: counts.get(c,0)/N for c in cells}
