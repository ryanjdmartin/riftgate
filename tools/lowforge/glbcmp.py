"""Compare two glTF binaries by node tree and world-space geometry, so a rebuild that only
adds joints can be shown to leave the model itself untouched (the joint pass, 3 October):

    python tools/lowforge/glbcmp.py art/models/badger.glb /tmp/badger.glb [-v]

Prints the node counts and the names only one file has, whether the world-space geometry is
identical (every mesh's vertices, rounded, as a multiset of hashes, so a reparented part
still matches), which meshes were reparented, and the second file's joint_* and hp_* nodes
with their parents. Needs numpy (tools/spriter/.venv has it)."""
import json, struct, sys, hashlib
import numpy as np

def load(path):
    d = open(path, "rb").read()
    assert d[:4] == b"glTF"
    off = 12; js = None; bins = None
    while off < len(d):
        ln, ty = struct.unpack_from("<II", d, off); off += 8
        chunk = d[off:off+ln]; off += ln
        if ty == 0x4E4F534A: js = json.loads(chunk)
        elif ty == 0x004E4942: bins = chunk
    return js, bins

CT = {5120: "b", 5121: "B", 5122: "h", 5123: "H", 5125: "I", 5126: "f"}
NC = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4, "MAT4": 16}

def accessor(js, bins, i):
    a = js["accessors"][i]; bv = js["bufferViews"][a["bufferView"]]
    n = NC[a["type"]]; dt = np.dtype(CT[a["componentType"]])
    start = bv.get("byteOffset", 0) + a.get("byteOffset", 0)
    stride = bv.get("byteStride", dt.itemsize * n)
    out = np.empty((a["count"], n), dt)
    for k in range(a["count"]):
        out[k] = np.frombuffer(bins, dt, n, start + k * stride)
    return out

def local_matrix(node):
    if "matrix" in node:
        return np.array(node["matrix"], float).reshape(4, 4).T
    t = np.array(node.get("translation", [0, 0, 0]), float)
    q = np.array(node.get("rotation", [0, 0, 0, 1]), float)
    s = np.array(node.get("scale", [1, 1, 1]), float)
    x, y, z, w = q
    R = np.array([[1-2*(y*y+z*z), 2*(x*y-z*w), 2*(x*z+y*w)], [2*(x*y+z*w), 1-2*(x*x+z*z), 2*(y*z-x*w)], [2*(x*z-y*w), 2*(y*z+x*w), 1-2*(x*x+y*y)]])
    M = np.eye(4); M[:3, :3] = R * s; M[:3, 3] = t
    return M

def walk(js, bins):
    nodes = js["nodes"]; parent = {}
    for i, n in enumerate(nodes):
        for c in n.get("children", []): parent[c] = i
    world = {}
    def W(i):
        if i in world: return world[i]
        M = local_matrix(nodes[i])
        world[i] = (W(parent[i]) @ M) if i in parent else M
        return world[i]
    rows = {}
    for i, n in enumerate(nodes):
        name = n.get("name", "?"); M = W(i)
        pname = nodes[parent[i]]["name"] if i in parent else "-"
        rec = {"parent": pname, "pos": tuple(np.round(M[:3, 3], 2))}
        if "mesh" in n:
            m = js["meshes"][n["mesh"]]
            verts = []; mats = []
            for p in m["primitives"]:
                v = accessor(js, bins, p["attributes"]["POSITION"])
                v = (M[:3, :3] @ v.T).T + M[:3, 3]
                verts.append(v)
                if "material" in p: mats.append(js["materials"][p["material"]].get("name", "?"))
            v = np.vstack(verts)
            key = np.round(v, 1)
            key = key[np.lexsort(key.T)]
            rec["mats"] = tuple(mats)
            rec["bounds"] = (tuple(np.round(v.min(0), 1)), tuple(np.round(v.max(0), 1)))
            rec["hash"] = hashlib.md5(key.tobytes()).hexdigest()[:8]
            rec["nv"] = len(v)
        rows[name] = rec
    return rows

a = walk(*load(sys.argv[1])); b = walk(*load(sys.argv[2]))
verbose = "-v" in sys.argv
if verbose:
    for name, r in sorted(b.items()): print(name, r)
only_a = sorted(set(a) - set(b)); only_b = sorted(set(b) - set(a))
print("nodes:", len(a), "vs", len(b), "| only in first:", only_a, "| only in second:", only_b)
geo_a = sorted(r["hash"] for r in a.values() if "hash" in r); geo_b = sorted(r["hash"] for r in b.values() if "hash" in r)
print("world geometry (hash multiset) identical:", geo_a == geo_b, f"({len(geo_a)} vs {len(geo_b)} meshes)")
if geo_a != geo_b:
    ha = {r["hash"]: n for n, r in a.items() if "hash" in r}; hb = {r["hash"]: n for n, r in b.items() if "hash" in r}
    print("  meshes changed, first:", sorted(ha[h] for h in set(ha) - set(hb))[:30])
    print("  meshes changed, second:", sorted(hb[h] for h in set(hb) - set(ha))[:30])
diff = [(n, a[n]["parent"], b[n]["parent"]) for n in set(a) & set(b) if a[n]["parent"] != b[n]["parent"]]
print("reparented:", sorted(diff)[:40])
joints = sorted((n, r["parent"], r["pos"]) for n, r in b.items() if n.startswith(("joint_", "hp_")))
print("tags in second:"); [print("  ", j) for j in joints]
