from sklearn.linear_model import LogisticRegression, PoissonRegressor
import pandas as pd, numpy as np
from joblib import dump

FEATURES = ["flower_ndvi","dist_hedge","shade_index","wind_u","wind_v",
            "temp_c","sun_elev","hour_sin","hour_cos","doy_sin","doy_cos"]

def fit_logistic(csv_path, out_model="occupancy.joblib"):
    df = pd.read_csv(csv_path)
    X = df[FEATURES].astype(float).values
    y = df["occ"].astype(int).values
    clf = LogisticRegression(max_iter=1000, class_weight="balanced").fit(X,y)
    dump({"model":clf,"mode":"logistic","features":FEATURES}, out_model)
    return out_model

def fit_poisson(csv_path, out_model="intensity.joblib"):
    df = pd.read_csv(csv_path)
    X = df[FEATURES].astype(float).values
    y = df["count"].astype(float).values
    pr = PoissonRegressor(max_iter=1000).fit(X,y)
    dump({"model":pr,"mode":"poisson","features":FEATURES}, out_model)
    return out_model
