def nl_summary(top_cells):
    s = ", ".join([f"{cid} (p≈{p:.2f})" for cid,p in top_cells])
    return f"Next bin: {s}."
