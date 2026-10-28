/* The hangar page's Animation tab (3 October): a machine's idle acts, its gait and its
   cornering, played from the same sidecar the game reads (art/models/<id>.rig.json, written
   by tools/lowforge from models_low.py) on the same glTF (art/models/<id>.glb, published as
   JSON). Published beside the page as hangar/motion.js, the models and sidecars as
   hangar/models/<id>.model.json and <id>.rig.json (tools/hangar_data.py prints the map).

   The motion is a port of game/ui/mech_rig.gd (MechRig: curve, cycle_curve, the acts and
   their servos, the strikes, drive and its gait) and of Map3D._corner (the facing against the path). Keep the
   two in step: a change to the rig's maths lands here in the same commit. The look is this
   page's own (three.js, the models' tiles, flat light); the game is the judge of the look.

   Angles are authored in the machine's terms: pitch about the axle line (+ raises the
   forward end), yaw about up (+ turns left), roll about forward (+ drops the right side).
   The glTF's forward is -Z, so a roll of r is rotation.z = -r and a slide (dx right, dy
   forward, dz up) is (dx, dz, -dy), as in Godot. Euler order YXZ, Godot's. */
(function () {
"use strict";
const THREE_URLS = [
  "https://cdn.jsdelivr.net/npm/three@0.128.0/build/three.min.js",
  "https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/loaders/GLTFLoader.js",
  "https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js",
];

// ---------------------------------------------------------------- the rig (MechRig's numbers)
const GAP_MIN = 6.0, GAP_MAX = 12.0, GAP_DEBUG = 0.4, WAIT_TICK_MAX = 0.1;   // MechRig: a long frame spends at most this much of the gap
const MOVE_REF_SPEED = 150.0, MOVE_BLEND_IN = 0.25, MOVE_BLEND_OUT = 0.35;
const ROCK_ACCEL = 200.0, BANK_TURN = 1.2, DRIFT_UNITS = 12.0;
const STEER_EASE = 0.12;   // MechRig: seconds a steered joint takes to follow the turn, its servo
const PIVOT_STEP = 0.35, PIVOT_CAP = 0.75, PIVOT_FADE = 20.0, PIVOT_MIN = 0.15, BANK_SPEED = 37.5;   // MechRig: turning in place steps the legs round, never faster than PIVOT_CAP of its speed (the twenty-first notes; three quarters in the twenty-second); nothing banks standing (the twentieth)
const HEFT_DEFAULT = 0.12, DAMPING = 0.7, STEP = 1 / 60;   // the servos (MechRig._follow) and the longest step anything advances by
const SLIDE_RATE_SNAP = 12.0, SLIDE_RATE_FULL = 2.2, STRAFE_TURN_RATE = 6.0, REST_TURN_RATE = 4.0;   // Map3D
const OVERSTEER_AHEAD = 0.4, OVERSTEER_GAIN = 1.4, OVERSTEER_MAX = 1.45, OVERSTEER_RATE = 7.0, OVERSTEER_WINDOW = 0.5;   // Map3D: the nose leads the path into a corner, from the heading a moment ahead
const DRIFT_AHEAD = 0.35, DRIFT_WINDOW = 1.4, DRIFT_RATE = 4.5, DRIFT_MAX = 1.55, DRIFT_GAIN = 2.0;   // Map3D: the same for a drifter, eased into its kick-out (Map3D.oversteer_ease)
const oversteerEase = (over) => clamp((over - 0.5) / 1.0, 0, 1);
const oversteerAhead = (over) => lerp(OVERSTEER_AHEAD, DRIFT_AHEAD, oversteerEase(over));
const oversteerWindow = (over) => lerp(OVERSTEER_WINDOW, DRIFT_WINDOW, oversteerEase(over));
const oversteerRate = (over) => lerp(OVERSTEER_RATE, DRIFT_RATE, oversteerEase(over));
const oversteerMax = (over) => lerp(OVERSTEER_MAX, DRIFT_MAX, oversteerEase(over));
const oversteerGain = (over) => lerp(OVERSTEER_GAIN, DRIFT_GAIN, oversteerEase(over));
// Map3D.oversteer_lead: eased toward the limit, never stopped at it hard.
const oversteerLead = (turnAhead, over) => oversteerMax(over) * Math.tanh(turnAhead * oversteerGain(over) * over / oversteerMax(over));
// Map3D.turn_toward: a critically damped spring turning the facing toward `want`, its natural
// frequency twice the first-order rate so it lags as long, so the turn rate eases in and out and
// a corner's start never jolts the nose. Returns [facing, turn rate].
const TURN_RATE_MAX = 5.0, TURN_ACCEL_MAX = 30.0;   // Map3D: the turn rate and its change, capped
const SETOFF_S = 0.5;   // Map3D: a move's set-off eases the aim from the facing it stood at onto the path (setoff_aim)
const SETOFF_TURN_BASE = 0.85, SETOFF_TURN_PER_ACCEL = 0.55, SETOFF_ROLL = 0.75;   // Map3D: it turns onto its way first, rolling off as the turn finishes (the twentieth notes; two fifths slower in the twenty-second)
const setoffTurn = (angle, accel) => (SETOFF_TURN_BASE + SETOFF_TURN_PER_ACCEL * accel) * Math.sqrt(Math.abs(angle) / (Math.PI / 3));
const setoffAim = (from, t, want, dur = SETOFF_S) => { const u = clamp(t / Math.max(0.05, dur), 0, 1); return from + wrapPi(want - from) * u * u * u * (u * (6 * u - 15) + 10); };
function turnToward(facing, vel, want, rate, dt) {
  const w = 2 * rate, n = Math.max(1, Math.ceil(dt * w / 0.25)), h = dt / n;
  for (let i = 0; i < n; i++) {
    const acc = clamp(wrapPi(want - facing) * w * w - 2 * w * vel, -TURN_ACCEL_MAX, TURN_ACCEL_MAX);
    vel = clamp(vel + acc * h, -TURN_RATE_MAX, TURN_RATE_MAX); facing += vel * h;
  }
  return [facing, vel];
}
const GLOW_PAGE = 0.9;   // this page's emission for a lit part at rest (the game's is 1.8 under its own glow pass)
const AXES = ["pitch", "yaw", "roll"];
const D2R = Math.PI / 180;

const clamp = (v, a, b) => Math.min(b, Math.max(a, v));
const lerp = (a, b, t) => a + (b - a) * t;
const fposmod = (a, b) => ((a % b) + b) % b;
const wrapPi = (a) => fposmod(a + Math.PI, Math.PI * 2) - Math.PI;
const lerpAngle = (a, b, t) => a + wrapPi(b - a) * t;
const moveToward = (a, b, d) => Math.abs(b - a) <= d ? b : a + Math.sign(b - a) * d;
const v3 = (x = 0, y = 0, z = 0) => ({x, y, z});
const add3 = (a, b) => v3(a.x + b.x, a.y + b.y, a.z + b.z);
const mul3 = (a, k) => v3(a.x * k, a.y * k, a.z * k);

// An act's keys as a curve (MechRig.curve): [t, v1, v2...] rows, resting at 0 and at the act's
// end unless a key is authored there; "smooth" a monotone cubic through the keys, so a part
// keeps its speed through a key it passes and stops only to turn or hold; "linear" straight.
function curve(keys, duration, ease = "smooth") {
  let width = 1;
  for (const k of keys) width = Math.max(width, k.length);
  const zero = new Array(width).fill(0);
  const pts = [];
  if (!keys.length || keys[0][0] > 0) pts.push(zero.slice());
  for (const k of keys) { const r = k.slice(); while (r.length < width) r.push(0); pts.push(r); }
  if (pts[pts.length - 1][0] < duration) { const e = zero.slice(); e[0] = duration; pts.push(e); }
  return through(pts, ease);
}
// Cyclic keys over a phase of 0 to 1 (MechRig.cycle_curve): two keys of the cycle padded on each
// side, so the curve runs through the wrap without a stop.
function cycleCurve(keys, ease = "smooth") {
  if (!keys.length) return null;
  const rows = [], at = new Set(), snap = (t) => Math.round(t * 10000);
  for (const k of keys) if (k[0] < 1) { rows.push(k.slice()); at.add(snap(k[0])); }
  for (const k of keys) if (k[0] >= 1 && !at.has(snap(k[0] - 1))) { const r = k.slice(); r[0] -= 1; rows.push(r); }
  rows.sort((a, b) => a[0] - b[0]);
  let width = 1;
  for (const r of rows) width = Math.max(width, r.length);
  for (const r of rows) while (r.length < width) r.push(0);
  const n = rows.length, pts = [];
  for (let i = -2; i < n + 2; i++) { const r = rows[fposmod(i, n)].slice(); r[0] += Math.floor(i / n); pts.push(r); }
  return through(pts, ease);
}
// MechRig._once_curves: the stride a gait changes in, once through, never wrapping.
function onceCurves(g) {
  const out = {};
  for (const [name, tr] of Object.entries(g.tracks || {})) out[name] = curve(tr.keys || [], 1, "linear");
  if ((g.body || []).length) out["@body"] = curve(g.body, 1, "linear");
  return out;
}
// MechRig._cycle_curves: the cyclic curves of a gait's tracks and its body.
function cycleCurves(g) {
  const out = {}, ease = g.ease || "smooth";
  for (const [name, tr] of Object.entries(g.tracks || {})) out[name] = cycleCurve(tr.keys || [], ease);
  if ((g.body || []).length) out["@body"] = cycleCurve(g.body, ease);
  return out;
}
const smoothstep = (a, b, x) => { const t = clamp((x - a) / (b - a), 0, 1); return t * t * (3 - 2 * t); };   // Godot's
// The slopes of a monotone cubic (MechRig._through): zero at a turn, a hold and the ends, the
// weighted harmonic mean of the neighbouring secants where the track runs on (Fritsch and Butland).
function through(pts, ease) {
  const n = pts.length, width = pts[0].length - 1, linear = ease === "linear";
  const t = pts.map(p => p[0]), v = pts.map(p => p.slice(1)), m = [];
  for (let i = 0; i < n; i++) {
    const row = new Array(width).fill(0);
    if (!linear && i > 0 && i < n - 1) {
      const h0 = t[i] - t[i - 1], h1 = t[i + 1] - t[i];
      if (h0 > 0 && h1 > 0) for (let j = 0; j < width; j++) {
        const d0 = (v[i][j] - v[i - 1][j]) / h0, d1 = (v[i + 1][j] - v[i][j]) / h1;
        if (d0 * d1 <= 0) continue;
        const w0 = 2 * h1 + h0, w1 = h1 + 2 * h0;
        row[j] = (w0 + w1) / (w0 / d0 + w1 / d1);
      }
    }
    m.push(row);
  }
  return {t, v, m, linear, width};
}
// A curve's values at time t (MechRig.curve_at), held at its first and last keys outside them.
function curveAt(c, time) {
  if (!c) return [];
  const {t, v, m, width} = c, n = t.length;
  if (time <= t[0]) return v[0].slice();
  if (time >= t[n - 1]) return v[n - 1].slice();
  let i = 0, hi = n - 1;
  while (hi - i > 1) { const mid = (i + hi) >> 1; if (t[mid] <= time) i = mid; else hi = mid; }
  const h = t[i + 1] - t[i], u = h <= 0 ? 1 : (time - t[i]) / h, a = v[i], b = v[i + 1], out = [];
  if (c.linear) { for (let j = 0; j < width; j++) out.push(lerp(a[j], b[j], u)); return out; }
  const u2 = u * u, u3 = u2 * u;
  const h00 = 2 * u3 - 3 * u2 + 1, h10 = u3 - 2 * u2 + u, h01 = -2 * u3 + 3 * u2, h11 = u3 - u2;
  for (let j = 0; j < width; j++) out.push(h00 * a[j] + h10 * h * m[i][j] + h01 * b[j] + h11 * h * m[i + 1][j]);
  return out;
}
const sample = (keys, t, duration, ease = "smooth") => curveAt(curve(keys, duration, ease), t);
const sampleCycle = (keys, phase, ease = "smooth") => keys.length ? curveAt(cycleCurve(keys, ease), fposmod(phase, 1)) : [];
function clampDegrees(deg, limits) {
  const out = v3(deg.x, deg.y, deg.z), keys = ["x", "y", "z"];
  for (let i = 0; i < 3; i++) {
    const lim = (limits || {})[AXES[i]];
    if (Array.isArray(lim) && lim.length === 2) out[keys[i]] = clamp(out[keys[i]], lim[0], lim[1]);
  }
  return out;
}
const eulerOf = (deg) => v3(deg.x * D2R, deg.y * D2R, -deg.z * D2R);
const offsetOf = (s) => v3(s.x, s.z, -s.y);
function axisFor(name) { return ["turret", "caster", "steer", "head", "sensor"].some(p => name.startsWith(p)) ? "yaw" : "pitch"; }
function parseTag(name) {
  if (name.startsWith("joint_") && name.length > 6) return ["joint", name.slice(6)];
  const m = /^hp_(\d+)/.exec(name); return m ? ["hp", Number(m[1])] : [];
}
// A lowforge label, or the label with the exporter's numbering (".001", or "001" once three.js
// strips the dot), never another label that starts the same ("tread_deck").
function labelled(name, part) {
  if (name === part) return true;
  if (!name.startsWith(part)) return false;
  return /^[._]?\d+$/.test(name.slice(part.length));
}

class Rig {
  constructor(root, side, rngSeed = 1) {
    this.model = root; this.body = root;
    this.joints = {}; this.hardpoints = {}; this.rest = {}; this.restPos = {};
    root.traverse(n => {
      const tag = parseTag(n.name || "");
      if (tag.length !== 2) return;
      if (tag[0] === "joint") { this.joints[tag[1]] = n; n.rotation.order = "YXZ"; this.rest[tag[1]] = v3(n.rotation.x, n.rotation.y, n.rotation.z); this.restPos[tag[1]] = n.position.clone(); }
      else this.hardpoints[tag[1]] = n;
    });
    const sm = side.joints || {};
    this.meta = {};
    for (const name of Object.keys(this.joints)) {
      const m = sm[name] || {};
      this.meta[name] = {axis: m.axis || axisFor(name), limits: m.limits || {}, swing: m.swing ?? name.startsWith("shoulder"), parent: m.parent || ""};
    }
    this.acts = (side.acts || []).filter(a => a && a.name);
    this.move = side.move || {};
    this.heft = this.move.heft ?? HEFT_DEFAULT;
    this.gaitOptions = side.gait_options || {};   // other ways it could move, to judge beside it (b.gait_option); the game moves by the gait alone
    this.spinners = {}; this.spun = {};   // joints turned without end (MechRig.spinners, b.spin: the Stingray's fans)
    for (const [name, r] of Object.entries(side.spin || {})) if (this.joints[name] && Array.isArray(r) && r.length >= 2) { this.spinners[name] = [Number(r[0]), Number(r[1])]; this.spun[name] = 0; }
    this.useGait(side.gait || {});
    root.rotation.order = "YXZ";
    this.bodyRestPos = root.position.clone();
    this.bodyRestRot = v3(root.rotation.x, root.rotation.y, root.rotation.z);
    this.seed = rngSeed;
    this.debug = "1"; this.lastAct = ""; this.moving = false;
    this.wait = GAP_DEBUG;
    this.current = null; this.t = 0;
    this.actRot = {}; this.actSlide = {}; this.gaitRot = {}; this.gaitSlide = {};
    this.bodyActRot = v3(); this.bodyActSlide = v3(); this.bodyMoveRot = v3(); this.bodyMoveSlide = v3();
    this.curves = {}; this.wantRot = {}; this.wantSlide = {}; this.bodyWantRot = v3(); this.bodyWantSlide = v3(); this.servo = {};
    this.strikes = []; this.glow = []; this.glowCache = {};
    this.dist = 0; this.speed = 0; this.blend = 0; this.accel = 0; this.bank = 0; this.tiltP = 0; this.tiltR = 0; this.drift = 0; this.steerVal = {};
    this.treadMats = []; this.moveGlow = [];
    for (const part of ((this.gait.treads || {}).parts || [])) root.traverse(n => {
      if (n.isMesh && labelled(n.name, part)) for (const m of [].concat(n.material)) if (m.map) this.treadMats.push([m, m.map.offset.x]);
    });
    for (const part of ((this.gait.glow || {}).parts || [])) for (const m of this.litMaterials(part)) this.moveGlow.push([m, m.emissiveIntensity]);
  }
  // Move by this gait from now on: the sidecar's own, or one of its options.
  useGait(g) {
    this.gait = g || {};
    this.spin = new Set(Object.keys(this.gait.wheels || {}));   // an act turns a wheel directly, never through a servo
    this.gaitCurves = cycleCurves(this.gait);
    // MechRig.use_gait: a gait may start and stop in one of the options (the nineteenth notes)
    const st = this.gait.start, opt = st && this.gaitOptions[st.option];
    this.startGait = opt ? {gait: opt, curves: cycleCurves(opt), below: st.below ?? 0.3, full: st.full ?? 0.8} : null;
    // and set off in it at `from`, playing the stride it changes in once into its own at `to` (the twenty-second notes)
    const h = st && st.handoff;
    if (opt && h && h.length > 0) {
      const change = {stride: h.length, ease: "linear", tracks: h.tracks || {}, body: h.body || []};
      change.curves = onceCurves(change);
      Object.assign(this.startGait, {from: h.from || 0, to: h.to || 0, handoff: change});
    }
    this.startOffset = 0; this.mainOffset = 0; this.handing = false;
  }
  random() { this.seed = (this.seed * 1103515245 + 12345) % 2147483648; return this.seed / 2147483648; }
  alive() { return this.acts.length > 0 || this.strikes.length > 0 || !!this.current || Object.keys(this.servo).length > 0 || Object.keys(this.spinners).length > 0; }
  litMaterials(part) {
    if (this.glowCache[part]) return this.glowCache[part];
    const out = [], tag = parseTag(part);
    const collect = (node) => node.traverse(n => { if (n.isMesh) for (const m of [].concat(n.material)) if (m.userData.lit && !out.includes(m)) out.push(m); });
    if (tag.length === 2) { const root = tag[0] === "joint" ? this.joints[tag[1]] : this.hardpoints[tag[1]]; if (root) collect(root); }
    else this.model.traverse(n => { if (n.isMesh && labelled(n.name, part)) collect(n); });
    return this.glowCache[part] = out;
  }
  jointOf(node) {
    let p = node.parent;
    while (p && p !== this.model) { const tag = parseTag(p.name || ""); if (tag[0] === "joint") return tag[1]; p = p.parent; }
    return "";
  }
  choose() {
    if (!this.acts.length) return null;
    if (this.debug && this.debug !== "1") { const a = this.acts.find(x => x.name === this.debug); if (a) return a; }
    if (this.acts.length === 1) return this.acts[0];
    const pool = this.acts.filter(a => a.name !== this.lastAct);
    return pool[Math.floor(this.random() * pool.length) % pool.length];
  }
  play(name) { const a = this.acts.find(x => x.name === name); if (!a) return false; this.endAct(true); this.start(a); this.evaluateAct(); this.pose(); return true; }
  start(a) {
    this.current = a; this.t = 0; this.lastAct = a.name; this.glow = [];
    this.actHeft = a.heft ?? this.heft;   // an act may ask for its own heft (MechRig._act_heft): a blow sharper than the machine's weight
    const d = a.duration || 0, ease = a.ease || "smooth";
    this.curves = {};
    for (const [name, keys] of Object.entries(a.tracks || {})) if (this.joints[name]) this.curves[name] = curve(keys, d, ease);
    if ((a.body || []).length) this.curves["@body"] = curve(a.body, d, ease);
    for (const g of (a.glow || [])) {
      const mats = []; for (const p of g.parts || []) mats.push(...this.litMaterials(p));
      this.glow.push({curve: curve(g.keys || [], d, ease), mats, base: mats.map(m => m.emissiveIntensity)});
    }
  }
  restoreGlow() { for (const g of this.glow) g.mats.forEach((m, i) => { m.emissiveIntensity = g.base[i]; }); this.glow = []; }
  // The act is over (MechRig._end_act): its asks go to nothing and the servos bring every part home.
  endAct(quiet) {
    const wrap = (a) => fposmod(a + 180, 360) - 180;   // the short way round: a loop or a spin ends a whole turn on and never unwinds
    for (const st of Object.values(this.servo)) st[0] = v3(wrap(st[0].x), wrap(st[0].y), wrap(st[0].z));
    this.restoreGlow();
    this.current = null; this.curves = {}; this.wantRot = {}; this.wantSlide = {}; this.bodyWantRot = v3(); this.bodyWantSlide = v3();
    this.wait = this.debug ? GAP_DEBUG : lerp(GAP_MIN, GAP_MAX, this.random());
    if (!quiet) this.pose();
  }
  // Every part home at once, no settling (a change of mode).
  settle() { this.servo = {}; this.actRot = {}; this.actSlide = {}; this.bodyActRot = v3(); this.bodyActSlide = v3(); }
  evaluateAct() {
    for (const [name, c] of Object.entries(this.curves)) {
      const v = curveAt(c, this.t);
      if (name === "@body") { this.bodyWantSlide = v3(v[0], v[1], v[2]); this.bodyWantRot = v.length >= 6 ? v3(v[4], v[3], v[5]) : v3(); continue; }   // authored (yaw, pitch, roll)
      this.wantRot[name] = v3(v[0], v[1], v[2]);
      this.wantSlide[name] = v.length >= 6 ? v3(v[3], v[4], v[5]) : v3();
    }
    for (const g of this.glow) {
      const k = curveAt(g.curve, this.t)[0] + 1;
      g.mats.forEach((m, i) => { m.emissiveIntensity = g.base[i] * Math.max(0, k); });
    }
  }
  // The servos (MechRig._follow): each part a mass on a damped spring chasing what the act asks,
  // the machine's heft its time constant; a part home and still drops out.
  follow(dt) {
    const w = 1 / Math.max(0.02, this.current ? (this.actHeft ?? this.heft) : this.heft), len = (a) => Math.hypot(a.x, a.y, a.z);
    const names = new Set([...Object.keys(this.servo), ...Object.keys(this.wantRot)]);
    if (len(this.bodyWantRot) || len(this.bodyWantSlide)) names.add("@body");
    const chase = (x, v, want) => { const nv = add3(v, mul3(add3(mul3(add3(want, mul3(x, -1)), w * w), mul3(v, -2 * DAMPING * w)), dt)); return [add3(x, mul3(nv, dt)), nv]; };
    for (const name of names) {
      const body = name === "@body";
      const wr = body ? this.bodyWantRot : (this.wantRot[name] || v3()), ws = body ? this.bodyWantSlide : (this.wantSlide[name] || v3());
      let st;
      if (this.spin.has(name)) st = [wr, v3(), ws, v3()];
      else {
        const o = this.servo[name] || [v3(), v3(), v3(), v3()];
        const [r, vr] = chase(o[0], o[1], wr), [sl, vs] = chase(o[2], o[3], ws);
        st = [r, vr, sl, vs];
      }
      const home = !len(wr) && !len(ws) && len(st[0]) < 0.02 && len(st[1]) < 0.05 && len(st[2]) < 0.005 && len(st[3]) < 0.01;
      if (home) { delete this.servo[name]; st = [v3(), v3(), v3(), v3()]; } else this.servo[name] = st;
      if (body) { this.bodyActRot = st[0]; this.bodyActSlide = st[2]; }
      else if (home) { delete this.actRot[name]; delete this.actSlide[name]; }
      else { this.actRot[name] = st[0]; this.actSlide[name] = st[2]; }
    }
  }
  // The act playing at a time of the viewer's choosing (the scrubber): replayed from its start,
  // servos and all, without ending it.
  seek(t) {
    const a = this.current;
    if (!a) return;
    this.restoreGlow(); this.settle(); this.start(a);
    let left = clamp(t, 0, a.duration || 0);
    while (left > 1e-9) { const dt = Math.min(left, STEP); left -= dt; this.t += dt; this.evaluateAct(); this.follow(dt); }
    this.pose();
  }
  // Advance (MechRig.tick): in steps no longer than STEP, so a slow frame lands where frames would.
  tick(delta, acting = true) {
    let moved = false, left = delta;
    this.waitBudget = Math.min(delta, WAIT_TICK_MAX);
    while (left > 0) { const dt = Math.min(left, STEP); left -= dt; if (this.step(dt, acting)) moved = true; }
    for (const [name, r] of Object.entries(this.spinners)) {
      const s = this.spun[name] + (r[0] + (r[1] - r[0]) * this.blend) * delta;
      this.spun[name] = ((s % 360) + 360) % 360; moved = true;
    }
    if (moved) this.pose();
  }
  step(dt, acting) {
    let moved = false;
    if (this.current) {
      this.t += dt; this.evaluateAct(); moved = true;
      if (this.t >= (this.current.duration || 0)) this.endAct(true);
    } else if (acting && this.acts.length && !this.moving) {
      const spent = Math.min(dt, this.waitBudget || 0); this.waitBudget -= spent; this.wait -= spent;
      if (this.wait <= 0) { const next = this.choose(); if (next) { this.start(next); this.evaluateAct(); moved = true; } }
    }
    const bw = this.bodyWantRot, bs = this.bodyWantSlide;
    if (Object.keys(this.servo).length || Object.keys(this.wantRot).length || bw.x || bw.y || bw.z || bs.x || bs.y || bs.z) { this.follow(dt); moved = true; }
    if (this.strikes.length) {
      for (const st of this.strikes) st.t += dt;
      this.strikes = this.strikes.filter(st => st.t < st.up + st.down);
      moved = true;
    }
    return moved;
  }
  // The blows alone, for a paused stage: a blow always plays out (Ryan, 5 October: they only
  // played while an act was running, since a paused stage advanced nothing).
  tickStrikes(delta) {
    if (!this.strikes.length) return;
    for (const st of this.strikes) st.t += delta;
    this.strikes = this.strikes.filter(st => st.t < st.up + st.down);
    this.pose();
  }
  strike(ranged) {
    const armed = {};
    for (const hp of Object.values(this.hardpoints)) { const o = this.jointOf(hp); if (o) armed[o] = true; }
    for (const name of Object.keys(this.joints)) {
      const m = this.meta[name], axis = m.axis;
      let swing;
      if (ranged) { if (!armed[name]) continue; swing = 5; }
      else if (!m.swing) continue;
      else swing = -29;
      const lim = m.limits[axis];
      if (Array.isArray(lim) && lim.length === 2) {
        if (swing > 0 && lim[1] <= 0 && lim[0] < 0) swing = -swing;
        else if (swing < 0 && lim[0] >= 0 && lim[1] > 0) swing = -swing;
      }
      const vec = v3(); vec[["x", "y", "z"][AXES.indexOf(axis)]] = swing;
      this.strikes.push({joint: name, vec, up: ranged ? 0.05 : 0.10, down: ranged ? 0.2 : 0.28, t: 0});
    }
    this.pose();
  }
  static envelope(st) {
    if (st.t < st.up) { const f = st.t / st.up; return 1 - (1 - f) * (1 - f); }
    const g = clamp((st.t - st.up) / st.down, 0, 1);
    return 1 - g * g * (3 - 2 * g);
  }
  pose() {
    for (const [name, j] of Object.entries(this.joints)) {
      let deg = add3(this.actRot[name] || v3(), this.gaitRot[name] || v3());
      for (const st of this.strikes) if (st.joint === name) deg = add3(deg, mul3(st.vec, Rig.envelope(st)));
      deg = clampDegrees(deg, this.meta[name].limits);
      if (name in this.spun) { const k = ["x", "y", "z"][AXES.indexOf(this.meta[name].axis)]; deg = {...deg, [k]: deg[k] + this.spun[name]}; }
      const r = this.rest[name], e = eulerOf(deg);
      j.rotation.set(r.x + e.x, r.y + e.y, r.z + e.z, "YXZ");
      const o = offsetOf(add3(this.actSlide[name] || v3(), this.gaitSlide[name] || v3())), p = this.restPos[name];
      j.position.set(p.x + o.x, p.y + o.y, p.z + o.z);
    }
    const bo = offsetOf(add3(this.bodyActSlide, this.bodyMoveSlide)), be = eulerOf(add3(this.bodyActRot, this.bodyMoveRot));
    this.body.position.set(this.bodyRestPos.x + bo.x, this.bodyRestPos.y + bo.y, this.bodyRestPos.z + bo.z);
    this.body.rotation.set(this.bodyRestRot.x + be.x, this.bodyRestRot.y + be.y, this.bodyRestRot.z + be.z, "YXZ");
  }
  // One frame of movement (MechRig.drive): speed in model units a second, aim the travel's
  // bearing against the facing (+ left), turn the facing's turning (+ left), radians.
  drive(speed, aim, turn, delta) {
    if (delta <= 0) return;
    const prev = this.speed;
    this.speed = lerp(this.speed, Math.max(0, speed), 1 - Math.exp(-delta / 0.12));
    this.accel = lerp(this.accel, (this.speed - prev) / delta, 1 - Math.exp(-delta / 0.15));
    const pivot = Math.abs(turn) > PIVOT_MIN ? Math.min(Math.abs(turn) * PIVOT_STEP * Math.max(1, this.gait.stride || 40), PIVOT_CAP * (this.topSpeed || MOVE_REF_SPEED)) * (1 - clamp(this.speed / PIVOT_FADE, 0, 1)) : 0;
    this.moving = speed > 0.5 || pivot > 0;
    const stood = this.blend < 0.05;   // the gait not yet showing as this frame begins
    this.blend = moveToward(this.blend, this.moving ? 1 : 0, delta / (this.moving ? MOVE_BLEND_IN : MOVE_BLEND_OUT));
    this.dist += (this.speed + pivot) * delta;
    if (speed > 0.5 || this.speed > 0.5) {   // MechRig._travel: rolling since it last stood still
      if (!(this.travel > 0)) this.setOff(stood);
      this.travel = (this.travel || 0) + this.speed * delta;
    } else { this.travel = 0; this.handing = false; }
    const mv = this.move;
    this.bank = lerp(this.bank, (mv.bank || 0) * clamp(-turn / BANK_TURN, -1, 1) * clamp(this.speed / BANK_SPEED, 0, 1), 1 - Math.exp(-delta / 0.3));
    if (Array.isArray(mv.tilt) && mv.tilt.length >= 2) {
      // MechRig: a third number sheds that share of the nose-down at the whole bank's turn rate (it pulls into the corner)
      const share = clamp(this.speed / MOVE_REF_SPEED, 0, 1), f = 1 - Math.exp(-delta / 0.35), pull = mv.tilt.length >= 3 ? mv.tilt[2] * clamp(Math.abs(turn) / BANK_TURN, 0, 1) : 0;
      this.tiltP = lerp(this.tiltP, -mv.tilt[0] * Math.cos(aim) * (1 - pull) * share, f);
      this.tiltR = lerp(this.tiltR, -mv.tilt[1] * Math.sin(aim) * share, f);
    }
    this.drift = lerp(this.drift, (mv.slide || 0) * DRIFT_UNITS * Math.sin(aim) * clamp(this.speed / MOVE_REF_SPEED, 0, 1), 1 - Math.exp(-delta / 0.3));
    // MechRig: steered joints follow the turn on a servo, eased toward their limits (the nineteenth notes)
    for (const [name, k] of Object.entries(this.gait.steer || {})) this.steerVal[name] = lerp(this.steerVal[name] || 0, this.steerSoft(name, turn * k), 1 - Math.exp(-delta / STEER_EASE));
    this.evaluateGait(aim, turn);
    this.pose();
  }
  // MechRig._set_off: the start gait set to its handoff's moment when not yet showing (else the change counts from that moment nearest now), the gait's own to meet its end
  setOff(stood) {
    const st = this.startGait;
    if (!st || !st.handoff) return;
    const s = Math.max(1, st.gait.stride || 40);
    if (stood) { this.startOffset = st.from * s - this.dist; this.handoffAt = this.dist; }
    else this.handoffAt = this.dist - (fposmod((this.dist + this.startOffset) / s - st.from + 0.5, 1) - 0.5) * s;
    this.mainOffset = st.to * Math.max(1, this.gait.stride || 40) - this.handoffAt;
    this.handing = true;
  }
  // MechRig.start_weight: by its share of its speed; wholly the start gait standing and until the change begins
  startWeight() {
    const st = this.startGait;
    if (!st) return 0;
    if (st.handoff && (!this.handing || this.dist < this.handoffAt)) return 1;
    return 1 - smoothstep(st.below, st.full, this.speed / Math.max(1, this.topSpeed || MOVE_REF_SPEED));
  }
  // MechRig.changing: the stride it changes gait in is playing
  changing() {
    const st = this.startGait;
    return !!(this.handing && st && st.handoff && this.dist >= this.handoffAt && this.dist - this.handoffAt < st.handoff.stride);
  }
  // MechRig.steer_soft: eased toward the joint's limit on its axis, never stopped at it hard
  steerSoft(name, raw) {
    const m = this.meta[name] || {}, lim = (m.limits || {})[m.axis || "yaw"];
    if (!Array.isArray(lim) || lim.length !== 2) return raw;
    const edge = Math.abs(raw > 0 ? lim[1] : lim[0]);
    return edge > 0 ? edge * Math.tanh(raw / edge) : raw;
  }
  evaluateGait(aim, turn) {
    const g = this.gait, gr = {}, gs = {}, b = this.blend;
    const addRot = (name, v) => { gr[name] = add3(gr[name] || v3(), v); };
    let rot = v3(), slide = v3();
    // MechRig._add_cycles: a gait's tracks and body bob at a weight, each at its own stride's phase (`offset` units on)
    const st = this.startGait;
    const cycles = (gg, curves, w, offset) => {
      if (w <= 0) return;
      const phase = fposmod((this.dist + offset) / Math.max(1, gg.stride || 40), 1), k = b * w;
      for (const [name, tr] of Object.entries(gg.tracks || {})) {
        if (!this.joints[name] || !curves[name]) continue;
        const v = curveAt(curves[name], fposmod(phase + (tr.phase || 0), 1));
        if (v.length >= 3) gr[name] = add3(gr[name] || v3(), mul3(v3(v[0], v[1], v[2]), k));
        if (v.length >= 6) gs[name] = add3(gs[name] || v3(), mul3(v3(v[3], v[4], v[5]), k));
      }
      if (curves["@body"]) {
        const v = curveAt(curves["@body"], phase);
        if (v.length >= 6) { slide = add3(slide, mul3(v3(v[0], v[1], v[2]), k)); rot = add3(rot, mul3(v3(v[4], v[3], v[5]), k)); }
      }
    };
    // MechRig: off the mark, the stride it changes gait in plays in place of its own
    const startW = this.startWeight();
    if (this.changing()) cycles(st.handoff, st.handoff.curves, 1 - startW, -this.handoffAt);
    else cycles(g, this.gaitCurves, 1 - startW, this.mainOffset || 0);
    if (st && startW > 0) cycles(st.gait, st.curves, startW, this.startOffset || 0);
    for (const [name, r] of Object.entries(g.wheels || {})) if (this.joints[name]) addRot(name, v3(-fposmod(this.dist / Math.max(0.1, r) / D2R, 360), 0, 0));
    // MechRig: steering about each joint's own axis (a knuckle yaws, the Goshawk's nacelles pitch: the eighteenth notes)
    for (const name of Object.keys(g.steer || {})) if (this.joints[name]) { const a = (this.steerVal[name] || 0) * b, ax = Math.max(0, AXES.indexOf((this.meta[name] || {}).axis || "yaw")); addRot(name, v3(ax === 0 ? a : 0, ax === 1 ? a : 0, ax === 2 ? a : 0)); }
    for (const [name, k] of Object.entries(g.aim || {})) if (this.joints[name]) addRot(name, v3(0, aim / D2R * k * b, 0));
    for (const [name, h] of Object.entries(g.hold || {})) if (this.joints[name]) addRot(name, mul3(v3(h[0], h[1], h[2]), b));
    const bh = g.body_hold || [];
    if (bh.length >= 6) { slide = add3(slide, mul3(v3(bh[0], bh[1], bh[2]), b)); rot = add3(rot, mul3(v3(bh[4], bh[3], bh[5]), b)); }
    if (g.rock) rot.x += g.rock * clamp(this.accel / ROCK_ACCEL, -1, 1);
    rot.z += this.bank + this.tiltR;
    rot.x += this.tiltP;
    slide.x += this.drift;
    this.gaitRot = gr; this.gaitSlide = gs; this.bodyMoveRot = rot; this.bodyMoveSlide = slide;
    if (this.treadMats.length) {
      const scroll = ((g.treads || {}).scroll ?? 1) * this.dist / 14;
      for (const [m, base] of this.treadMats) m.map.offset.x = base + fposmod(scroll, 1);
    }
    if (this.moveGlow.length) {
      const k = 1 + ((g.glow || {}).k ?? 1) * b;
      for (const [m, base] of this.moveGlow) m.emissiveIntensity = base * k;
    }
  }
}

// ---------------------------------------------------------------- the move (MovePath)
// A port of game/battle/move_path.gd (Ryan, 4 October: too fast, no acceleration, hard
// corners): the hex centres become one smooth curve, each interior corner cut by a quintic
// whose curvature eases in from the straight and out again (the seventh notes); along it the speed starts at rest, accelerates at the machine's rate, holds full speed
// through the corners (the third pass: no braking for them) and comes to rest at the end.
// Points are {x, z} on the ground plane, in model units.
const MP_CUT = 0.42, MP_ARC_STEPS = 24, MP_FINE = 24, MP_ACCEL = 0.6;
const pAdd = (a, b, k = 1) => ({x: a.x + b.x * k, z: a.z + b.z * k});
const pSub = (a, b) => ({x: a.x - b.x, z: a.z - b.z});
const pLerp = (a, b, t) => ({x: a.x + (b.x - a.x) * t, z: a.z + (b.z - a.z) * t});
const pLen = (a) => Math.hypot(a.x, a.z);
const pNorm = (a) => { const l = pLen(a) || 1; return {x: a.x / l, z: a.z / l}; };
// A quintic Bezier through six control points (MovePath.quintic).
function quintic(c, t) {
  const s = 1 - t, w = [s ** 5, 5 * t * s ** 4, 10 * t * t * s ** 3, 10 * t ** 3 * s * s, 5 * t ** 4 * s, t ** 5];
  let x = 0, z = 0;
  for (let i = 0; i < 6; i++) { x += c[i].x * w[i]; z += c[i].z * w[i]; }
  return {x, z};
}
class MovePath {
  static build(centres, top, accelS = MP_ACCEL) {
    const mp = new MovePath();
    // The curve: corners cut by arcs, each sample carrying its corner's turn.
    const coarse = [centres[0]], cturn = [0];
    for (let i = 1; i < centres.length - 1; i++) {
      const a = centres[i - 1], p = centres[i], b = centres[i + 1];
      const din = pNorm(pSub(p, a)), dout = pNorm(pSub(b, p));
      const turn = Math.abs(Math.atan2(din.x * dout.z - din.z * dout.x, din.x * dout.x + din.z * dout.z));
      if (turn < 0.01) { coarse.push(p); cturn.push(0); continue; }
      const p1 = pLerp(p, a, MP_CUT), p2 = pLerp(p, b, MP_CUT);
      const ctrl = [p1, pLerp(p1, p, 0.4), pLerp(p1, p, 0.8), pLerp(p2, p, 0.8), pLerp(p2, p, 0.4), p2];
      for (let k = 0; k <= MP_ARC_STEPS; k++) { coarse.push(quintic(ctrl, k / MP_ARC_STEPS)); cturn.push(turn); }
    }
    coarse.push(centres[centres.length - 1]); cturn.push(0);
    const pts = [], turns = [];
    for (let i = 0; i < coarse.length; i++) {
      if (i > 0 && cturn[i] === 0 && cturn[i - 1] === 0) for (let k = 1; k < MP_FINE; k++) { pts.push(pLerp(coarse[i - 1], coarse[i], k / MP_FINE)); turns.push(0); }
      if (!pts.length || pLen(pSub(coarse[i], pts[pts.length - 1])) > 0.001) { pts.push(coarse[i]); turns.push(cturn[i]); }
    }
    const n = pts.length;
    mp.points = pts; mp.arc = [0]; mp.speed = []; mp.time = [0];
    for (let i = 1; i < n; i++) mp.arc.push(mp.arc[i - 1] + pLen(pSub(pts[i], pts[i - 1])));
    const a = top / Math.max(0.05, accelS);
    const v = turns.map(() => top);
    v[0] = 0; v[n - 1] = 0;
    for (let i = 1; i < n; i++) v[i] = Math.min(v[i], Math.sqrt(v[i - 1] * v[i - 1] + 2 * a * (mp.arc[i] - mp.arc[i - 1])));
    for (let i = n - 2; i >= 0; i--) v[i] = Math.min(v[i], Math.sqrt(v[i + 1] * v[i + 1] + 2 * a * (mp.arc[i + 1] - mp.arc[i])));
    mp.speed = v;
    for (let i = 1; i < n; i++) mp.time.push(mp.time[i - 1] + (mp.arc[i] - mp.arc[i - 1]) / Math.max(0.5 * (v[i - 1] + v[i]), top * 0.02));
    mp.duration = n > 1 ? mp.time[n - 1] : 0;
    return mp;
  }
  tangent(i) { i = clamp(i, 0, this.points.length - 2); return pNorm(pSub(this.points[i + 1], this.points[i])); }
  // The heading turning evenly along a span between its samples' tangents, each sample's the
  // direction across its two neighbours (MovePath._tangent_at: no stepping round an arc).
  sampleTangent(k) {
    const n = this.points.length;
    if (k <= 0 || k >= n - 1) return this.tangent(k <= 0 ? 0 : n - 2);
    const t = pSub(this.points[k + 1], this.points[k - 1]);
    return pLen(t) > 1e-4 ? pNorm(t) : this.tangent(k);
  }
  tangentAt(i, f) { const t = pLerp(this.sampleTangent(i), this.sampleTangent(i + 1), f); return pLen(t) > 1e-4 ? pNorm(t) : this.tangent(i); }
  // [position, unit tangent, speed, distance along it] at time t
  // MovePath.chord: the direction from the curve at t0 to the curve at t1, the heading averaged
  // over that stretch; null when it has no length.
  chord(t0, t1) {
    const a = this.at(t0)[0], b = this.at(t1)[0], dx = b.x - a.x, dz = b.z - a.z, l = Math.hypot(dx, dz);
    return l > 0.001 ? {x: dx / l, z: dz / l} : null;
  }
  // MovePath.chord_tapered: the heading averaged about t, half either side, the middle counting
  // most (the fourteenth notes): the whole stretch's chord and two nested ones weighted by taper.
  chordTapered(t, half, taper) {
    let x = 0, z = 0;
    for (let j = 1; j <= 3; j++) { const q = this.chord(t - half * j / 3, t + half * j / 3), k = j === 3 ? 1 : taper; if (q) { x += q.x * k; z += q.z * k; } }
    const l = Math.hypot(x, z);
    return l > 1e-6 ? {x: x / l, z: z / l} : null;
  }
  // MovePath.hold_start: it holds at its start that long, turning onto its way, before it sets off
  holdStart(seconds) { this.lead = Math.max(0, seconds); this.duration = (this.time.length ? this.time[this.time.length - 1] : 0) + this.lead; }
  at(t) {
    t -= this.lead || 0;
    const n = this.points.length;
    if (t <= 0) return [this.points[0], this.tangent(0), 0, 0];
    if (t >= this.time[n - 1]) return [this.points[n - 1], this.tangent(n - 2), 0, this.arc[n - 1]];
    let i = 0; while (i < n - 2 && this.time[i + 1] < t) i++;
    const dt = this.time[i + 1] - this.time[i], u = dt <= 0 ? 0 : (t - this.time[i]) / dt;
    const ds = this.arc[i + 1] - this.arc[i];
    const d = (this.speed[i] * u + 0.5 * (this.speed[i + 1] - this.speed[i]) * u * u) * dt;
    const f = ds <= 0 ? 0 : clamp(d / ds, 0, 1);
    return [pLerp(this.points[i], this.points[i + 1], f), this.tangentAt(i, f), lerp(this.speed[i], this.speed[i + 1], u), this.arc[i] + d];
  }
}

// ---------------------------------------------------------------- the route (Map3D._corner)
// Flat-topped hexes, the map's: neighbours at 90, 30, -30, -90, -150 and 150 degrees, a
// step of sqrt(3) circumradii. Two long moves that close a loop (Ryan, 4 October: a longer
// run to judge, fewer stops): three steps north and a turn through north-east and south-east;
// three steps south and a turn back through south-west and north-west. Each move runs along
// its MovePath curve; between moves the machine eases to the facing the simulation records,
// its last step's (Map3D, REST_TURN_RATE). The hex is sized to the machine as the map fits it
// (Map3D.SIZE_FIT: its widest extent is so many hex widths by its class by mass) and a step
// takes the map's time for its move (BattleMapView.MECH_PACE: seconds a hex by its move in
// hexes, straight between the keys), so the pace here is the pace on the map (MechRig.map_speed).
const SIZE_FIT = {light: 0.72, medium: 0.88, heavy: 1.05, assault: 1.2};
const fitFor = (size) => SIZE_FIT[size] || SIZE_FIT.heavy;
const MECH_PACE = [[1, 2.8], [2, 1.9], [3, 1.25], [4, 0.55], [5, 0.42], [6, 0.36]];
function mechSecondsPerHex(move) {
  if (move <= MECH_PACE[0][0]) return MECH_PACE[0][1];
  for (let i = 1; i < MECH_PACE.length; i++) {
    const [b, vb] = MECH_PACE[i], [a, va] = MECH_PACE[i - 1];
    if (move <= b) return lerp(va, vb, (move - a) / (b - a));
  }
  return MECH_PACE[MECH_PACE.length - 1][1];
}
const DIRS = {N: 90, NE: 30, SE: -30, S: -90, SW: -150, NW: 150};
const ROUTE = [["N", "N", "N", "NE", "SE"], ["S", "S", "S", "SW", "NW"]];
const PAUSE = 1.2;
// A direction in degrees (0 east, 90 north) to the ground plane: x east, -z north.
const dirVec = (deg) => ({x: Math.cos(deg * D2R), z: -Math.sin(deg * D2R)});
const yawOf = (d) => Math.atan2(-d.x, -d.z);

class Route {
  constructor(hexR = 60) { this.R = hexR; this.STEP = hexR * Math.sqrt(3); this.reset(); }
  reset() { this.move = 0; this.t = 0; this.curve = null; this.pause = 0.6; this.pos = {x: 0, z: 0}; this.facing = yawOf(dirVec(DIRS.N)); this.rest = this.facing; this.turnVel = 0; }
  points() {
    const pts = [{x: 0, z: 0}]; let p = {x: 0, z: 0};
    for (const mv of ROUTE) for (const d of mv) { p = pAdd(p, dirVec(DIRS[d]), this.STEP); pts.push(p); }
    return pts;
  }
  // Advance by dt; `top` is full speed in model units a second, `move` the machine's motion
  // numbers. Returns what the rig is told, and sets this.pos and this.facing.
  advance(dt, top, move) {
    const mv = ROUTE[this.move];
    if (!this.curve) {
      // At rest between moves: ease to the recorded facing, then set off.
      [this.facing, this.turnVel] = turnToward(this.facing, this.turnVel, this.rest, REST_TURN_RATE, dt);
      this.pause -= dt;
      if (this.pause <= 0) {
        const centres = [this.pos]; let p = this.pos;
        for (const d of mv) { p = pAdd(p, dirVec(DIRS[d]), this.STEP); centres.push(p); }
        this.curve = MovePath.build(centres, top, move.accel ?? MP_ACCEL);
        this.t = 0; this.base = null; this.ahead = null; this.from = this.facing;
        // Map3D.setoff_seconds: it turns onto its way first, the move holding at its start for most of the turn
        this.setoffTurn = (move.strafe || 0) > 0 ? SETOFF_S : Math.max(SETOFF_S, setoffTurn(wrapPi(yawOf(pSub(centres[1], centres[0])) - this.facing), move.accel ?? MP_ACCEL));
        if (!((move.strafe || 0) > 0)) this.curve.holdStart(SETOFF_ROLL * setoffTurn(wrapPi(yawOf(pSub(centres[1], centres[0])) - this.facing), move.accel ?? MP_ACCEL));
      }
      return {speed: 0, aim: 0, turn: this.turnVel};
    }
    this.t += dt;
    if (this.t >= this.curve.duration) {
      this.pos = this.curve.points[this.curve.points.length - 1];
      this.rest = yawOf(dirVec(DIRS[mv[mv.length - 1]]));
      this.move = (this.move + 1) % ROUTE.length; this.curve = null; this.pause = PAUSE;
      if (this.move === 0) this.pos = {x: 0, z: 0};
      // The frame the move ends still turns, toward the facing it now rests on, as the map's
      // standing machine does at once (a nose still easing out of a drift froze a frame here).
      [this.facing, this.turnVel] = turnToward(this.facing, this.turnVel, this.rest, REST_TURN_RATE, dt);
      return {speed: 0, aim: 0, turn: this.turnVel};
    }
    const [here, tan, sp] = this.curve.at(this.t);
    this.here = here;
    const heading = yawOf(tan);
    const slide = clamp(move.slide || 0, 0, 1), strafe = clamp(move.strafe || 0, 0, 1), over = Math.max(0, move.oversteer || 0);
    let rate = lerp(SLIDE_RATE_SNAP, SLIDE_RATE_FULL, slide), want = heading;
    if (over > 0) {
      // The headings averaged about now and a moment ahead, a drifter's tapered to their middle
      // (Map3D: MovePath.chord_tapered), held when the stretch runs off the curve's end.
      const w = oversteerWindow(over) / 2, ah = oversteerAhead(over), tp = oversteerEase(over), cb = this.curve.chordTapered(this.t, w, tp), ca = this.curve.chordTapered(this.t + ah, w, tp);
      if (cb) this.base = yawOf(cb);
      if (ca) this.ahead = yawOf(ca);
      const base = this.base ?? heading, ahead = this.ahead ?? base;
      want = base + oversteerLead(wrapPi(ahead - base), over);
      rate = lerp(rate, oversteerRate(over), Math.min(over, 1));
    }
    if (strafe > 0) { want = lerpAngle(heading, yawOf(dirVec(DIRS[mv[mv.length - 1]])), strafe); rate = lerp(rate, STRAFE_TURN_RATE, strafe); }
    want = setoffAim(this.from, this.t, want, this.setoffTurn);
    [this.facing, this.turnVel] = turnToward(this.facing, this.turnVel, want, rate, dt);
    return {speed: sp, aim: wrapPi(heading - this.facing), turn: this.turnVel};
  }
  where() { return this.curve && this.here ? this.here : this.pos; }
}

// ---------------------------------------------------------------- the stage
// The models' own tiles, nearest sampled on flat facets; the amber role lights, as the game's
// toon pass makes it (MechView3D.toon), each material its own so a glow is per instance.
function prepareMaterials(root) {
  const T = window.THREE;
  root.traverse(n => {
    if (!n.isMesh) return;
    n.material = [].concat(n.material).map(src => {
      const m = src.clone();
      m.flatShading = true; m.side = T.DoubleSide; m.roughness = 0.85; m.metalness = 0.1;
      if (m.map) { m.map = m.map.clone(); m.map.needsUpdate = true; m.map.magFilter = T.NearestFilter; m.map.minFilter = T.NearestFilter; m.map.wrapS = m.map.wrapT = T.RepeatWrapping; }
      if ((src.name || "").startsWith("amber")) { m.emissive = new T.Color(1, 1, 1); m.emissiveMap = m.map; m.emissiveIntensity = GLOW_PAGE; m.userData.lit = true; }
      return m;
    });
    if (n.material.length === 1) n.material = n.material[0];
  });
}
let THREE_READY = null;
function loadScript(src) {
  return new Promise((ok, bad) => { const s = document.createElement("script"); s.src = src; s.async = false; s.onload = ok; s.onerror = () => bad(new Error("could not load " + src)); document.head.append(s); });
}
function three() {
  if (!THREE_READY) THREE_READY = THREE_URLS.reduce((p, u) => p.then(() => loadScript(u)), Promise.resolve());
  return THREE_READY;
}
const cssVar = (name) => getComputedStyle(document.documentElement).getPropertyValue(name).trim() || "#888";

// A hovercraft's idle (HoverBalance, game/ui/hover_balance.gd: keep the two in step; the
// random numbers differ, the motion does not): its attitude a mass on a spring a little
// under critical damping, pushed toward a lean by slow currents wandering every way and
// knocked now and then by a gust, so it tips, catches itself and settles with a touch of
// overshoot; a heave with a slow swell and a dip at each gust (Ryan, 5 October: a platform
// on the water, trying to stay level). Stepped at a fixed rate.
const HB = {OMEGA: 3.2, ZETA: 0.3, CURRENT: 0.05, GUST: 0.22, GUST_GAP: [1.3, 3.4], HEAVE_OMEGA: 2.6, HEAVE_ZETA: 0.4, SWELL: 0.8, HEAVE_GUST: 3.0, STEP: 1 / 120,
            GUST_TIME: 0.5, QUIET: 0.35, QUIET_RATE: 1.5};   // a gust a push over half a second; quiet in an act
class HoverBalance {
  constructor(seed = 1) {
    this.seed = seed;
    this.pitch = 0; this.roll = 0; this.heave = 0; this.quiet = false;
    this.p = 0; this.r = 0; this.h = 0; this.k = 1; this.push = [0, 0, 0]; this.pushT = HB.GUST_TIME;
    this.rate = [0, 0]; this.heaveRate = 0; this.t = 0; this.acc = 0;
    this.phase = [0, 1, 2, 3, 4].map(() => this.random() * Math.PI * 2);
    this.nextGust = 0.4 + this.random() * (HB.GUST_GAP[1] - 0.4);
  }
  random() { this.seed = (this.seed * 1103515245 + 12345) % 2147483648; return this.seed / 2147483648; }
  current(t) {
    const p = this.phase;
    return [(Math.sin(t * 0.53 + p[0]) * 0.6 + Math.sin(t * 1.27 + p[1]) * 0.4) * HB.CURRENT,
            (Math.sin(t * 0.71 + p[2]) * 0.6 + Math.sin(t * 1.53 + p[3]) * 0.4) * HB.CURRENT];
  }
  step(dt) {
    this.acc += Math.min(dt, 0.25);
    const w = HB.OMEGA, d = 2 * HB.ZETA * HB.OMEGA, hw = HB.HEAVE_OMEGA, hd = 2 * HB.HEAVE_ZETA * HB.HEAVE_OMEGA;
    while (this.acc >= HB.STEP) {
      this.acc -= HB.STEP; this.t += HB.STEP;
      const kWant = this.quiet ? HB.QUIET : 1, kStep = HB.QUIET_RATE * HB.STEP;
      this.k += Math.max(-kStep, Math.min(kStep, kWant - this.k));
      if (this.t >= this.nextGust) {
        if (!this.quiet) {
          const a = this.random() * Math.PI * 2, k = 0.6 + this.random() * 0.4;
          this.push = [Math.cos(a) * HB.GUST * k, Math.sin(a) * HB.GUST * k, -HB.HEAVE_GUST * k]; this.pushT = 0;
        }
        this.nextGust = this.t + HB.GUST_GAP[0] + this.random() * (HB.GUST_GAP[1] - HB.GUST_GAP[0]);
      }
      let shove = [0, 0, 0];
      if (this.pushT < HB.GUST_TIME) {
        const f = Math.sin(Math.PI * this.pushT / HB.GUST_TIME) * Math.PI / (2 * HB.GUST_TIME);
        shove = this.push.map(v => v * f); this.pushT += HB.STEP;
      }
      const c = this.current(this.t);
      this.rate[0] += ((c[0] - this.p) * w * w - this.rate[0] * d + shove[0]) * HB.STEP;
      this.rate[1] += ((c[1] - this.r) * w * w - this.rate[1] * d + shove[1]) * HB.STEP;
      this.p += this.rate[0] * HB.STEP; this.r += this.rate[1] * HB.STEP;
      const swell = Math.sin(this.t * 0.9 + this.phase[4]) * HB.SWELL;
      this.heaveRate += ((swell - this.h) * hw * hw - this.heaveRate * hd + shove[2]) * HB.STEP;
      this.h += this.heaveRate * HB.STEP;
      this.pitch = this.p * this.k; this.roll = this.r * this.k; this.heave = this.h * this.k;
    }
  }
}

class Stage {
  constructor() {
    this.el = document.createElement("div");
    this.el.className = "stage";
    this.canvas = document.createElement("canvas");
    this.canvas.setAttribute("aria-label", "The machine, animated");
    this.note = document.createElement("div");
    this.note.className = "stage-note";
    this.note.textContent = "Loading the 3D view…";
    this.el.append(this.canvas, this.note);
    this.mode = "acts"; this.speedK = 1; this.playing = true;
    this.loop = ""; this.listeners = new Set();
    this.models = {}; this.id = ""; this.rig = null;
    this.route = new Route();
    this.raf = 0; this.last = 0;
  }
  on(fn) { this.listeners.add(fn); }
  emit() { for (const fn of this.listeners) fn(this); }
  async init() {
    if (this.renderer) return;
    await three();
    const T = window.THREE;
    this.renderer = new T.WebGLRenderer({canvas: this.canvas, antialias: true, alpha: false});
    this.renderer.setPixelRatio(Math.min(2, window.devicePixelRatio || 1));
    this.renderer.outputEncoding = T.sRGBEncoding;
    this.scene = new T.Scene();
    this.camera = new T.OrthographicCamera(-1, 1, 1, -1, 1, 4000);
    this.controls = new T.OrbitControls(this.camera, this.canvas);
    this.controls.enableDamping = true;
    this.controls.screenSpacePanning = true;
    this.scene.add(new T.HemisphereLight(0xdfe8f2, 0x3a3d42, 0.9));
    const sun = new T.DirectionalLight(0xffffff, 1.25); sun.position.set(-260, 420, 300); this.scene.add(sun);
    this.pivot = new T.Group(); this.scene.add(this.pivot);   // turns to the facing and carries the model
    this.ground = new T.Group(); this.scene.add(this.ground);
    this.trail = null;
    this.paintTheme();
    const mq = window.matchMedia ? window.matchMedia("(prefers-color-scheme: dark)") : null;
    if (mq && mq.addEventListener) mq.addEventListener("change", () => this.paintTheme());
    new MutationObserver(() => this.paintTheme()).observe(document.documentElement, {attributes: true, attributeFilter: ["data-theme"]});
    new ResizeObserver(() => this.resize()).observe(this.el);
    this.note.textContent = "";
  }
  paintTheme() {
    if (!this.scene) return;
    const T = window.THREE;
    this.scene.background = new T.Color(cssVar("--sunk"));
    this.buildGround();
  }
  buildGround() {
    const T = window.THREE;
    while (this.ground.children.length) { const c = this.ground.children.pop(); c.geometry && c.geometry.dispose(); }
    const pts = [], R = this.route.R, STEP = this.route.STEP;
    for (let q = -5; q <= 7; q++) for (let r = -5; r <= 8; r++) {
      const cx = q * R * 1.5, cz = -(r * STEP + (q & 1 ? STEP / 2 : 0)) + STEP * 2;
      for (let i = 0; i < 6; i++) {
        const a = i * 60 * D2R, b = (i + 1) * 60 * D2R;
        pts.push(new T.Vector3(cx + R * Math.cos(a), 0, cz + R * Math.sin(a)), new T.Vector3(cx + R * Math.cos(b), 0, cz + R * Math.sin(b)));
      }
    }
    const grid = new T.LineSegments(new T.BufferGeometry().setFromPoints(pts), new T.LineBasicMaterial({color: new T.Color(cssVar("--ink-3")), transparent: true, opacity: 0.45}));
    this.ground.add(grid);
    const route = this.route.points().map(p => new T.Vector3(p.x, 0.5, p.z));
    const line = new T.Line(new T.BufferGeometry().setFromPoints(route), new T.LineDashedMaterial({color: new T.Color(cssVar("--ink")), dashSize: R * 0.16, gapSize: R * 0.1}));
    line.computeLineDistances();
    this.routeLine = line; this.ground.add(line);
    this.routeLine.visible = this.mode === "route";
    // The hexes sit on the route's points: the loop starts at (0, 0) on a hex centre.
    this.ground.position.set(0, 0, 0);
  }
  resize() {
    if (!this.renderer) return;
    const w = this.el.clientWidth || 300, h = this.el.clientHeight || 300;
    this.renderer.setSize(w, h, false);
    this.aspect = w / h;
    this.frame();
  }
  // An orthographic view on the map's pitch, from the front-left, fitted to the machine or to
  // the whole route. Picking an act leaves the view as it is (Ryan, 6 October, the tenth notes:
  // fitting the view to each act's travel, and turning it back with it, was a nuisance; he
  // zooms out for a flight himself).
  frame(keepDir) {
    if (!this.camera || !this.size) return;
    const STEP = this.route.STEP;
    const half = this.mode === "route" ? STEP * 2.3 + this.size * 0.3 : this.size * 0.75;
    const a = this.aspect || 1;
    this.camera.left = -half * a; this.camera.right = half * a; this.camera.top = half; this.camera.bottom = -half;
    this.camera.updateProjectionMatrix();
    if (!keepDir) {
      const target = this.mode === "route" ? new window.THREE.Vector3(STEP * 0.866, 0, -STEP * 1.5) : new window.THREE.Vector3(0, this.size * 0.3, 0);
      const pitch = 42 * D2R, yaw = (this.mode === "route" ? 20 : 35) * D2R;
      this.camera.position.set(target.x - Math.sin(yaw) * Math.cos(pitch) * 1200, target.y + Math.sin(pitch) * 1200, target.z + Math.cos(yaw) * Math.cos(pitch) * 1200);
      this.camera.zoom = 1; this.camera.updateProjectionMatrix();
      this.controls.target.copy(target);
      this.controls.update();
    }
  }
  // A machine by its chassis id, with its rig sidecar; or, with `shape` set, one silhouette
  // class alone in a maker's metal (shapes/<class>_<maker>), which has no rig and only turns.
  async show(id, shape = false) {
    await this.init();
    if (this.id === id && this.rig) return;
    this.id = id;
    this.isShape = shape;
    this.fits = {};
    this.note.textContent = "Loading " + id.replace("shapes/", "").replace(/_/g, " ") + "…";
    const side = shape ? Promise.resolve({}) : fetch("hangar/models/" + id + ".rig.json", {cache: "no-store"}).then(r => {
      if (!r.ok) throw new Error("hangar/models/" + id + ".rig.json: " + r.status);
      return r.json();
    });
    const [gltf, sidecar] = await Promise.all([this.loadModel(id), side]);
    if (this.id !== id) return;
    const T = window.THREE;
    if (this.modelRoot) this.pivot.remove(this.modelRoot);
    const root = gltf.scene;   // a fresh parse each time, so materials are never shared between visits
    prepareMaterials(root);
    // Hang the model off the pivot centred by its bounds, the ground at its own y = 0 (a class
    // sits on the ground by its lowest point, since it has no ground of its own).
    const box = new T.Box3().setFromObject(root), c = box.getCenter(new T.Vector3()), s = box.getSize(new T.Vector3());
    root.position.set(-c.x, shape ? -box.min.y : 0, -c.z);
    this.size = Math.max(s.x, s.y, s.z);
    this.widest = Math.max(s.x, s.z);
    this.modelRoot = root;
    this.pivot.add(root);
    this.rig = new Rig(root, sidecar, 7);
    this.gaitName = "";
    this.rig.debug = this.loop || "1";
    this.side = sidecar;
    if (shape && this.mode !== "acts") this.mode = "acts";
    this.route = new Route(this.widest / (2 * fitFor(this.size)));
    this.buildGround();
    this.pivot.position.set(0, 0, 0); this.pivot.rotation.set(0, this.route.facing, 0);
    this.balance = this.hover ? new HoverBalance(3) : null;
    this.note.textContent = "";
    this.frame();
    this.emit();
    this.start();
  }
  // Fit a mount as the game does (MechView3D.mount): the stock part under hp_<n> hides and a
  // silhouette class in a maker's metal hangs under the pin, wearing its frame and scale, so it
  // swings and recoils with whatever joint carries the pin. `shape` "" bares the mount; null
  // puts the stock part back.
  async fit(n, shape, maker) {
    const rig = this.rig, pin = rig && rig.hardpoints[n];
    if (!pin) return;
    const id = this.id;
    let part = null;
    if (shape) {
      const gltf = await this.loadModel("shapes/" + shape + "_" + maker);
      if (this.id !== id) return;
      part = gltf.scene;
      prepareMaterials(part);
      part.userData.mounted = true;
    }
    for (const c of pin.children.slice()) {
      if (c.userData.mounted) pin.remove(c);
      else c.visible = shape === null;
    }
    if (part) pin.add(part);
    rig.glowCache = {};   // a fitted part's lights now answer the mount's glow
    if (shape === null) delete this.fits[n]; else this.fits[n] = shape ? shape + ":" + maker : "bare";
    this.emit();
  }
  resetFits() { for (const n of Object.keys(this.fits)) this.fit(Number(n), null); }
  // The glTF as JSON with its binary embedded: an artifact does not serve .glb (tools/hangar_data.py).
  // The page fetches it itself, as it fetches the content files, and three.js only parses it.
  // Its textures sit in the embedded binary, and r128 decodes those by fetch() on a blob:
  // address wherever createImageBitmap exists (Chrome, Safari); the artifact viewer's content
  // policy refuses that fetch ("Failed to fetch", 3 October). The plugin hands the parser an
  // image-element loader instead, which the policy allows for blob: images.
  async loadModel(id) {
    const r = await fetch("hangar/models/" + id + ".model.json", {cache: "no-store"});
    if (!r.ok) throw new Error("hangar/models/" + id + ".model.json: " + r.status);
    const text = await r.text();
    const T = window.THREE;
    const loader = new T.GLTFLoader();
    loader.register(parser => { parser.textureLoader = new T.TextureLoader(parser.options.manager); return {name: "riftgate_image_element_textures"}; });
    return new Promise((ok, bad) => loader.parse(text, "", ok, bad));
  }
  setMode(mode) {
    if (this.isShape) mode = "acts";
    this.mode = mode;
    if (this.rig) { this.rig.endAct(true); this.rig.settle(); this.rig.strikes = []; this.rig.drive(0, 0, 0, 10); this.rig.pose(); }
    this.route.reset();
    if (this.pivot) { this.pivot.position.set(0, 0, 0); this.pivot.rotation.set(0, this.route.facing, 0); }
    if (this.routeLine) this.routeLine.visible = mode === "route";
    this.frame();
    this.emit();
  }
  // Walk by one of the sidecar's gait options, or by its own gait ("").
  setGait(name) {
    if (!this.rig) return;
    this.gaitName = name && this.rig.gaitOptions[name] ? name : "";
    this.rig.useGait(this.gaitName ? this.rig.gaitOptions[this.gaitName] : (this.side.gait || {}));
    this.emit();
  }
  setLoop(name) {
    this.loop = name;
    if (!this.rig) return;
    this.rig.debug = name || "1";
    if (name) this.rig.play(name); else this.rig.endAct();
    this.emit();
  }
  start() {
    if (this.raf) return;
    this.last = performance.now();
    const step = (now) => {
      this.raf = 0;
      if (!this.el.isConnected) return;   // the tab closed: stop until it shows again
      const dt = Math.min(0.05, (now - this.last) / 1000); this.last = now;
      if (this.playing && this.rig) this.advance(dt * this.speedK);
      else if (this.rig) this.rig.tickStrikes(dt * this.speedK);
      this.controls.update();
      this.renderer.render(this.scene, this.camera);
      this.raf = requestAnimationFrame(step);
    };
    this.raf = requestAnimationFrame(step);
  }
  advance(dt) {
    const rig = this.rig;
    if (this.isShape) { this.pivot.rotation.y += 0.5 * dt; return; }   // a class alone turns on its stand
    rig.topSpeed = this.topSpeed();   // MechRig.top_speed: a gait's start crossfades by the share of it
    if (this.mode === "acts") rig.tick(dt, true);
    else if (this.mode === "walk") { rig.tick(dt, false); rig.drive(this.topSpeed(), 0, 0, dt); }
    else {
      rig.tick(dt, false);
      const d = this.route.advance(dt, this.topSpeed(), rig.move);
      rig.drive(d.speed, d.aim, d.turn, dt);
      const p = this.route.where();
      this.pivot.position.set(p.x, 0, p.z);
      this.pivot.rotation.set(0, this.route.facing, 0);
    }
    if (this.balance) {   // a hovercraft balancing on its cushion, as the map and the skirmish draw it
      this.balance.quiet = !!rig.current;
      this.balance.step(dt);
      this.pivot.rotation.order = "YXZ";
      this.pivot.rotation.x = this.balance.pitch;
      this.pivot.rotation.z = this.balance.roll;
      this.pivot.position.y = this.balance.heave;
    }
    if (rig.current) this.emitTick();
  }
  // The machine's full speed on the map in its own model units a second (MechRig.map_speed):
  // the route's step, which the map fits to it, at the map's time for its move.
  topSpeed() { return this.route.STEP / mechSecondsPerHex(this.movespeed || 5); }
  emitTick() { const now = performance.now(); if (!this.lastTick || now - this.lastTick > 90) { this.lastTick = now; this.emit(); } }
  strike(ranged) { if (this.rig) this.rig.strike(ranged); }
  seek(t) { if (this.rig && this.rig.current) { this.rig.seek(t); this.renderer && this.renderer.render(this.scene, this.camera); this.emit(); } }
}

window.HangarMotion = {Rig, Route, Stage, MovePath, HoverBalance, curve, cycleCurve, curveAt, sample, sampleCycle, clampDegrees, labelled, MOVE_REF_SPEED};
})();
