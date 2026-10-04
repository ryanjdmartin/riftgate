/* The hangar page's Animation tab (3 October): a machine's idle acts, its gait and its
   cornering, played from the same sidecar the game reads (art/models/<id>.rig.json, written
   by tools/lowforge from models_low.py) on the same glTF (art/models/<id>.glb, published as
   JSON). Published beside the page as hangar/motion.js, the models and sidecars as
   hangar/models/<id>.model.json and <id>.rig.json (tools/hangar_data.py prints the map).

   The motion is a port of game/ui/mech_rig.gd (MechRig: sample, sample_cycle, the acts, the
   strikes, drive and its gait) and of Map3D._corner (the facing against the path). Keep the
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
const GAP_MIN = 2.5, GAP_MAX = 6.5, GAP_DEBUG = 0.4;
const MOVE_REF_SPEED = 150.0, MOVE_BLEND_IN = 0.25, MOVE_BLEND_OUT = 0.35;
const ROCK_ACCEL = 200.0, BANK_TURN = 1.2, DRIFT_UNITS = 12.0, AIM_HOLD_MAX = 170.0, AIM_RELAX = 0.8;
const SLIDE_RATE_SNAP = 12.0, SLIDE_RATE_FULL = 2.2, STRAFE_TURN_RATE = 6.0, REST_TURN_RATE = 4.0;   // Map3D
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

// Keys [t, v1, v2...] sampled at t; the track rests at 0 and at the act's end (MechRig.sample).
function sample(keys, t, duration, ease = "smooth") {
  let width = 1;
  for (const k of keys) width = Math.max(width, k.length);
  const zero = new Array(width).fill(0);
  const pts = [];
  if (!keys.length || keys[0][0] > 0) pts.push(zero.slice());
  for (const k of keys) { const r = k.slice(); while (r.length < width) r.push(0); pts.push(r); }
  if (pts[pts.length - 1][0] < duration) { const e = zero.slice(); e[0] = duration; pts.push(e); }
  if (t <= pts[0][0]) return pts[0].slice(1);
  for (let i = 1; i < pts.length; i++) {
    const a = pts[i - 1], b = pts[i];
    if (t <= b[0]) {
      const span = b[0] - a[0];
      let f = span <= 0 ? 1 : (t - a[0]) / span;
      if (ease !== "linear") f = f * f * (3 - 2 * f);
      const out = [];
      for (let j = 1; j < width; j++) out.push(lerp(a[j], b[j], f));
      return out;
    }
  }
  return pts[pts.length - 1].slice(1);
}
// Cyclic keys over a phase in [0, 1) (MechRig.sample_cycle).
function sampleCycle(keys, phase, ease = "smooth") {
  if (!keys.length) return [];
  const pts = keys.map(k => k.slice()).sort((a, b) => a[0] - b[0]);
  if (pts[0][0] > 0) { const k0 = pts[pts.length - 1].slice(); k0[0] = pts[pts.length - 1][0] - 1; pts.unshift(k0); }
  if (pts[pts.length - 1][0] < 1) { const k1 = (pts[0][0] >= 0 ? pts[0] : pts[1]).slice(); k1[0] += 1; pts.push(k1); }
  return sample(pts, fposmod(phase, 1), 2, ease);
}
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
    this.gait = side.gait || {};
    root.rotation.order = "YXZ";
    this.bodyRestPos = root.position.clone();
    this.bodyRestRot = v3(root.rotation.x, root.rotation.y, root.rotation.z);
    this.seed = rngSeed;
    this.debug = "1"; this.lastAct = ""; this.moving = false;
    this.wait = GAP_DEBUG;
    this.current = null; this.t = 0;
    this.actRot = {}; this.actSlide = {}; this.gaitRot = {}; this.gaitSlide = {};
    this.bodyActRot = v3(); this.bodyActSlide = v3(); this.bodyMoveRot = v3(); this.bodyMoveSlide = v3();
    this.strikes = []; this.glow = []; this.glowCache = {};
    this.dist = 0; this.speed = 0; this.blend = 0; this.accel = 0; this.bank = 0; this.tiltP = 0; this.tiltR = 0; this.drift = 0; this.aimHold = {};
    this.treadMats = []; this.moveGlow = [];
    for (const part of ((this.gait.treads || {}).parts || [])) root.traverse(n => {
      if (n.isMesh && labelled(n.name, part)) for (const m of [].concat(n.material)) if (m.map) this.treadMats.push([m, m.map.offset.x]);
    });
    for (const part of ((this.gait.glow || {}).parts || [])) for (const m of this.litMaterials(part)) this.moveGlow.push([m, m.emissiveIntensity]);
  }
  random() { this.seed = (this.seed * 1103515245 + 12345) % 2147483648; return this.seed / 2147483648; }
  alive() { return this.acts.length > 0 || this.strikes.length > 0 || !!this.current; }
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
    for (const g of (a.glow || [])) {
      const mats = []; for (const p of g.parts || []) mats.push(...this.litMaterials(p));
      this.glow.push({keys: g.keys || [], mats, base: mats.map(m => m.emissiveIntensity)});
    }
  }
  endAct(quiet) {
    for (const g of this.glow) g.mats.forEach((m, i) => { m.emissiveIntensity = g.base[i]; });
    this.glow = []; this.current = null; this.actRot = {}; this.actSlide = {};
    this.bodyActRot = v3(); this.bodyActSlide = v3();
    this.wait = this.debug ? GAP_DEBUG : lerp(GAP_MIN, GAP_MAX, this.random());
    if (!quiet) this.pose();
  }
  evaluateAct() {
    const a = this.current, duration = a.duration || 0, ease = a.ease || "smooth";
    for (const [name, keys] of Object.entries(a.tracks || {})) {
      if (!this.joints[name]) continue;
      const v = sample(keys, this.t, duration, ease);
      this.actRot[name] = v3(v[0], v[1], v[2]);
      this.actSlide[name] = v.length >= 6 ? v3(v[3], v[4], v[5]) : v3();
    }
    if ((a.body || []).length) {
      const v = sample(a.body, this.t, duration, ease);
      this.bodyActSlide = v3(v[0], v[1], v[2]);
      this.bodyActRot = v3(v[4], v[3], v[5]);   // authored (yaw, pitch, roll)
    }
    for (const g of this.glow) {
      const k = sample(g.keys, this.t, duration, ease)[0] + 1;
      g.mats.forEach((m, i) => { m.emissiveIntensity = g.base[i] * Math.max(0, k); });
    }
  }
  // The act playing at a time of the viewer's choosing (the scrubber), without advancing it.
  seek(t) { if (!this.current) return; this.t = clamp(t, 0, this.current.duration || 0); this.evaluateAct(); this.pose(); }
  tick(delta, acting = true) {
    let moved = false;
    if (this.current) {
      this.t += delta; this.evaluateAct(); moved = true;
      if (this.t >= (this.current.duration || 0)) this.endAct();
    } else if (acting && this.acts.length && !this.moving) {
      this.wait -= delta;
      if (this.wait <= 0) { const next = this.choose(); if (next) { this.start(next); this.evaluateAct(); moved = true; } }
    }
    if (this.strikes.length) {
      for (const st of this.strikes) st.t += delta;
      this.strikes = this.strikes.filter(st => st.t < st.up + st.down);
      moved = true;
    }
    if (moved) this.pose();
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
    this.moving = speed > 0.5;
    this.blend = moveToward(this.blend, this.moving ? 1 : 0, delta / (this.moving ? MOVE_BLEND_IN : MOVE_BLEND_OUT));
    this.dist += this.speed * delta;
    const mv = this.move;
    this.bank = lerp(this.bank, (mv.bank || 0) * clamp(-turn / BANK_TURN, -1, 1), 1 - Math.exp(-delta / 0.3));
    if (Array.isArray(mv.tilt) && mv.tilt.length >= 2) {
      const share = clamp(this.speed / MOVE_REF_SPEED, 0, 1), f = 1 - Math.exp(-delta / 0.35);
      this.tiltP = lerp(this.tiltP, -mv.tilt[0] * Math.cos(aim) * share, f);
      this.tiltR = lerp(this.tiltR, -mv.tilt[1] * Math.sin(aim) * share, f);
    }
    this.drift = lerp(this.drift, (mv.slide || 0) * DRIFT_UNITS * Math.sin(aim) * clamp(this.speed / MOVE_REF_SPEED, 0, 1), 1 - Math.exp(-delta / 0.3));
    for (const [name, share] of Object.entries(this.gait.hold_aim || {})) {
      let held = this.aimHold[name] || 0;
      if (Math.abs(turn) > 0.15) held = clamp(held - turn / D2R * delta * share, -AIM_HOLD_MAX, AIM_HOLD_MAX);
      else held = lerp(held, 0, 1 - Math.exp(-delta / AIM_RELAX));
      this.aimHold[name] = held;
    }
    this.evaluateGait(aim, turn);
    this.pose();
  }
  evaluateGait(aim, turn) {
    const g = this.gait, gr = {}, gs = {};
    const phase = fposmod(this.dist / Math.max(1, g.stride || 40), 1), ease = g.ease || "smooth", b = this.blend;
    const addRot = (name, v) => { gr[name] = add3(gr[name] || v3(), v); };
    for (const [name, tr] of Object.entries(g.tracks || {})) {
      if (!this.joints[name]) continue;
      const v = sampleCycle(tr.keys || [], phase + (tr.phase || 0), ease);
      if (v.length >= 3) gr[name] = mul3(v3(v[0], v[1], v[2]), b);
      if (v.length >= 6) gs[name] = mul3(v3(v[3], v[4], v[5]), b);
    }
    for (const [name, r] of Object.entries(g.wheels || {})) if (this.joints[name]) addRot(name, v3(-fposmod(this.dist / Math.max(0.1, r) / D2R, 360), 0, 0));
    for (const [name, k] of Object.entries(g.steer || {})) if (this.joints[name]) addRot(name, v3(0, turn / D2R * k * b, 0));
    for (const [name, k] of Object.entries(g.aim || {})) if (this.joints[name]) addRot(name, v3(0, aim / D2R * k * b, 0));
    for (const [name, h] of Object.entries(this.aimHold)) if (this.joints[name]) addRot(name, v3(0, h, 0));
    for (const [name, h] of Object.entries(g.hold || {})) if (this.joints[name]) addRot(name, mul3(v3(h[0], h[1], h[2]), b));
    let rot = v3(), slide = v3();
    if ((g.body || []).length) {
      const v = sampleCycle(g.body, phase, ease);
      if (v.length >= 6) { slide = add3(slide, mul3(v3(v[0], v[1], v[2]), b)); rot = add3(rot, mul3(v3(v[4], v[3], v[5]), b)); }
    }
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
// corners): the hex centres become one smooth curve, each interior corner cut by a quadratic
// arc; along it the speed starts at rest, accelerates at the machine's rate, brakes into each
// corner by its sharpness and the machine's `corner` share, and comes to rest at the end.
// Points are {x, z} on the ground plane, in model units.
const MP_CUT = 0.42, MP_ARC_STEPS = 8, MP_FINE = 24, MP_ACCEL = 0.6, MP_CORNER = 0.35, MP_FLOOR = 0.2;
const pAdd = (a, b, k = 1) => ({x: a.x + b.x * k, z: a.z + b.z * k});
const pSub = (a, b) => ({x: a.x - b.x, z: a.z - b.z});
const pLerp = (a, b, t) => ({x: a.x + (b.x - a.x) * t, z: a.z + (b.z - a.z) * t});
const pLen = (a) => Math.hypot(a.x, a.z);
const pNorm = (a) => { const l = pLen(a) || 1; return {x: a.x / l, z: a.z / l}; };
class MovePath {
  static build(centres, top, accelS = MP_ACCEL, corner = MP_CORNER) {
    const mp = new MovePath();
    // The curve: corners cut by arcs, each sample carrying its corner's turn.
    const coarse = [centres[0]], cturn = [0];
    for (let i = 1; i < centres.length - 1; i++) {
      const a = centres[i - 1], p = centres[i], b = centres[i + 1];
      const din = pNorm(pSub(p, a)), dout = pNorm(pSub(b, p));
      const turn = Math.abs(Math.atan2(din.x * dout.z - din.z * dout.x, din.x * dout.x + din.z * dout.z));
      if (turn < 0.01) { coarse.push(p); cturn.push(0); continue; }
      const p1 = pLerp(p, a, MP_CUT), p2 = pLerp(p, b, MP_CUT);
      for (let k = 0; k <= MP_ARC_STEPS; k++) { const t = k / MP_ARC_STEPS; coarse.push(pLerp(pLerp(p1, p, t), pLerp(p, p2, t), t)); cturn.push(turn); }
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
    const v = turns.map(t => top * Math.max(MP_FLOOR, 1 - clamp(corner, 0, 1) * clamp(t / (Math.PI / 3), 0, 2)));
    v[0] = 0; v[n - 1] = 0;
    for (let i = 1; i < n; i++) v[i] = Math.min(v[i], Math.sqrt(v[i - 1] * v[i - 1] + 2 * a * (mp.arc[i] - mp.arc[i - 1])));
    for (let i = n - 2; i >= 0; i--) v[i] = Math.min(v[i], Math.sqrt(v[i + 1] * v[i + 1] + 2 * a * (mp.arc[i + 1] - mp.arc[i])));
    mp.speed = v;
    for (let i = 1; i < n; i++) mp.time.push(mp.time[i - 1] + (mp.arc[i] - mp.arc[i - 1]) / Math.max(0.5 * (v[i - 1] + v[i]), top * 0.02));
    mp.duration = n > 1 ? mp.time[n - 1] : 0;
    return mp;
  }
  tangent(i) { i = clamp(i, 0, this.points.length - 2); return pNorm(pSub(this.points[i + 1], this.points[i])); }
  // [position, unit tangent, speed, distance along it] at time t
  at(t) {
    const n = this.points.length;
    if (t <= 0) return [this.points[0], this.tangent(0), 0, 0];
    if (t >= this.duration) return [this.points[n - 1], this.tangent(n - 2), 0, this.arc[n - 1]];
    let i = 0; while (i < n - 2 && this.time[i + 1] < t) i++;
    const dt = this.time[i + 1] - this.time[i], u = dt <= 0 ? 0 : (t - this.time[i]) / dt;
    const ds = this.arc[i + 1] - this.arc[i];
    const d = (this.speed[i] * u + 0.5 * (this.speed[i + 1] - this.speed[i]) * u * u) * dt;
    return [pLerp(this.points[i], this.points[i + 1], ds <= 0 ? 0 : clamp(d / ds, 0, 1)), this.tangent(i), lerp(this.speed[i], this.speed[i + 1], u), this.arc[i] + d];
  }
}

// ---------------------------------------------------------------- the route (Map3D._corner)
// Flat-topped hexes, the map's: neighbours at 90, 30, -30, -90, -150 and 150 degrees, a
// step of sqrt(3) circumradii. Four moves that close a loop: two steps north; a corner
// through north-east and south-east; two steps south; a corner back through south-west and
// north-west. Each move runs along its MovePath curve; between moves the machine eases to
// the facing the simulation records, its last step's (Map3D, REST_TURN_RATE). The hex is
// sized to the machine as the map fits it (Map3D: its widest extent is MARKER_FIT hex
// widths, a flyer FIT_FLYER of that) and a step takes the map's time (BattleMapView:
// MECH_SECONDS_PER_HEX, slower below MOVE_REF_SPEED), so the pace here is the pace on the map.
const MARKER_FIT = 1.05, FIT_FLYER = 0.8, MECH_SECONDS_PER_HEX = 0.55, MAP_REF_SPEED = 50;
const DIRS = {N: 90, NE: 30, SE: -30, S: -90, SW: -150, NW: 150};
const ROUTE = [["N", "N"], ["NE", "SE"], ["S", "S"], ["SW", "NW"]];
const PAUSE = 1.2;
// A direction in degrees (0 east, 90 north) to the ground plane: x east, -z north.
const dirVec = (deg) => ({x: Math.cos(deg * D2R), z: -Math.sin(deg * D2R)});
const yawOf = (d) => Math.atan2(-d.x, -d.z);

class Route {
  constructor(hexR = 60) { this.R = hexR; this.STEP = hexR * Math.sqrt(3); this.reset(); }
  reset() { this.move = 0; this.t = 0; this.curve = null; this.pause = 0.6; this.pos = {x: 0, z: 0}; this.facing = yawOf(dirVec(DIRS.N)); this.rest = this.facing; }
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
      const step = wrapPi(this.rest - this.facing) * (1 - Math.exp(-dt * REST_TURN_RATE));
      this.facing += step;
      this.pause -= dt;
      if (this.pause <= 0) {
        const centres = [this.pos]; let p = this.pos;
        for (const d of mv) { p = pAdd(p, dirVec(DIRS[d]), this.STEP); centres.push(p); }
        this.curve = MovePath.build(centres, top, move.accel ?? MP_ACCEL, move.corner ?? MP_CORNER);
        this.t = 0;
      }
      return {speed: 0, aim: 0, turn: dt > 0 ? step / dt : 0};
    }
    this.t += dt;
    if (this.t >= this.curve.duration) {
      this.pos = this.curve.points[this.curve.points.length - 1];
      this.rest = yawOf(dirVec(DIRS[mv[mv.length - 1]]));
      this.move = (this.move + 1) % ROUTE.length; this.curve = null; this.pause = PAUSE;
      if (this.move === 0) this.pos = {x: 0, z: 0};
      return {speed: 0, aim: 0, turn: 0};
    }
    const [here, tan, sp] = this.curve.at(this.t);
    this.here = here;
    const heading = yawOf(tan);
    const slide = clamp(move.slide || 0, 0, 1), strafe = clamp(move.strafe || 0, 0, 1);
    let rate = lerp(SLIDE_RATE_SNAP, SLIDE_RATE_FULL, slide), want = heading;
    if (strafe > 0) { want = lerpAngle(heading, yawOf(dirVec(DIRS[mv[mv.length - 1]])), strafe); rate = lerp(rate, STRAFE_TURN_RATE, strafe); }
    const step = wrapPi(want - this.facing) * (1 - Math.exp(-dt * rate));
    this.facing += step;
    return {speed: sp, aim: wrapPi(heading - this.facing), turn: dt > 0 ? step / dt : 0};
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
  // An orthographic view on the map's pitch, from the front-left, fitted to the machine or
  // to the whole route.
  frame(keepDir) {
    if (!this.camera || !this.size) return;
    const STEP = this.route.STEP, half = this.mode === "route" ? STEP * 1.75 + this.size * 0.3 : this.size * 0.75;
    const a = this.aspect || 1;
    this.camera.left = -half * a; this.camera.right = half * a; this.camera.top = half; this.camera.bottom = -half;
    this.camera.updateProjectionMatrix();
    if (!keepDir) {
      const target = this.mode === "route" ? new window.THREE.Vector3(STEP * 0.866, 0, -STEP) : new window.THREE.Vector3(0, this.size * 0.3, 0);
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
    this.rig.debug = this.loop || "1";
    this.side = sidecar;
    if (shape && this.mode !== "acts") this.mode = "acts";
    this.route = new Route(this.widest / (2 * MARKER_FIT * (this.flyer ? FIT_FLYER : 1)));
    this.buildGround();
    this.pivot.position.set(0, 0, 0); this.pivot.rotation.set(0, this.route.facing, 0);
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
    if (this.rig) { this.rig.endAct(true); this.rig.strikes = []; this.rig.drive(0, 0, 0, 10); this.rig.pose(); }
    this.route.reset();
    if (this.pivot) { this.pivot.position.set(0, 0, 0); this.pivot.rotation.set(0, this.route.facing, 0); }
    if (this.routeLine) this.routeLine.visible = mode === "route";
    this.frame();
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
      this.controls.update();
      this.renderer.render(this.scene, this.camera);
      this.raf = requestAnimationFrame(step);
    };
    this.raf = requestAnimationFrame(step);
  }
  advance(dt) {
    const rig = this.rig;
    if (this.isShape) { this.pivot.rotation.y += 0.5 * dt; return; }   // a class alone turns on its stand
    if (this.mode === "acts") rig.tick(dt, true);
    else if (this.mode === "walk") { rig.tick(dt, false); rig.drive(MOVE_REF_SPEED, 0, 0, dt); }
    else {
      rig.tick(dt, false);
      const speed = this.route.STEP / (MECH_SECONDS_PER_HEX * Math.max(1, MAP_REF_SPEED / Math.max(1, this.movespeed || MAP_REF_SPEED)));
      const d = this.route.advance(dt, speed, rig.move);
      rig.drive(d.speed, d.aim, d.turn, dt);
      const p = this.route.where();
      this.pivot.position.set(p.x, 0, p.z);
      this.pivot.rotation.set(0, this.route.facing, 0);
    }
    if (rig.current) this.emitTick();
  }
  emitTick() { const now = performance.now(); if (!this.lastTick || now - this.lastTick > 90) { this.lastTick = now; this.emit(); } }
  strike(ranged) { if (this.rig) this.rig.strike(ranged); }
  seek(t) { if (this.rig && this.rig.current) { this.rig.seek(t); this.renderer && this.renderer.render(this.scene, this.camera); this.emit(); } }
}

window.HangarMotion = {Rig, Route, Stage, MovePath, sample, sampleCycle, clampDegrees, labelled, MOVE_REF_SPEED};
})();
