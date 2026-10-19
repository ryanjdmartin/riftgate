import json, subprocess, sys, time
jobs = json.load(open(sys.argv[1])); t0 = time.time()
for job in jobs:
    label, args = job[0], job[1:]
    print(f"=== {label} {time.strftime('%H:%M:%S')}", flush=True)
    r = subprocess.run(["tools/foeforge/.venv/bin/python", "tools/foeforge/forge.py"] + args, capture_output=True, text=True)
    print(r.stdout.strip().splitlines()[-1] if r.returncode == 0 and r.stdout.strip() else "FAILED " + r.stderr[-400:], flush=True)
print(f"=== done in {int((time.time() - t0) // 60)} min", flush=True)
