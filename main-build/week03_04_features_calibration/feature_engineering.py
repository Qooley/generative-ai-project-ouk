import pandas as pd, numpy as np

def add_wind_mag(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df["wind_mag"] = np.sqrt(df["wind_u"]**2 + df["wind_v"]**2)
    return df

def encode_hour(df: pd.DataFrame) -> pd.DataFrame:
    return df  # already has hour_sin/cos in schema
