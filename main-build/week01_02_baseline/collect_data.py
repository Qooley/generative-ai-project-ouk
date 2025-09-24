"""
Camera/mic → 5–10 min CSV aggregations.
- Sample RTSP frames at 1–2 fps
- Detect small moving objects (bees) -> counts
- Map pixels to grid cells via homography
- Aggregate per time bin

This is a stub with function signatures.
"""
from typing import Iterable, Dict, Any
import csv, time

def init_camera(rtsp_url: str): ...
def sample_frames(rtsp_url: str, fps: float=1.0) -> Iterable[bytes]: ...
def detect_bees(frame_bytes: bytes) -> list[dict]: ...
def map_to_cell(detections: list[dict]) -> Dict[str, int]: ...

def write_bin_row(path: str, row: Dict[str, Any]):
    header = ["time","cell_id","x","y","count","occ","flower_ndvi","dist_hedge",
              "shade_index","wind_u","wind_v","temp_c","sun_elev",
              "hour_sin","hour_cos","doy_sin","doy_cos"]
    exists = os.path.exists(path)
    with open(path,"a",newline="") as f:
        w = csv.DictWriter(f, fieldnames=header)
        if not exists: w.writeheader()
        w.writerow(row)
