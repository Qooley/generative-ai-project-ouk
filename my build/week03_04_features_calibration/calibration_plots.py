import numpy as np, pandas as pd
import matplotlib.pyplot as plt
from sklearn.isotonic import IsotonicRegression

def reliability_curve(y_true, y_prob, bins=10):
    df = pd.DataFrame({"y":y_true, "p":y_prob}).sort_values("p")
    df["bin"] = pd.qcut(df["p"], q=bins, duplicates="drop")
    stats = df.groupby("bin").agg(p_mean=("p","mean"), y_rate=("y","mean")).reset_index(drop=True)
    return stats
