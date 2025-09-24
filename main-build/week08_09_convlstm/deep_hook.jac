import json from "std"
walker LoadDeepMap {
  can from_json with entry {
    let path = ctx{"path"} ?? "deep_output.json";
    let obj = json.loads(file.read(path));
    let u=0;
    for row in obj{"cells"} {
      let c=(here-->`?Cell::id==row{"cell_id"})[0];
      if c { c.features{"p_deep"} = float(row{"p"}); u+=1; }
    }
    report {"updated":u};
  }
}
