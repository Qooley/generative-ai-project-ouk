import json from "std"
walker ExportJSON { has top_k:int=5;
  can dump with entry {
    let path = ctx{"path"} ?? "week11_dashboard_api/map_export.json";
    let cells = []; for c in here-->`?Cell { cells.append({"cell_id":c.id,"x":c.x,"y":c.y,"p":round(c.p_now,4)}); }
    cells.sort(key=lambda a: -a{"p"});
    file.write(path, json.dumps({"cells": cells, "top_k": cells[:self.top_k]}));
    report {"wrote": path};
  }
}
