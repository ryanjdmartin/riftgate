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
const RECOIL_SLIDE = 1.5;   // MechRig: world units a gun that only runs in and out of its port kicks back on a shot
const COUNT_RISE = 0.08, COUNT_FALL = 0.35, COUNT_DEBUG_PERIOD = 1.0;   // MechRig: a count display's part lighting and fading, and the beat it counts to with no fight to count (RIFTGATE_COUNT_DEBUG's)
const SPIN_HELD_EASE = 0.45;   // MechRig: seconds a status's spin takes to come up to speed and to run down
const PARK_TIME = 0.3;   // MechRig: seconds a locked spin takes to park on its next step ahead
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
const GLOW_PAGE = 1.8;   // a lit part's light at rest, the game's (MechView3D.toon), shown as the phone shows it (PHONE_GLOW)
// A lit part's colour as the phone shows it (Ryan, 29 October: the Polar Bear's new vent glow looked
// "the same" here). The game's renderer (gl_compatibility, the phone's and the desk's) lights in sRGB
// space: a lit tile shows as the tile as stored times its light, each channel clipped at one (measured
// from its renders), the light first eased by the power 1/2.2 so a flare holds its colour (MechRig.light;
// Ryan, 30 October: "white doesn't really sell" hot). This page lights in linear space and would decode
// the tile first, crushing a dark tile the game multiplies up to its colour (the vents' heat showed dull
// brown), so a lit part takes the game's colour and only then goes into this page's linear light.
const PHONE_GLOW = `#ifdef USE_EMISSIVEMAP
  totalEmissiveRadiance = sRGBToLinear(vec4(min(texture2D(emissiveMap, vUv).rgb * pow(totalEmissiveRadiance, vec3(1.0 / 2.2)), vec3(1.0)), 1.0)).rgb;
#endif`;
// A lit part's halo (MechRig's halos, on trial; halo.gdshader): a copy of the part grown out along
// its smoothed normals, in the part's colour at its light without its grey, held to its hue and
// squared to lean red (never white), whole from the part's edge and fading to nothing at the
// shell's rim, faded in as the light climbs over its rest, drawn a little toward the eye so a part
// in a slot glows out over its walls, and added to what it lies over as the game adds it (the
// colour times the alpha, the root of the strength in each); written as it is, not re-encoded,
// so it shows the game's colour.
const HALO_FULL = 8, HALO_REACH = 0.45, HALO_AHEAD = 3, HALO_SPREAD = 0.025;
// A weapon's fire flaring as it fires (MechRig.flash_k): up to `peak` rests over its own in `up`
// seconds, held `hold`, gone in `down`, easing out.
const FLASH = {peak: 12, up: 0.05, hold: 0.15, down: 0.6};
function flashK(t) {
  if (t < FLASH.up) return FLASH.peak * t / FLASH.up;
  t -= FLASH.up;
  if (t < FLASH.hold) return FLASH.peak;
  const u = Math.min(1, Math.max(0, 1 - (t - FLASH.hold) / FLASH.down));
  return FLASH.peak * u * u;
}
const HALO_VERT = `uniform float grow; uniform float ahead; varying vec2 vUv; varying vec3 vN; varying vec3 vV;
void main() { vUv = uv; vec4 mv = modelViewMatrix * vec4(position + normal * grow, 1.0); vN = normalize(normalMatrix * normal); vV = normalize(-mv.xyz);
  mv.xyz += mix(normalize(-mv.xyz), vec3(0.0, 0.0, 1.0), projectionMatrix[3][3]) * ahead * length(modelViewMatrix[0].xyz); gl_Position = projectionMatrix * mv; }`;
const HALO_FRAG = `uniform sampler2D tile; uniform float light; uniform float presence; uniform float reach; varying vec2 vUv; varying vec3 vN; varying vec3 vV;
void main() { vec3 t = texture2D(tile, vUv).rgb; vec3 c = (t - min(t.r, min(t.g, t.b))) * light; c /= max(1.0, max(c.r, max(c.g, c.b))); c *= c;
  float f = abs(dot(normalize(vN), normalize(vV))); float a = sqrt(reach * presence * smoothstep(0.0, 0.6, f)); gl_FragColor = vec4(c * a, a); }`;
// A weapon's muzzle flare (MuzzleFlare; Ryan, 31 October: "If the flare colour of the weapons can
// follow their tags, that would be really cool"): a quad facing the eye at its gun's muzzle (a
// class's in hangar/models/shapes/muzzles.json, a stock gun's as its class's), a
// soft core with rays, its middle hot, a layer a tag (the delivery first, what it carries smaller
// and a beat behind), each on its look's beat, its colour laid over what is there
// (flare.gdshader). Colours as each kind of shot looks, free of the colourblind rules (Ryan, 2
// November). The same table as the game's.
const FLARES = {
  colours: {ballistic: [1.0, 0.71, 0.24], missile: [1.0, 0.48, 0.13], flame: [1.0, 0.29, 0.06], beam: [1.0, 0.13, 0.25], plasma: [0.4, 1.0, 0.33], arc: [0.54, 0.85, 1.0], blade: [1.0, 0.84, 0.35]},
  cores: {ballistic: 0.7, missile: 0.5, flame: 0.35, beam: 0.6, plasma: 0.55, arc: 0.75, blade: 0.8},
  order: ["ballistic", "missile", "beam", "blade", "melee", "flame", "plasma", "arc"],
  classLook: {barrel: "ballistic", twin_barrel: "ballistic", rack: "missile", dish: "arc"},
  layerDelay: 0.05, layerScale: 0.75,
  beats: {
    ballistic: {rays: 4, up: 0.03, hold: 0.04, down: 0.16, flicker: 0, scale: 1.0},
    missile: {rays: 0, up: 0.06, hold: 0.10, down: 0.45, flicker: 0, scale: 1.25},
    flame: {rays: 0, up: 0.06, hold: 0.28, down: 0.35, flicker: 14, scale: 1.15},
    beam: {rays: 2, up: 0.04, hold: 0.32, down: 0.18, flicker: 0, scale: 1.4},
    plasma: {rays: 6, up: 0.14, hold: 0.10, down: 0.30, flicker: 0, scale: 1.2},
    arc: {rays: 5, up: 0.02, hold: 0.30, down: 0.10, flicker: 22, scale: 1.0},
    blade: {rays: 8, up: 0.02, hold: 0.03, down: 0.12, flicker: 0, scale: 0.8},
  },
};
// MuzzleFlare.lunges: melee with nothing that sends its blow across the field (no tag of CROSSING,
// no firing class) lunges; the rest fire as guns, a shotgun tagged melee and ballistic among them
// (Ryan, 3 November, of the Bullion Fragmenter: "It's a shotgun, thematically").
const CROSSING = ["ballistic", "missile", "beam"], FIRING = ["barrel", "twin_barrel", "rack", "dish"];
function lunges(tags, shape) {
  tags = tags || [];
  return tags.includes("melee") && !FIRING.includes(shape) && !CROSSING.some(t => tags.includes(t));
}
function flareLooks(tags, shape) {   // MuzzleFlare.looks_for: every look its tags give it, in the order they layer; melee's sparks only on a weapon that lunges
  const out = [], edge = lunges(tags, shape);
  for (const t of FLARES.order) { if (t === "melee" && !edge) continue; const look = t === "melee" ? "blade" : t; if ((tags || []).includes(t) && !out.includes(look)) out.push(look); }
  return out.length ? out : [FLARES.classLook[shape] || "ballistic"];
}
function flareLasts(look) { const b = FLARES.beats[look] || FLARES.beats.ballistic; return b.up + b.hold + b.down; }
function flareStrength(look, t) {   // MuzzleFlare.strength
  const b = FLARES.beats[look] || FLARES.beats.ballistic;
  if (t < 0 || t >= b.up + b.hold + b.down) return 0;
  let k = 1;
  if (t < b.up) { const f = t / b.up; k = 1 - (1 - f) * (1 - f); }
  else if (t >= b.up + b.hold) { const g = (t - b.up - b.hold) / b.down; k = 1 - g * g * (3 - 2 * g); }
  if (b.flicker > 0) { const w = Math.sin(2 * Math.PI * b.flicker * t); k *= look === "arc" ? (w >= 0 ? 1 : 0.25) : 0.7 + 0.3 * w; }
  return k;
}
const FLARE_VERT = `uniform float ahead; varying vec2 vUv;
void main() { vUv = uv; vec4 c = modelViewMatrix * vec4(0.0, 0.0, 0.0, 1.0); float s = length(modelViewMatrix[0].xyz);
  c.xyz += mix(normalize(-c.xyz), vec3(0.0, 0.0, 1.0), projectionMatrix[3][3]) * ahead * s; gl_Position = projectionMatrix * (c + vec4(position.xy * s, 0.0, 0.0)); }`;
const FLARE_FRAG = `uniform vec3 colour; uniform float strength; uniform float rays; uniform float spin; uniform float core; varying vec2 vUv;
void main() { vec2 p = vUv * 2.0 - 1.0; float r = length(p); float bloom = 1.0 - smoothstep(0.15, 0.6, r); float star;
  if (rays > 0.5) { float a = atan(p.y, p.x) + spin; star = pow(abs(cos(a * rays * 0.5)), rays < 2.5 ? 16.0 : 6.0) * (1.0 - smoothstep(0.2, 1.0, r)); }
  else star = 0.7 * (1.0 - smoothstep(0.4, 1.0, r));
  gl_FragColor = vec4(mix(colour, vec3(1.0), core * (1.0 - smoothstep(0.0, 0.4, r))), clamp(bloom + star, 0.0, 1.0) * strength); }`;
// A booster's plume along its thrust (MechView3D.setup_plumes, plume.gdshader; Ryan, 31 October, of the
// Stingray's exhaust: "can it be directional?"): a flame out of its plume node's mouth down the node's
// -z, turned about that line to face the eye, stretching and brightening with its booster's light, in
// place of that booster's halo; a trial, the Plume button turning it off to compare with the ring.
const PLUME_VERT = `uniform float strength; uniform float reach; uniform float breadth; varying vec2 vUv;
void main() { vUv = uv; vec4 origin = modelViewMatrix * vec4(0.0, 0.0, 0.0, 1.0);
  vec3 axis = normalize((modelViewMatrix * vec4(0.0, 0.0, -1.0, 0.0)).xyz); float s = length(modelViewMatrix[2].xyz);
  vec3 toEye = mix(normalize(-origin.xyz), vec3(0.0, 0.0, 1.0), projectionMatrix[3][3]);
  vec3 side = cross(axis, toEye); side = length(side) > 0.001 ? normalize(side) : vec3(1.0, 0.0, 0.0);
  float along = uv.y; float halfW = 0.5 * breadth * s * (1.0 - 0.6 * along); float stretch = 0.4 + 0.6 * clamp(strength, 0.0, 1.0);
  vec3 p = origin.xyz + axis * (along * reach * stretch * s) + side * ((uv.x * 2.0 - 1.0) * halfW);
  gl_Position = projectionMatrix * vec4(p, 1.0); }`;
const PLUME_FRAG = `uniform float strength; uniform float ceiling; varying vec2 vUv;
void main() { float across = 1.0 - abs(vUv.x * 2.0 - 1.0); float along = 1.0 - vUv.y;
  vec3 c = mix(vec3(0.8, 0.08, 0.02), vec3(1.0, 0.42, 0.1), smoothstep(0.05, 0.55, across)); c = mix(c, vec3(1.0, 0.9, 0.7), smoothstep(0.55, 0.95, across * along));
  gl_FragColor = vec4(c, clamp(strength * pow(across, 0.9) * pow(along, 1.2) * 1.6, 0.0, 1.0) * ceiling); }`;
function plumeK(light, rest) { return rest > 0 ? clamp((light / rest - 1) / 7, 0, 1) : 0; }   // gone at rest (Ryan, 3 November: "It needs to dissapear when idle"); the page's light is not eased: eight rests over its own is full
const RECOIL_BODY = 1.2;   // MechRig: model units a machine kicks back along a gun's line when it fires from a mount on the body
const AIM_UP = 0.22, AIM_DOWN = 0.5;   // MechRig.aim: the turn onto a target, the blow waiting on it (Ryan, 2 November: "make sure that the turns or aims happen before the sound effects")
const AIM_HOLD = 0.35;   // SkirmishScreen: a machine that turned to fire holds its aim this long past its firing slice (Ryan, 3 November: the Buzzard's cannon "turns back before the hit is complete")
// A blow on the hull (MechRig.jolt, MechView3D.hit; the to-do's hit reaction, on Ryan's go of 3
// November): the machine shoved back a share of its longest side, its nose rocking up, its hull
// laid over in heat's red-orange for a beat (the game lays an overlay; the page tints the materials);
// a machine lost guttering its lit parts out (MechRig.kill).
const JOLT = {share: 0.045, pitch: 6, up: 0.05, down: 0.34};
const HIT = {peak: 0.8, up: 0.04, hold: 0.08, down: 0.3, colour: [1.0, 0.25, 0.0]};
const GUTTER = 0.9;
// And then a lost machine slumps (MechRig._collapse_wants; Ryan, 3 November: "they should slump or
// collapse after, limbs dropping, flyers and hovers landing, fans stopping, idle spins stopping"; the
// second notes the same day: its feet planted, sinking on its knees and ankles, a biped slumping only
// at the waist, an arm going slack at the elbow, nothing through the floor).
const COLLAPSE = {at: 0.3, heft: 0.3, sink: 0.28, waist: 16, passes: 2, touch: 0.02, spinStop: 1.4, land: 1.1};
const COLLAPSE_SKIP = ["hip", "knee", "ankle", "toe", "foot", "coxa", "wheel", "steer", "caster", "tread", "rotor", "fan", "drum", "louvre",
  "shutter", "vent", "valve", "run", "salvo", "top_mouth", "top_lamp", "cell", "recoil", "capacitor", "rudder", "waist", "yaw", "turret", "sensor", "eye"];
function hitK(t) { if (t < 0 || t >= HIT.up + HIT.hold + HIT.down) return 0; if (t < HIT.up) return t / HIT.up; if (t < HIT.up + HIT.hold) return 1; const g = (t - HIT.up - HIT.hold) / HIT.down; return (1 - g) * (1 - g); }
function gutterK(t) { if (t >= GUTTER) return 0; const f = t / GUTTER; return (1 - f) * (1 - f) * ((t % 0.13) < 0.05 ? 0.35 : 1); }
// A lit material's light at rest, kept the first time it is asked (MechRig._rest_of), so a standing
// glow that raises it is never taken for its rest.
function restOf(m) { if (m.userData.restLight === undefined) m.userData.restLight = m.emissiveIntensity; return m.userData.restLight; }
// A mesh's halo shell (MechRig._halo_mesh): its own triangles and UVs, each corner's normal the sum
// of the faces meeting there, so the shell grows out closed round a flat-shaded part; at an edge
// one triangle alone uses, the corner leans outward in the face's own plane too, so a flat disc's
// shell spreads round its rim. Once a geometry.
function haloGeometry(geo) {
  if (geo.userData.halo) return geo.userData.halo;
  const T = window.THREE, pos = geo.attributes.position, nor = geo.attributes.normal, sums = new Map();
  const key = i => Math.round(pos.getX(i) * 64) + "," + Math.round(pos.getY(i) * 64) + "," + Math.round(pos.getZ(i) * 64);
  for (let i = 0; i < pos.count; i++) { const k = key(i), s = sums.get(k) || [0, 0, 0]; s[0] += nor.getX(i); s[1] += nor.getY(i); s[2] += nor.getZ(i); sums.set(k, s); }
  const idx = geo.index ? geo.index.array : null, corners = idx ? idx.length : pos.count, edges = new Map(), v = i => [pos.getX(i), pos.getY(i), pos.getZ(i)];
  const sub = (a, b) => [a[0] - b[0], a[1] - b[1], a[2] - b[2]], cross = (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
  const dot = (a, b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2], unit = a => { const l = Math.hypot(a[0], a[1], a[2]) || 1; return [a[0] / l, a[1] / l, a[2] / l]; };
  for (let f = 0; f + 2 < corners; f += 3) {
    const ix = [0, 1, 2].map(c => idx ? idx[f + c] : f + c), p = ix.map(v);
    const fn = cross(sub(p[1], p[0]), sub(p[2], p[0]));
    if (dot(fn, fn) < 1e-12) continue;
    const n = unit(fn);
    for (let e = 0; e < 3; e++) {
      const a = key(ix[e]), b = key(ix[(e + 1) % 3]), ek = a < b ? a + "|" + b : b + "|" + a;
      if (edges.has(ek)) { edges.get(ek)[0]++; continue; }
      let out = unit(cross(sub(p[(e + 1) % 3], p[e]), n));
      if (dot(out, sub(p[(e + 2) % 3], p[e])) > 0) out = out.map(x => -x);
      edges.set(ek, [1, out, a, b]);
    }
  }
  const rims = new Map();
  for (const [uses, out, a, b] of edges.values()) if (uses === 1) for (const k of [a, b]) { const r = rims.get(k) || [0, 0, 0]; rims.set(k, [r[0] + out[0], r[1] + out[1], r[2] + out[2]]); }
  const out = new Float32Array(pos.count * 3);
  for (let i = 0; i < pos.count; i++) {
    let n = unit(sums.get(key(i)));
    const r = rims.get(key(i));
    if (r && Math.hypot(r[0], r[1], r[2]) > 1e-4) { const u = unit(r); n = unit([n[0] + u[0], n[1] + u[1], n[2] + u[2]]); }
    out[i * 3] = n[0]; out[i * 3 + 1] = n[1]; out[i * 3 + 2] = n[2];
  }
  const g = new T.BufferGeometry();
  g.setAttribute("position", pos); g.setAttribute("normal", new T.BufferAttribute(out, 3));
  if (geo.attributes.uv) g.setAttribute("uv", geo.attributes.uv);
  if (geo.index) g.setIndex(geo.index);
  return geo.userData.halo = g;
}
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

let PLUMES_ON = true;   // the plume trial on (RIFTGATE_PLUME's page twin); the Plume button turns it off to compare with the ring
class Rig {
  constructor(root, side, rngSeed = 1) {
    this.plumesOff = !PLUMES_ON;
    this.model = root; this.body = root; this.standing = new Map(); this.halos = new Map(); this.flashes = []; this.haloGrow = 0; this.flares = []; this.aimAt = null;
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
      this.meta[name] = {axis: m.axis || axisFor(name), limits: m.limits || {}, swing: m.swing ?? name.startsWith("shoulder"), parent: m.parent || "",
        slide: Array.isArray(m.slide) && m.slide.length === 3 ? m.slide : null};   // a joint that only runs along its line (a gun in a port): that line
    }
    this.acts = (side.acts || []).filter(a => a && a.name);
    this.move = side.move || {};
    this.heft = this.move.heft ?? HEFT_DEFAULT;
    this.gaitOptions = side.gait_options || {};   // other ways it could move, to judge beside it (b.gait_option); the game moves by the gait alone
    this.spinners = {}; this.spun = {};   // joints turned without end (MechRig.spinners, b.spin: the Stingray's fans)
    for (const [name, r] of Object.entries(side.spin || {})) if (this.joints[name] && Array.isArray(r) && r.length >= 2) { this.spinners[name] = [Number(r[0]), Number(r[1])]; this.spun[name] = 0; }
    this.spinSteps = {}; this.locked = {};   // a spinner an act may lock, parked on its step (MechRig.spin_steps, _locked: the Cottonmouth's drum)
    for (const [name, step] of Object.entries(side.spin_step || {})) if (this.spinners[name] && Number(step) > 0) this.spinSteps[name] = Number(step);
    this.heldSpins = {}; this.heldOn = {}; this.heldSpeed = {};   // a status's spin (MechRig.held_spins, b.spin_held: the Cassowary's capacitor while Spun Up)
    for (const [status, js] of Object.entries(side.spin_held || {})) {
      const turned = {};
      for (const [jn, v] of Object.entries(js || {})) if (this.joints[jn]) { turned[jn] = Number(v); this.spun[jn] = this.spun[jn] || 0; this.heldSpeed[jn] = 0; }
      if (Object.keys(turned).length) { this.heldSpins[status] = turned; this.heldOn[status] = false; }
    }
    this.useGait(side.gait || {});
    this.fires = side.fires || {}; this.until = -1;   // a fixed weapon's firing slice (MechRig.fire_act), and where one playing now ends
    this.hiddenFire = side.hidden_fire || null;   // the slice a weapon on a hidden mount fires with (MechRig.fire_hidden: the Cottonmouth's drum)
    this.fireTurn = {}; this.collapse = -1; this.spinK = 1; this.airborne = false; this.collapseFloor = 0;   // each weapon's slices taking turns (MechRig.fire_slice); a lost machine's slump and its spins running down
    this.aims = side.aims || {}; this.pivots = !!side.pivots;   // a fixed weapon's aim joint; the whole machine turning on the spot (tracks, casters)
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
    for (const part of ((this.gait.glow || {}).parts || [])) for (const m of this.litMaterials(part)) this.moveGlow.push([m, restOf(m)]);
    this.setupForms(side.forms || {});
    this.setupCounts(side.counts || []);
    this.setupHalos(side);
    this.setupStanding(side);
    this.setupPlumes(side);
  }
  // Each booster's plume (MechView3D.setup_plumes): a flame at its plume node, lit with its part.
  setupPlumes(side) {
    const T = window.THREE;
    this.plumes = [];
    if (this.plumesOff) return;
    for (const pl of side.plumes || []) {
      const node = this.model.getObjectByName(pl.node), lit = this.litMaterials(pl.part);
      if (!node || !lit.length) continue;
      const mat = new T.ShaderMaterial({uniforms: {strength: {value: 0.3}, reach: {value: +pl.reach || 20}, breadth: {value: +pl.breadth || 8}, ceiling: {value: 0.9}},
        vertexShader: PLUME_VERT, fragmentShader: PLUME_FRAG, transparent: true, depthWrite: false, side: T.DoubleSide});
      const mesh = new T.Mesh(new T.PlaneGeometry(1, 1), mat);
      mesh.userData.halo = true; mesh.frustumCulled = false; mesh.renderOrder = 2;
      node.add(mesh);
      this.plumes.push([mat, lit[0], restOf(lit[0])]);
    }
  }
  stepPlumes() { for (const [mat, m, rest] of this.plumes || []) mat.uniforms.strength.value = plumeK(m.emissiveIntensity, rest); }
  // A lit material's light (MechRig._light_to): its rest times the multiple, and its halos with it,
  // their light eased as the game eases it (the page's own light eases in PHONE_GLOW).
  lightTo(m, base, k) {
    k = Math.max(k, this.standing.get(m) || 1);
    m.emissiveIntensity = base * Math.max(0, k);
    for (const h of this.halos.get(m) || []) {
      h.uniforms.light.value = Math.pow(m.emissiveIntensity, 1 / 2.2);
      h.uniforms.presence.value = clamp((k - 1) / HALO_FULL, 0, 1);
    }
  }
  // The halos (MechRig._setup_halos): round each lit surface of the hot parts a sidecar names
  // (`halo`), a soft shell standing out a share of the machine's size, a part named with a scale
  // ([part, 2]) that much larger and stronger.
  setupHalos(side) {
    this.halos = new Map();
    this.haloGrow = HALO_SPREAD * this.modelSize();
    const named = Array.isArray(side.halo) ? side.halo : [];
    const plumed = this.plumesOff ? [] : (side.plumes || []).map(pl => pl.part);   // a booster burning as a plume wears no ring (MechRig.halo_skip)
    for (const entry of named) {
      // A part, [part, scale] or [part, scale, ahead] (MechRig._setup_halos).
      const p = Array.isArray(entry) ? entry[0] : entry, scale = Array.isArray(entry) && entry.length > 1 ? +entry[1] : 1;
      if (plumed.includes(p)) continue;
      const ahead = Array.isArray(entry) && entry.length > 2 ? +entry[2] : HALO_AHEAD;
      const tag = parseTag(p);
      if (tag.length === 2) { const root = tag[0] === "joint" ? this.joints[tag[1]] : this.hardpoints[tag[1]]; if (root) this.wearHalo(root, scale, ahead); }
      else this.model.traverse(n => { if (n.isMesh && !n.userData.halo && labelled(n.name, p)) this.wearHalo(n, scale, ahead); });
    }
  }
  // A halo round each lit surface under a node (MechRig._halo_under); a hot part hung later, a burn
  // weapon's fire over its class, wears one too (MechRig.wear_hot).
  wearHalo(node, scale = 1, ahead = HALO_AHEAD) {
    const T = window.THREE, grow = this.haloGrow;
    node.traverse(n => {
      if (!n.isMesh || n.userData.halo || n.userData.haloWorn) return;
      n.userData.haloWorn = true;
      for (const m of [].concat(n.material)) {
        if (!m.userData.lit) continue;
        const mat = new T.ShaderMaterial({uniforms: {tile: {value: m.map}, light: {value: Math.pow(m.emissiveIntensity, 1 / 2.2)}, presence: {value: 0}, grow: {value: grow * scale}, ahead: {value: ahead}, reach: {value: Math.min(1, HALO_REACH * scale)}},
          vertexShader: HALO_VERT, fragmentShader: HALO_FRAG, transparent: true, depthWrite: false, blending: T.AdditiveBlending});
        const h = new T.Mesh(haloGeometry(n.geometry), mat);
        h.userData.halo = true; h.renderOrder = 1;
        n.add(h);
        if (!this.halos.has(m)) this.halos.set(m, []);
        this.halos.get(m).push(mat);
      }
    });
  }
  // Flare the lit parts under a node as a weapon fires (MechRig.flash_under): FLASH rests over their
  // own at the top, held, then easing back.
  flashUnder(node) {
    const mats = [];
    node.traverse(n => { if (n.isMesh && !n.userData.halo) for (const m of [].concat(n.material)) if (m.userData.lit && !mats.includes(m)) mats.push(m); });
    if (mats.length) this.flashes.push({mats, base: mats.map(restOf), t: 0});
  }
  stepFlashes(dt) {
    if (!this.flashes.length) return false;
    const end = FLASH.up + FLASH.hold + FLASH.down;
    for (const f of this.flashes) {
      f.t += dt;
      const k = f.t >= end ? 0 : flashK(f.t);
      f.mats.forEach((m, i) => this.lightTo(m, f.base[i], 1 + k));
    }
    this.flashes = this.flashes.filter(f => f.t < end);
    return true;
  }
  // The glows a sidecar holds always (MechRig._setup_standing): a lit part never falls under so
  // many rests over its own, an act's flare rising past it.
  setupStanding(side) {
    this.standing = new Map();
    for (const [part, k] of Object.entries(side.standing || {})) for (const m of this.litMaterials(part)) {
      const rest = restOf(m);
      this.standing.set(m, 1 + k);
      this.lightTo(m, rest, 1);
    }
  }
  // The longest side of the model's bounds at rest, in its own units (MechRig._model_size).
  modelSize() {
    const T = window.THREE, box = new T.Box3(), inv = new T.Matrix4();
    this.model.updateMatrixWorld(true); inv.copy(this.model.matrixWorld).invert();
    this.model.traverse(n => {
      if (!n.isMesh || !n.geometry || n.userData.halo) return;
      if (!n.geometry.boundingBox) n.geometry.computeBoundingBox();
      box.union(n.geometry.boundingBox.clone().applyMatrix4(new T.Matrix4().multiplyMatrices(inv, n.matrixWorld)));
    });
    const s = box.getSize(new T.Vector3());
    return Math.max(s.x, s.y, s.z);
  }
  // The forms a sidecar names (MechRig._setup_forms): poses held while the machine carries the
  // status of the same name (the Polar Bear's seal), their tracks and body as curves over their
  // turn, their lit parts with the light each has at rest, and the acts each plays while held.
  setupForms(fs) {
    this.forms = {}; this.formOn = {}; this.formT = {}; this.formRot = {}; this.formSlide = {};
    this.formBodyRot = v3(); this.formBodySlide = v3();
    for (const [name, f] of Object.entries(fs || {})) {
      const duration = Math.max(0.01, f.duration ?? 0.6), curves = {}, glow = [];
      for (const [jn, keys] of Object.entries(f.tracks || {})) if (this.joints[jn]) curves[jn] = curve(keys, duration, "smooth");
      if ((f.body || []).length) curves["@body"] = curve(f.body, duration, "smooth");
      for (const g of f.glow || []) for (const part of g.parts || []) for (const m of this.litMaterials(part)) glow.push([m, restOf(m), g.k ?? -1]);
      this.forms[name] = {duration, curves, glow, acts: (f.acts || []).filter(a => a && a.name)};
      this.formOn[name] = false; this.formT[name] = 0;
    }
  }
  // Hold a form or let it go (MechRig.set_form): it turns in over its duration and back out the
  // same way, from wherever it is; while a form turns no act starts, and one playing stops.
  setForm(name, on) {
    if (!this.forms[name] || this.formOn[name] === on) return;
    this.formOn[name] = on;
    if (this.current) this.endAct();
  }
  formHeld(name) { return !!this.formOn[name]; }
  // A status's spin held or let go (MechRig.hold_spin); true when it changes.
  holdSpin(status, on) { if (!this.heldSpins[status] || this.heldOn[status] === on) return false; this.heldOn[status] = on; return true; }
  spinHeld(status) { return !!this.heldOn[status]; }
  // MechRig._spins_held_step: each held spin's joints ease toward what their held statuses ask, and turn.
  spinsHeldStep(delta) {
    let turning = false;
    for (const jn of Object.keys(this.heldSpeed)) {
      let want = 0;
      for (const [status, js] of Object.entries(this.heldSpins)) if (this.heldOn[status] && jn in js) want += js[jn];
      let v = want + (this.heldSpeed[jn] - want) * Math.exp(-delta / SPIN_HELD_EASE);
      if (Math.abs(v - want) < 3) v = want;   // the exponential's tail, a creep, cut off (MechRig)
      this.heldSpeed[jn] = v;
      if (v !== 0 && this.spinK > 0) { this.spun[jn] = ((((this.spun[jn] || 0) + v * delta * this.spinK) % 360) + 360) % 360; turning = true; }
    }
    return turning;
  }
  // The count displays (MechRig._setup_counts): each part's lit materials and its light at rest, every part dark.
  setupCounts(cs) {
    this.countDisplays = []; this.countDebugT = 0;
    for (const c of Array.isArray(cs) ? cs : []) {
      if (!c || !Array.isArray(c.parts) || !c.parts.length) continue;
      const off = c.off ?? -0.85;
      this.countDisplays.push({source: c.source || "", parts: c.parts.map(p => this.litMaterials(p).map(m => [m, m.emissiveIntensity])),
        on: c.on ?? 1.5, off, flare: c.flare ?? 0, n: -1, k: c.parts.map(() => off)});
    }
    this.lightCounts();
  }
  // MechRig.show_counts: the first n parts lit, the rest dark; a number that falls flares them all and lets them go dark.
  showCounts(values) {
    let changed = false;
    for (const d of this.countDisplays) {
      if (!(d.source in values)) continue;
      const size = d.parts.length, n = clamp(Math.round(values[d.source]), 0, size), was = d.n;
      if (n === was) continue;
      if (was < 0) d.k = d.k.map((_, i) => i < n ? d.on : d.off);
      else if (n < was && d.flare > 0) d.k = d.k.map(() => d.flare);
      d.n = n; changed = true;
    }
    if (changed) this.lightCounts();
    return changed;
  }
  // MechRig._counts_step: each part chases its light, quick to light and slower to fade.
  countsStep(delta) {
    let moving = false;
    for (const d of this.countDisplays) {
      const n = Math.max(0, d.n);
      d.k = d.k.map((k, i) => {
        const want = i < n ? d.on : d.off;
        if (k === want) return k;
        moving = true;
        const nk = want + (k - want) * Math.exp(-delta / (want > k ? COUNT_RISE : COUNT_FALL));
        return Math.abs(nk - want) < 0.05 ? want : nk;   // the fade's tail, past seeing, cut off (MechRig)
      });
    }
    if (moving) this.lightCounts();
    return moving;
  }
  lightCounts() { for (const d of this.countDisplays || []) d.parts.forEach((mats, i) => { for (const [m, base] of mats) m.emissiveIntensity = base * Math.max(0, 1 + d.k[i]); }); }
  static keysAny(a, held) { return Object.keys(a.tracks || {}).some(jn => held[jn]); }
  // The acts it may play now (MechRig.act_set): none while a form turns; a form held all the way
  // in plays its own when it has any (the sealed Polar Bear's, from its hunkered pose); else its
  // own, less any that moves a joint a held form keeps.
  actSet() {
    const held = {};
    for (const [name, f] of Object.entries(this.forms)) {
      const on = this.formOn[name], t = this.formT[name];
      if ((on && t < f.duration) || (!on && t > 0)) return [];
      if (on) {
        if (f.acts.length) return f.acts;
        for (const jn of Object.keys(f.curves)) held[jn] = true;
      }
    }
    return Object.keys(held).length ? this.acts.filter(a => !Rig.keysAny(a, held)) : this.acts;
  }
  // Turn every form toward held or let go (MechRig._forms_step), and what they add to each joint
  // and to their lit parts' light; true while one is turning.
  formsStep(delta) {
    let turning = false;
    for (const [name, f] of Object.entries(this.forms)) {
      const want = this.formOn[name] ? f.duration : 0, t = this.formT[name];
      if (t !== want) { this.formT[name] = t < want ? Math.min(want, t + delta) : Math.max(want, t - delta); turning = true; }
    }
    if (!turning) return false;
    this.formRot = {}; this.formSlide = {}; this.formBodyRot = v3(); this.formBodySlide = v3();
    let settled = true;
    for (const [name, f] of Object.entries(this.forms)) {
      const t = this.formT[name];
      if (t !== (this.formOn[name] ? f.duration : 0)) settled = false;
      for (const [jn, c] of Object.entries(f.curves)) {
        const v = curveAt(c, t);
        if (jn === "@body") {
          this.formBodySlide = add3(this.formBodySlide, v3(v[0], v[1], v[2]));
          if (v.length >= 6) this.formBodyRot = add3(this.formBodyRot, v3(v[4], v[3], v[5]));   // authored (yaw, pitch, roll)
          continue;
        }
        this.formRot[jn] = add3(this.formRot[jn] || v3(), v3(v[0], v[1], v[2]));
        if (v.length >= 6) this.formSlide[jn] = add3(this.formSlide[jn] || v3(), v3(v[3], v[4], v[5]));
      }
      const k = t / f.duration;
      for (const [m, base, gk] of f.glow) this.lightTo(m, base, 1 + gk * k);
    }
    if (settled) this.wait = this.debug ? GAP_DEBUG : lerp(GAP_MIN, GAP_MAX, this.random());   // a pause before the new set's first act
    return true;
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
  alive() { return this.acts.length > 0 || Object.keys(this.forms).length > 0 || this.strikes.length > 0 || this.flares.length > 0 || !!this.aimAt || !!this.current || Object.keys(this.servo).length > 0 || Object.keys(this.spinners).length > 0
    || Object.keys(this.heldSpins).length > 0 || this.countDisplays.length > 0; }
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
    const here = this.actSet().filter(a => a.idle !== false);   // a weapon's firing alone never plays at rest (MechRig.choose)
    if (!here.length) return null;
    if (this.debug && this.debug !== "1") { const a = here.find(x => x.name === this.debug); if (a) return a; }
    if (here.length === 1) return here[0];
    const pool = here.filter(a => a.name !== this.lastAct);
    return pool[Math.floor(this.random() * pool.length) % pool.length];
  }
  // A named act now, among those it may play first, then its own and its forms'.
  play(name) {
    const every = [...this.actSet(), ...this.acts, ...Object.values(this.forms).flatMap(f => f.acts)];
    const a = every.find(x => x.name === name);
    if (!a) return false;
    this.endAct(true); this.start(a); this.evaluateAct(); this.pose(); return true;
  }
  // MechRig._lock_spins: park every spinner the act locks on its next step ahead, the way it turns.
  lockSpins(a) {
    for (const name of a.locks || []) {
      if (!this.spinners[name] || !this.spinSteps[name]) continue;
      const step = this.spinSteps[name], from = this.spun[name], r = this.spinners[name];
      const ahead = r[0] + (r[1] - r[0]) * this.blend >= 0;
      this.locked[name] = [from, (ahead ? Math.ceil(from / step - 0.0001) : Math.floor(from / step + 0.0001)) * step, 0];
    }
  }
  // MechRig._unlock_spins: the act's own turn on a locked spinner goes into its turn, so it never
  // unwinds, and its idle turn takes up again from where it stands.
  unlockSpins() {
    for (const name of Object.keys(this.locked)) {
      const k = ["x", "y", "z"][AXES.indexOf(this.meta[name].axis)];
      let turned = this.spun[name];
      const st = this.servo[name];
      if (st) { turned += st[0][k]; st[0] = {...st[0], [k]: 0}; st[1] = {...st[1], [k]: 0}; }
      if (this.actRot[name]) this.actRot[name] = {...this.actRot[name], [k]: 0};
      this.spun[name] = fposmod(turned, 360);
    }
    this.locked = {};
  }
  start(a) {
    this.unlockSpins();
    this.current = a; this.t = 0; this.lastAct = a.name; this.glow = []; this.until = -1;
    this.lockSpins(a);
    this.actHeft = a.heft ?? this.heft;   // an act may ask for its own heft (MechRig._act_heft): a blow sharper than the machine's weight
    const d = a.duration || 0, ease = a.ease || "smooth";
    this.curves = {};
    for (const [name, keys] of Object.entries(a.tracks || {})) if (this.joints[name]) this.curves[name] = curve(keys, d, ease);
    if ((a.body || []).length) this.curves["@body"] = curve(a.body, d, ease);
    for (const g of (a.glow || [])) {
      const mats = []; for (const p of g.parts || []) mats.push(...this.litMaterials(p));
      this.glow.push({curve: curve(g.keys || [], d, ease), mats, base: mats.map(restOf)});
    }
  }
  restoreGlow() { for (const g of this.glow) g.mats.forEach((m, i) => { this.lightTo(m, g.base[i], 1); }); this.glow = []; }
  // The act is over (MechRig._end_act): its asks go to nothing and the servos bring every part home.
  endAct(quiet) {
    this.unlockSpins();
    const wrap = (a) => fposmod(a + 180, 360) - 180;   // the short way round: a loop or a spin ends a whole turn on and never unwinds
    for (const st of Object.values(this.servo)) st[0] = v3(wrap(st[0].x), wrap(st[0].y), wrap(st[0].z));
    this.restoreGlow();
    this.current = null; this.curves = {}; this.wantRot = {}; this.wantSlide = {}; this.bodyWantRot = v3(); this.bodyWantSlide = v3(); this.until = -1;
    this.wait = this.debug ? GAP_DEBUG : lerp(GAP_MIN, GAP_MAX, this.random());
    if (!quiet) this.pose();
  }
  // A fixed weapon fires with its own act (MechRig.fire_act): the slice the sidecar names, from `lead`
  // before its start, snappier than an idle act; false when it has none or a held form keeps its joints.
  fireSlice(cid) {   // MechRig.fire_slice: one slice, or several taking turns
    const f = this.fires[cid], all = Array.isArray(f) ? f : (f ? [f] : []);
    return all.length ? all[(this.fireTurn[cid] || 0) % all.length] : null;
  }
  fireSpan(cid) { const f = this.fireSlice(cid); return f ? Math.max(0, f.to - f.from) : 0; }   // MechRig.fire_span: how long the next slice plays
  fireAct(cid, lead = 0) {
    const f = this.fireSlice(cid);
    if (!f || !this.playSlice(f, lead)) return false;
    this.fireTurn[cid] = (this.fireTurn[cid] || 0) + 1;
    return true;
  }
  // A weapon on a hidden mount fires as the model's one slice for them (MechRig.fire_hidden, 16
  // November: the Cottonmouth's drum turning two chambers on); false with none.
  fireHidden(lead = 0) { return !!this.hiddenFire && this.playSlice(this.hiddenFire, lead); }
  hiddenSpan() { const f = this.hiddenFire; return f ? Math.max(0, f.to - f.from) : 0; }   // MechRig.hidden_span
  playSlice(f, lead) {   // MechRig._play_slice: the act cut to its slice, snappier than an idle act
    const act = this.actSet().find(a => a.name === f.act);
    if (!act) return false;
    if (this.current) this.endAct(true);
    this.start(act);
    this.t = Math.max(0, f.from - lead); this.until = f.to;
    this.actHeft = Math.min(this.actHeft, 0.1);
    this.evaluateAct(); this.pose();
    return true;
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
      g.mats.forEach((m, i) => { this.lightTo(m, g.base[i], k); });
    }
  }
  // The servos (MechRig._follow): each part a mass on a damped spring chasing what the act asks,
  // the machine's heft its time constant; a part home and still drops out.
  follow(dt) {
    const w = 1 / Math.max(0.02, this.dead ? COLLAPSE.heft : (this.current ? (this.actHeft ?? this.heft) : this.heft)), len = (a) => Math.hypot(a.x, a.y, a.z);
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
    for (const [name, lk] of Object.entries(this.locked)) { lk[2] = PARK_TIME; this.spun[name] = lk[1]; }   // a scrubbed act stands parked
    let left = clamp(t, 0, a.duration || 0);
    while (left > 1e-9) { const dt = Math.min(left, STEP); left -= dt; this.t += dt; this.evaluateAct(); this.follow(dt); }
    this.pose();
  }
  // Advance (MechRig.tick): in steps no longer than STEP, so a slow frame lands where frames would.
  // A blow on the hull (MechRig.jolt): `away` in the body's own axes, shoved back a share of the
  // machine's longest side, the nose rocking up, settling back; `k` scales it (the armour's block at half).
  jolt(away, k = 1) {
    const T = window.THREE, size = this.size || (this.size = this.modelSize());
    const a = new T.Vector3(away.x, away.y, away.z).normalize().applyQuaternion(this.body.quaternion).multiply(this.body.scale).multiplyScalar(JOLT.share * size * k);
    this.strikes.push({joint: "@body", vec: v3(JOLT.pitch * k, 0, 0), recoil: {x: a.x, y: a.y, z: a.z}, up: JOLT.up, down: JOLT.down, t: 0});
    this.pose();
  }
  // The machine lost (MechRig.kill): its act stops, none starts, every lit part gutters out.
  kill() {
    if (this.dead) return;
    this.dead = true;
    if (this.current) this.endAct(true);
    this.flashes = [];
    const mats = [];
    this.model.traverse(n => { if (n.isMesh && !n.userData.halo) for (const m of [].concat(n.material)) if (m.userData.lit && !mats.includes(m)) mats.push(m); });
    this.gutter = {t: 0, mats: mats.map(m => [m, m.emissiveIntensity])};
    this.collapse = 0;
  }
  revive() {
    if (!this.dead) return;
    this.dead = false;
    for (const [m] of (this.gutter || {mats: []}).mats) this.lightTo(m, restOf(m), 1);
    this.gutter = null;
    this.collapse = -1; this.collapseFloor = 0; this.spinK = 1; this.wantRot = {}; this.bodyWantRot = v3(); this.bodyWantSlide = v3();
  }
  // The slump's clock (MechRig._step): the spins run down, and once the lights are going the
  // limbs fall; true while anything moves.
  stepCollapse(dt) {
    if (!this.dead) return false;
    let moving = false;
    if (this.spinK > 0) { this.spinK = Math.max(0, this.spinK - dt / COLLAPSE.spinStop); moving = true; }
    if (this.collapse >= 0 && this.collapse < COLLAPSE.at) {
      this.collapse += dt;
      if (this.collapse >= COLLAPSE.at) this.collapseWants();
      moving = true;
    }
    return moving;
  }
  // MechRig._collapse_wants: worked from the pose at rest (a held form's with it). A walker sinks on the
  // limbs it stands on, its feet planted; a biped slumps forward at the waist; every other loose joint
  // hangs what it carries where its weight takes it, the outermost first, within its limits and above
  // the floor; nothing tips the body, and an airborne machine lands on what hangs lowest (collapseFloor).
  collapseWants() {
    if (!(this.size > 0)) this.size = this.modelSize();
    this.model.updateMatrixWorld(true);
    this.modelInv = this.model.matrixWorld.clone().invert();
    const held = {}, deg = {};
    for (const [name, j] of Object.entries(this.joints)) { held[name] = j.rotation.clone(); deg[name] = {...(this.formRot[name] || v3())}; this.turnTo(name, deg[name], false); }
    this.model.updateMatrixWorld(true);
    this.collapseFloor = this.airborne ? this.lowestUnder(this.model) : 0;
    let sink = 0, limbs = [];
    if (!this.airborne) {
      limbs = this.plantedLimbs(COLLAPSE.touch * Math.max(1, this.size));
      const [d, turns] = this.sinkTurns(limbs, deg);
      sink = d;
      for (const [name, t] of Object.entries(turns)) { deg[name] = add3(deg[name], t); this.turnTo(name, deg[name]); }
    }
    const planted = new Set(limbs.flat());
    const hands = limbs.some(t => !t[0].startsWith("hip"));
    if (limbs.length && !hands) for (const name of Object.keys(this.joints)) if (name.startsWith("waist")) { deg[name] = add3(deg[name], v3(-COLLAPSE.waist, 0, 0)); this.turnTo(name, deg[name]); }
    const floorY = this.collapseFloor + sink, slack = [], floorOf = {};
    for (const [name, j] of Object.entries(this.joints)) {
      if (this.spinners[name] || (this.spin && this.spin.has(name)) || planted.has(name) || COLLAPSE_SKIP.some(w => name.startsWith(w))) continue;
      const low = this.lowestUnder(j);
      if (low === Infinity) continue;
      floorOf[name] = Math.min(floorY, low);
      slack.push([this.jointDepth(j), name]);
    }
    slack.sort((a, b) => b[0] - a[0]);
    for (let pass = 0; pass < COLLAPSE.passes; pass++) for (const [, name] of slack) this.hang(name, deg, floorOf[name]);
    if (this.airborne) this.collapseFloor = this.lowestUnder(this.model);   // it lands on what hangs lowest once it has slumped
    for (const [name, j] of Object.entries(this.joints)) {
      const f = this.formRot[name] || v3(), want = v3(deg[name].x - f.x, deg[name].y - f.y, deg[name].z - f.z);
      if (Math.hypot(want.x, want.y, want.z) > 0.01) this.wantRot[name] = want;
      j.rotation.copy(held[name]);
    }
    this.model.updateMatrixWorld(true);
    this.bodyWantSlide = v3(0, 0, -sink);   // authored: x right, y forward, z up (MechRig.offset_of)
    this.bodyWantRot = v3();
  }
  turnTo(name, deg, update = true) { const r = this.rest[name], e = eulerOf(deg), j = this.joints[name]; j.rotation.set(r.x + e.x, r.y + e.y, r.z + e.z, "YXZ"); if (update) j.updateMatrixWorld(true); }
  inModel(node) { return new window.THREE.Matrix4().multiplyMatrices(this.modelInv, node.matrixWorld); }
  jointDepth(node) { let n = 0; const all = new Set(Object.values(this.joints)); for (let p = node.parent; p && p !== this.model; p = p.parent) if (all.has(p)) n++; return n; }
  // MechRig._lowest_under: the lowest point of the shown surfaces under a node, in the model's frame.
  lowestUnder(node) {
    const T = window.THREE, v = new T.Vector3(); let low = Infinity;
    const walk = (o) => {
      if (o.visible === false) return;
      if (o.isMesh && o.geometry && !o.userData.halo) {
        if (!o.geometry.boundingBox) o.geometry.computeBoundingBox();
        const bb = o.geometry.boundingBox, m = this.inModel(o);
        for (let k = 0; k < 8; k++) { v.set(k & 1 ? bb.max.x : bb.min.x, k & 2 ? bb.max.y : bb.min.y, k & 4 ? bb.max.z : bb.min.z).applyMatrix4(m); if (v.y < low) low = v.y; }
      }
      for (const c of o.children) walk(c);
    };
    walk(node);
    return low;
  }
  // MechRig._subtree_centre: the centroid of every shown vertex under a node, in the model's frame.
  subtreeCentre(node) {
    const T = window.THREE, sum = new T.Vector3(); let n = 0;
    const walk = (o) => {
      if (o.visible === false) return;
      if (o.isMesh && o.geometry && !o.userData.halo && o.geometry.attributes.position) {
        const g = o.geometry;
        if (!g.userData.centroid) {
          const p = g.attributes.position, c = new T.Vector3();
          for (let i = 0; i < p.count; i++) { c.x += p.getX(i); c.y += p.getY(i); c.z += p.getZ(i); }
          g.userData.centroid = [c.multiplyScalar(1 / Math.max(1, p.count)), p.count];
        }
        const [c, k] = g.userData.centroid;
        sum.add(c.clone().applyMatrix4(this.inModel(o)).multiplyScalar(k)); n += k;
      }
      for (const c of o.children) walk(c);
    };
    walk(node);
    return n ? sum.multiplyScalar(1 / n) : null;
  }
  // MechRig._planted_limbs: a leg's hip, knee and ankle, and an arm's shoulder, elbow and wrist (or hand)
  // when its end is on the floor; none unless it stands on a leg.
  plantedLimbs(touch) {
    const out = [];
    for (const name of Object.keys(this.joints)) {
      let trio = null;
      if (name.startsWith("knee")) { const s = name.slice(4); trio = ["hip" + s, name, "ankle" + s]; }
      else if (name.startsWith("elbow")) { const s = name.slice(5); trio = ["shoulder" + s, name, this.joints["wrist" + s] ? "wrist" + s : "hand" + s]; }
      if (!trio || !this.joints[trio[0]] || !this.joints[trio[2]]) continue;
      if (this.lowestUnder(this.joints[trio[2]]) > touch) continue;
      out.push(trio);
    }
    return out.some(t => t[0].startsWith("hip")) ? out : [];
  }
  // MechRig._sink_turns: the most of COLLAPSE.sink every planted limb reaches, its belly clear of the floor.
  sinkTurns(limbs, deg) {
    if (!limbs.length) return [0, {}];
    const T = window.THREE, at = (n) => new T.Vector3().setFromMatrixPosition(this.inModel(this.joints[n]));
    let span = Infinity;
    for (const t of limbs) span = Math.min(span, at(t[0]).y - at(t[2]).y);
    const want = COLLAPSE.sink * Math.max(0, span), floorY = Math.min(0, this.lowestUnder(this.model));
    let best = [0, {}], lo = 0, hi = want;
    for (let step = 0; step < 12; step++) {
      const d = step === 0 ? hi : (lo + hi) / 2, turns = {};
      let ok = d > 0;
      for (const t of limbs) { if (!ok) break; const r = this.sinkLimb(t, d, deg); if (!r) ok = false; else Object.assign(turns, r); }
      if (ok) {
        for (const [n, v] of Object.entries(turns)) this.turnTo(n, add3(deg[n], v));
        ok = this.lowestUnder(this.model) - d >= floorY - 0.05;
        for (const n of Object.keys(turns)) this.turnTo(n, deg[n]);
      }
      if (ok) { best = [d, turns]; if (step === 0) break; lo = d; } else hi = d;
    }
    return best;
  }
  // MechRig._sink_limb: a two-link reach in the plane the middle joint turns in, the end kept where it
  // stands and as it stands while the machine sinks `d`.
  sinkLimb(trio, d, deg) {
    const T = window.THREE, axle = (n) => new T.Vector3(1, 0, 0).applyMatrix4(new T.Matrix4().extractRotation(this.inModel(this.joints[n]))).normalize();
    const pos = (n) => new T.Vector3().setFromMatrixPosition(this.inModel(this.joints[n]));
    const u = axle(trio[1]), ur = axle(trio[0]), ue = axle(trio[2]);
    if (Math.abs(u.dot(ur)) < 0.95 || Math.abs(u.dot(ue)) < 0.95) return null;
    const a = new T.Vector3(0, 1, 0), b = new T.Vector3().crossVectors(u, a);
    if (b.length() < 0.5) return null;
    b.normalize();
    const h = pos(trio[0]), km = pos(trio[1]).sub(h), em = pos(trio[2]).sub(h);
    const k2 = [km.dot(a), km.dot(b)], e2 = [em.dot(a), em.dot(b)], t2 = [e2[0] + d, e2[1]];
    const l1 = Math.hypot(k2[0], k2[1]), l2 = Math.hypot(e2[0] - k2[0], e2[1] - k2[1]), reach = Math.hypot(t2[0], t2[1]);
    if (l1 < 0.001 || l2 < 0.001 || reach >= l1 + l2 - 0.001 || reach <= Math.abs(l1 - l2) + 0.001) return null;
    const shin0 = [e2[0] - k2[0], e2[1] - k2[1]], bend = Math.sign(k2[0] * shin0[1] - k2[1] * shin0[0]);
    const aim = Math.atan2(t2[1], t2[0]), spread = Math.acos(clamp((l1 * l1 + reach * reach - l2 * l2) / (2 * l1 * reach), -1, 1));
    const wrap = (x) => { while (x > Math.PI) x -= 2 * Math.PI; while (x < -Math.PI) x += 2 * Math.PI; return x; };
    for (const sg of [1, -1]) {
      const a1 = aim + sg * spread, k = [Math.cos(a1) * l1, Math.sin(a1) * l1], shin = [t2[0] - k[0], t2[1] - k[1]];
      if (bend !== 0 && Math.sign(k[0] * shin[1] - k[1] * shin[0]) !== bend) continue;
      const dRoot = wrap(a1 - Math.atan2(k2[1], k2[0]));
      const dMid = wrap((Math.atan2(shin[1], shin[0]) - a1) - (Math.atan2(shin0[1], shin0[0]) - Math.atan2(k2[1], k2[0])));
      const dEnd = -(dRoot + dMid);
      const out = {[trio[0]]: v3(dRoot / D2R * Math.sign(u.dot(ur)), 0, 0), [trio[1]]: v3(dMid / D2R, 0, 0), [trio[2]]: v3(dEnd / D2R * Math.sign(u.dot(ue)), 0, 0)};
      for (const [n, v] of Object.entries(out)) {
        const m = this.meta[n] || {};
        if ((m.axis || "pitch") !== "pitch") return null;
        const total = add3(deg[n], v), c = clampDegrees(total, m.limits);
        if (Math.hypot(c.x - total.x, c.y - total.y, c.z - total.z) > 0.5) return null;
      }
      return out;
    }
    return null;
  }
  // MechRig._hang: the turn about a slack joint's own axle that brings the middle of what it carries
  // under it, within its limits, eased back so what it carries keeps above `floorY`.
  hang(name, deg, floorY) {
    const T = window.THREE, j = this.joints[name], m = this.meta[name] || {}, axis = m.axis || axisFor(name), i = AXES.indexOf(axis);
    if (i < 0) return;
    const centre = this.subtreeCentre(j);
    if (!centre) return;
    const xj = this.inModel(j), o = new T.Vector3().setFromMatrixPosition(xj);
    const u = new T.Vector3(...[[1, 0, 0], [0, 1, 0], [0, 0, -1]][i]).applyMatrix4(new T.Matrix4().extractRotation(xj)).normalize();
    const r = centre.clone().sub(o), g = new T.Vector3(0, -1, 0);
    const rp = r.clone().sub(u.clone().multiplyScalar(r.dot(u))), gp = g.clone().sub(u.clone().multiplyScalar(g.dot(u)));
    if (gp.length() < 0.3 || rp.length() < 0.05) return;
    let turn = Math.atan2(u.dot(new T.Vector3().crossVectors(rp, gp)), rp.dot(gp)) / D2R;
    const k = ["x", "y", "z"][i], now = {...deg[name]}, edges = (m.limits || {})[axis];
    if (Math.abs(turn) > 170 && Array.isArray(edges) && edges.length === 2) turn = Math.abs(turn) * (edges[1] - now[k] >= now[k] - edges[0] ? 1 : -1);   // balanced on top: the way its limits give it room
    let to = {...now}; to[k] = now[k] + turn;
    to = clampDegrees(to, m.limits);
    const mix = (f) => v3(now.x + (to.x - now.x) * f, now.y + (to.y - now.y) * f, now.z + (to.z - now.z) * f);
    this.turnTo(name, to);
    if (this.lowestUnder(j) < floorY - 0.01) {
      let lo = 0, hi = 1;
      for (let s = 0; s < 10; s++) { const f = (lo + hi) / 2; this.turnTo(name, mix(f)); if (this.lowestUnder(j) < floorY - 0.01) hi = f; else lo = f; }
      to = mix(lo); this.turnTo(name, to);
    }
    deg[name] = to;
  }
  stepGutter(dt) {
    if (!this.gutter || this.gutter.t >= GUTTER) return false;
    this.gutter.t += dt;
    const k = gutterK(this.gutter.t);
    for (const [m, e] of this.gutter.mats) {
      m.emissiveIntensity = e * k;
      for (const h of this.halos.get(m) || []) { h.uniforms.light.value = Math.pow(m.emissiveIntensity, 1 / 2.2); h.uniforms.presence.value = 0; }
    }
    return true;
  }
  tick(delta, acting = true) {
    let moved = this.stepFlashes(delta), left = delta;
    if (this.stepGutter(delta)) moved = true;
    if (this.stepCollapse(delta)) moved = true;
    this.stepPlumes();
    acting = acting && !this.dead;
    if (this.stepFlares(delta)) moved = true;
    this.waitBudget = Math.min(delta, WAIT_TICK_MAX);
    while (left > 0) { const dt = Math.min(left, STEP); left -= dt; if (this.step(dt, acting)) moved = true; }
    if (this.formsStep(delta)) moved = true;   // the held forms turn on their own clock
    if (this.spinsHeldStep(delta)) moved = true;   // a status's spin, held on the page by its chip
    if (this.countDisplays.length) {   // no fight on this page: every display counts up a part a second until it falls, as RIFTGATE_COUNT_DEBUG has it in the game
      this.countDebugT += delta;
      if (this.countDebugT >= COUNT_DEBUG_PERIOD) {
        this.countDebugT -= COUNT_DEBUG_PERIOD;
        const up = {};
        for (const d of this.countDisplays) up[d.source] = (Math.max(0, d.n) + 1) % (d.parts.length + 1);
        this.showCounts(up);
      }
      this.countsStep(delta);
    }
    for (const [name, r] of Object.entries(this.spinners)) {
      const lk = this.locked[name];
      if (lk) {   // the act playing locks it: it eases onto its step and holds there
        lk[2] = Math.min(lk[2] + delta, PARK_TIME);
        const u = lk[2] / PARK_TIME;
        this.spun[name] = lerp(lk[0], lk[1], u * u * (3 - 2 * u));
      } else {
        const s = this.spun[name] + (r[0] + (r[1] - r[0]) * this.blend) * delta * this.spinK;
        this.spun[name] = ((s % 360) + 360) % 360;
      }
      moved = true;
    }
    if (moved) this.pose();
  }
  step(dt, acting) {
    let moved = false;
    if (this.current) {
      this.t += dt; this.evaluateAct(); moved = true;
      if (this.t >= (this.until >= 0 ? this.until : (this.current.duration || 0))) this.endAct(true);
    } else if (acting && this.actSet().length && !this.moving) {
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
    if (this.aimAt) { this.aimAt.t += dt; if (this.aimAt.t >= AIM_UP + this.aimAt.hold + AIM_DOWN) this.aimAt = null; moved = true; }
    return moved;
  }
  // The blows alone, for a paused stage: a blow always plays out (Ryan, 5 October: they only
  // played while an act was running, since a paused stage advanced nothing).
  tickStrikes(delta) {
    const turning = this.formsStep(delta);   // a form held or let go on a paused stage turns all the same
    const flaring = this.stepFlares(delta) || this.stepGutter(delta);
    const falling = this.stepCollapse(delta);
    this.stepPlumes();
    if (this.aimAt) { this.aimAt.t += delta; if (this.aimAt.t >= AIM_UP + this.aimAt.hold + AIM_DOWN) this.aimAt = null; }
    if (this.current && this.until >= 0) {   // a firing slice is a blow, and plays out on a paused stage too, in steps no longer than STEP
      let left = delta;
      while (left > 1e-9 && this.current) { const dt = Math.min(left, STEP); left -= dt; this.t += dt; this.evaluateAct(); this.follow(dt); if (this.t >= this.until) this.endAct(true); }
      for (const st of this.strikes) st.t += delta;
      this.strikes = this.strikes.filter(st => st.t < st.up + st.down);
      this.pose(); return;
    }
    // What a slice or a slump left raised comes home (or falls) on a paused stage too (Ryan, 3 November:
    // the Badger's claw "needs to come back down after attacking"; the slice ended, nothing ran its servos).
    const bw = this.bodyWantRot, bs = this.bodyWantSlide;
    const homing = Object.keys(this.servo).length || Object.keys(this.wantRot).length || bw.x || bw.y || bw.z || bs.x || bs.y || bs.z;
    if (homing) { let left = delta; while (left > 1e-9) { const dt = Math.min(left, STEP); left -= dt; this.follow(dt); } }
    if (!this.strikes.length && !this.aimAt) { if (turning || flaring || falling || homing) this.pose(); return; }
    for (const st of this.strikes) st.t += delta;
    this.strikes = this.strikes.filter(st => st.t < st.up + st.down);
    this.pose();
  }
  // A blow (MechRig.strike): `only` the joints of the weapon that fired, `recoil` (in the body's
  // parent's frame) a gun on the body kicking the whole machine back, `lead` the wait while it aims.
  strike(ranged, only = [], recoil = null, lead = 0) {
    if (recoil) this.strikes.push({joint: "@body", vec: v3(), recoil, up: 0.05, down: 0.22, t: -lead});
    const armed = {}, named = only.length > 0 || !!recoil;
    for (const hp of Object.values(this.hardpoints)) { const o = this.jointOf(hp); if (o) armed[o] = true; }
    for (const name of Object.keys(this.joints)) {
      if (named && !only.includes(name)) continue;
      const m = this.meta[name], axis = m.axis;
      let swing;
      if (ranged && (armed[name] || only.includes(name)) && m.slide) {   // a gun that only runs in and out of its port kicks back along its line (MechRig.strike)
        this.strikes.push({joint: name, vec: v3(), slide: v3(-m.slide[0] * RECOIL_SLIDE, -m.slide[1] * RECOIL_SLIDE, -m.slide[2] * RECOIL_SLIDE), up: 0.05, down: 0.2, t: -lead});
        continue;
      }
      if (ranged) { if (!armed[name] && !only.includes(name)) continue; swing = 5; }   // a joint named kicks though it carries no mount (a fixed gun on a wrist)
      else if (m.swing) swing = -29;
      else if (named) swing = -15;   // a melee piece on a joint that is not an arm's: a jab
      else continue;
      const lim = m.limits[axis];
      if (Array.isArray(lim) && lim.length === 2) {
        if (swing > 0 && lim[1] <= 0 && lim[0] < 0) swing = -swing;
        else if (swing < 0 && lim[0] >= 0 && lim[1] > 0) swing = -swing;
      }
      const vec = v3(); vec[["x", "y", "z"][AXES.indexOf(axis)]] = swing;
      this.strikes.push({joint: name, vec, up: ranged ? 0.05 : 0.10, down: ranged ? 0.2 : 0.28, t: -lead});
    }
    this.pose();
  }
  fireFlare(mesh, look, lead = 0) { mesh.material.uniforms.spin.value = Math.random() * Math.PI * 2; this.flares.push({mesh, look, t: -lead}); }
  stepFlares(dt) {
    if (!this.flares.length) return false;
    for (const f of this.flares) { f.t += dt; const k = flareStrength(f.look, f.t); f.mesh.material.uniforms.strength.value = k; f.mesh.visible = k > 0; }
    this.flares = this.flares.filter(f => { const live = f.t < flareLasts(f.look); if (!live) f.mesh.visible = false; return live; });
    return true;
  }
  // The turn onto a target (MechRig.aim): a yaw joint, or "@body" for a hover's or a flyer's pivot.
  aim(joint, deg, hold) { if (joint !== "@body" && !this.joints[joint]) return; this.aimAt = {joint, deg, hold: Math.max(0, hold), t: 0}; }
  aimEnvelope() {
    const a = this.aimAt; if (!a) return 0;
    if (a.t < AIM_UP) { const f = a.t / AIM_UP; return 1 - (1 - f) * (1 - f); }
    if (a.t < AIM_UP + a.hold) return 1;
    const g = clamp((a.t - AIM_UP - a.hold) / AIM_DOWN, 0, 1); return 1 - g * g * (3 - 2 * g);
  }
  aimJointOver(node) {   // MechRig.aim_joint_over: the nearest yaw joint above a pin, no spinner and no steering
    const steer = (this.gait || {}).steer || {};
    let p = node.parent;
    while (p && p !== this.model) {
      const tag = parseTag(p.name || "");
      if (tag[0] === "joint" && this.joints[tag[1]] && this.meta[tag[1]].axis === "yaw" && !(tag[1] in this.spinners) && !(tag[1] in steer)) return tag[1];
      p = p.parent;
    }
    return "";
  }
  static envelope(st) {
    if (st.t <= 0) return 0;
    if (st.t < st.up) { const f = st.t / st.up; return 1 - (1 - f) * (1 - f); }
    const g = clamp((st.t - st.up) / st.down, 0, 1);
    return 1 - g * g * (3 - 2 * g);
  }
  pose() {
    for (const [name, j] of Object.entries(this.joints)) {
      let deg = add3(add3(this.actRot[name] || v3(), this.gaitRot[name] || v3()), this.formRot[name] || v3()), kick = v3();
      for (const st of this.strikes) if (st.joint === name) { deg = add3(deg, mul3(st.vec, Rig.envelope(st))); if (st.slide) kick = add3(kick, mul3(st.slide, Rig.envelope(st))); }
      if (this.aimAt && this.aimAt.joint === name) deg = add3(deg, v3(0, this.aimAt.deg * this.aimEnvelope(), 0));
      deg = clampDegrees(deg, this.meta[name].limits);
      if (name in this.spun) { const k = ["x", "y", "z"][AXES.indexOf(this.meta[name].axis)]; deg = {...deg, [k]: deg[k] + this.spun[name]}; }
      const r = this.rest[name], e = eulerOf(deg);
      j.rotation.set(r.x + e.x, r.y + e.y, r.z + e.z, "YXZ");
      const o = offsetOf(add3(add3(add3(this.actSlide[name] || v3(), this.gaitSlide[name] || v3()), this.formSlide[name] || v3()), kick)), p = this.restPos[name];
      j.position.set(p.x + o.x, p.y + o.y, p.z + o.z);
    }
    const turn = this.aimAt && this.aimAt.joint === "@body" ? v3(0, this.aimAt.deg * this.aimEnvelope(), 0) : v3();
    let bo = offsetOf(add3(add3(this.bodyActSlide, this.bodyMoveSlide), this.formBodySlide));
    const be = eulerOf(add3(add3(add3(this.bodyActRot, this.bodyMoveRot), this.formBodyRot), turn));
    let rock = v3();
    for (const st of this.strikes) if (st.joint === "@body") { const k = Rig.envelope(st); bo = {x: bo.x + st.recoil.x * k, y: bo.y + st.recoil.y * k, z: bo.z + st.recoil.z * k}; rock = add3(rock, mul3(st.vec, k)); }
    const re = eulerOf(rock);   // a jolt's nose rocking up (MechRig._pose)
    this.body.position.set(this.bodyRestPos.x + bo.x, this.bodyRestPos.y + bo.y, this.bodyRestPos.z + bo.z);
    this.body.rotation.set(this.bodyRestRot.x + be.x + re.x, this.bodyRestRot.y + be.y + re.y, this.bodyRestRot.z + be.z + re.z, "YXZ");
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
    // MechRig: steering about each joint's own axis (a knuckle yaws, the Buzzard's nacelles pitch: the eighteenth notes)
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
      for (const [m, base] of this.moveGlow) this.lightTo(m, base, k);
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
// The skirmish's stand-off (SkirmishScreen.FLYER_LIFT and HOVER_LIFT, in hexes, at MechView3D's scale on
// its floor: MECH_FILL and SIZE_FILL), so a flyer or a hover stands off the grid as it does in a fight
// and a lost one comes down onto what hangs lowest (MechView3D.lose).
const SKIRMISH = {fill: 0.96, sizeFill: {light: 0.7, medium: 0.82, heavy: 0.92, assault: 1.0}, flyer: 0.4, hover: 0.06};
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

// ---------------------------------------------------------------- launches
// A launch's flight from its sidecar row (MechView3D.flight_row): how far along its own line it
// goes and how it gathers there ("in" gathering speed, "out" slowing, "line" at one speed), how far
// gravity pulls it down by the flight's end, the degrees it turns end over end, how long it hangs
// where the flight ends and how far it sinks meanwhile, the last seconds its light dies over, and
// the light it burns at (MechView3D.LAUNCH_LIGHT, 14, unless it names its own).
function flightRow(node, l) {
  return {node, rest: node.position.clone(), restQ: node.quaternion.clone(), delay: +l.delay || 0,
          seconds: Math.max(0.05, +l.seconds || 0.6), reach: l.reach == null ? 100 : +l.reach, ease: l.ease || "in",
          drop: +l.drop || 0, spin: +l.spin || 0, hang: Math.max(0, +l.hang || 0), sink: +l.sink || 0,
          fade: Math.max(0, +l.fade || 0), light: l.light == null ? 14 : +l.light};
}
// The moment a launch leaves (MechView3D._leave): the frame it flies in (its parent's, as it stands
// now), the world's down in that frame, and its line (its own -z, its reach long), or the way to
// where it lands as that stands now.
function leaveFlight(f) {
  const T = window.THREE, parent = f.node.parent;
  f.frame = new T.Matrix4();
  if (parent) { parent.updateWorldMatrix(true, false); f.frame.copy(parent.matrixWorld); }
  const p = new T.Vector3(), q = new T.Quaternion(), sc = new T.Vector3();
  f.frame.decompose(p, q, sc);
  f.down = new T.Vector3(0, -1, 0).applyQuaternion(q.invert());
  f.line = new T.Vector3(0, 0, -1).applyQuaternion(f.restQ).multiplyScalar(f.reach);
  if (f.lands) {
    f.lands.updateWorldMatrix(true, false);
    const there = new T.Vector3().setFromMatrixPosition(f.lands.matrixWorld).applyMatrix4(f.frame.clone().invert());
    f.line = there.sub(f.rest).addScaledVector(f.down, -f.drop);
  }
}
// Where a launch is t seconds after it left (MechView3D.flight_at), in that frame: carried along its
// line by its ease, pulled `drop` along `down` by the square of the flight's share, turned `spin`
// degrees about its own x; then held where the flight ended while it hangs, sinking.
function flightAt(f, t) {
  const T = window.THREE;
  const u = Math.min(1, Math.max(0, t / f.seconds));
  const e = f.ease === "out" ? u * (2 - u) : (f.ease === "line" ? u : u * u);
  const position = f.rest.clone().addScaledVector(f.line, e).addScaledVector(f.down, f.drop * u * u);
  if (f.hang > 0 && t > f.seconds) position.addScaledVector(f.down, f.sink * Math.min(1, (t - f.seconds) / f.hang));
  const quaternion = f.restQ.clone();
  if (f.spin) quaternion.multiply(new T.Quaternion().setFromAxisAngle(new T.Vector3(1, 0, 0), f.spin * u * Math.PI / 180));
  return {position, quaternion};
}
// The light a launch burns at t (MechView3D.flight_light): its own the whole way, dying to nothing
// over its last `fade` seconds.
function flightLight(f, t) {
  const left = f.seconds + f.hang - t;
  return f.fade > 0 && left < f.fade ? f.light * Math.min(1, Math.max(0, left / f.fade)) : f.light;
}

// ---------------------------------------------------------------- the stage
// The models' own tiles, nearest sampled on flat facets; the amber role lights, as the game's
// toon pass makes it (MechView3D.toon), in the phone's colours (PHONE_GLOW), each material its
// own so a glow is per instance.
function prepareMaterials(root) {
  const T = window.THREE;
  root.traverse(n => {
    if (!n.isMesh || n.userData.halo) return;
    n.material = [].concat(n.material).map(src => {
      const m = src.clone();
      m.flatShading = true; m.side = T.DoubleSide; m.roughness = 0.85; m.metalness = 0.1;
      if (m.map) { m.map = m.map.clone(); m.map.needsUpdate = true; m.map.magFilter = T.NearestFilter; m.map.minFilter = T.NearestFilter; m.map.wrapS = m.map.wrapT = T.RepeatWrapping; }
      if ((src.name || "").startsWith("amber")) {
        m.emissive = new T.Color(1, 1, 1); m.emissiveMap = m.map; m.emissiveIntensity = GLOW_PAGE; m.userData.lit = true;
        m.onBeforeCompile = sh => { sh.fragmentShader = sh.fragmentShader.replace("#include <emissivemap_fragment>", PHONE_GLOW); };
      }
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
    const up = this.mode === "route" ? 0 : (this.lift || 0), span = up > 0 ? up + (this.top || 0) : 0;   // a flyer standing off the grid: the grid and the machine both in view, the machine as large as ever
    const half = this.mode === "route" ? STEP * 2.3 + this.size * 0.3 : Math.max(this.size * 0.75, span * 0.6);
    const a = this.aspect || 1;
    this.camera.left = -half * a; this.camera.right = half * a; this.camera.top = half; this.camera.bottom = -half;
    this.camera.updateProjectionMatrix();
    if (!keepDir) {
      const target = this.mode === "route" ? new window.THREE.Vector3(STEP * 0.866, 0, -STEP * 1.5) : new window.THREE.Vector3(0, up > 0 ? span * 0.5 : this.size * 0.3, 0);
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
    const side = shape ? Promise.resolve({}) : fetch("hangar/models/" + id + ".rig.json?v=" + Date.now(), {cache: "no-store"}).then(r => {
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
    this.sizeClass = typeof this.size === "string" ? this.size : (this.sizeClass || "heavy");   // the page sets its class by mass as size; the numbers take the name below
    this.size = Math.max(s.x, s.y, s.z);
    this.widest = Math.max(s.x, s.z);
    const scale = SKIRMISH.fill * (SKIRMISH.sizeFill[this.sizeClass] || 1) / Math.max(0.001, Math.max(this.widest, (box.max.y - Math.min(box.min.y, 0)) * 0.8));
    this.lift = shape ? 0 : (this.flyer ? SKIRMISH.flyer : this.hover ? SKIRMISH.hover : 0) / scale;   // model units off the grid
    this.top = box.max.y;
    this.landT = -1; this.landK = 0; this.swayK = 1;
    this.modelRoot = root;
    this.pivot.add(root);
    this.rig = new Rig(root, sidecar, 7);
    this.burns = []; this.flares = []; this.shot = 0; this.aimSide = 1;
    // What a fixed weapon fires out of the machine (MechView3D.launches_of: the Lammergeier's drones,
    // the Swallowtail's flares, the Musk Ox's rockets, shell and casing), hidden until it flies.
    this.launches = {}; this.flights = [];
    for (const [cid, rows] of Object.entries(sidecar.launches || {})) {
      this.launches[cid] = [];
      for (const l of rows || []) {
        const node = root.getObjectByName(l.node);
        if (!node) continue;
        node.visible = false;
        const row = flightRow(node, l);
        if (l.lands) row.lands = root.getObjectByName(l.lands) || null;
        this.launches[cid].push(row);
      }
    }
    if (!shape) this.wearBurns(sidecar, id);
    this.gaitName = "";
    this.rig.debug = this.loop || "1";
    this.side = sidecar;
    if (shape && this.mode !== "acts") this.mode = "acts";
    this.route = new Route(this.widest / (2 * fitFor(this.sizeClass)));
    this.buildGround();
    this.pivot.position.set(0, 0, 0); this.pivot.rotation.set(0, this.route.facing, 0);
    this.balance = this.hover ? new HoverBalance(3) : null;
    this.note.textContent = "";
    this.frame();
    this.emit();
    this.start();
  }
  // How a class sits at a mount (MechView3D.fit_of): the variant and the scale on the pin's own
  // the sidecar's `fits` declare for it there, else the class itself at the pin's scale.
  fitOf(n, shape) {
    const how = ((((this.side || {}).fits || {})["hp_" + n]) || {})[shape] || {};
    return {shape: how.shape || shape, scale: Number(how.scale) || 1, sink: Number(how.sink) || 0};   // sink: back along the pin's line, its +z in the glTF (MechView3D.sink_offset)
  }
  // Fit a mount as the game does (MechView3D.wear): the stock part under hp_<n> hides and a
  // silhouette class in a maker's metal hangs under the pin, in the variant and at the scale the
  // mount declares for it, wearing the pin's frame, so it swings and recoils with whatever joint
  // carries the pin. `shape` "" bares the mount; null puts the stock part back. A hidden mount
  // (the sidecar's hidden_pins: the Cottonmouth's guns inside its drum) wears nothing, as in the game.
  async fit(n, shape, maker) {
    const rig = this.rig, pin = rig && rig.hardpoints[n];
    if (!pin) return;
    const id = this.id;
    let part = null;
    if (shape && !this.hidden(n)) {
      const how = this.fitOf(n, shape);
      const gltf = await this.loadModel("shapes/" + how.shape + "_" + maker);
      if (this.id !== id) return;
      part = gltf.scene;
      part.scale.setScalar(how.scale);
      part.position.set(0, 0, how.sink);
      prepareMaterials(part);
      part.userData.mounted = true;
    }
    for (const c of pin.children.slice()) {
      if (c.userData.mounted) pin.remove(c);
      else c.visible = shape === null;
    }
    if (part) pin.add(part);
    for (const f of this.flares.filter(f => f.pin === n)) pin.remove(f.mesh);
    this.flares = this.flares.filter(f => f.pin !== n);
    if (shape === null) {   // the stock part back: its class's flares (a stock gun is its class, 11 November)
      const side = this.side || {}, cls = (side.stock_shapes || {})["hp_" + n];
      this.hangFlares(n, cls, (side.pins || {})["hp_" + n]);
    }
    else if (shape) this.hangFlares(n, shape, "");
    rig.glowCache = {};   // a fitted part's lights now answer the mount's glow
    if (shape === null) delete this.fits[n]; else this.fits[n] = shape ? shape + ":" + maker : "bare";
    this.emit();
  }
  resetFits() { for (const n of Object.keys(this.fits)) this.fit(Number(n), null); }
  // A mount the model hides (the sidecar's hidden_pins: the Cottonmouth's guns inside its drum)
  // wears nothing and flares nothing, so no part or effect shows through what hides it.
  hidden(n) { return typeof n === "number" && (((this.side || {}).hidden_pins) || []).includes("hp_" + n); }
  // A blow on the hull (MechView3D.hit): the machine shoved back from it and its hull laid over in
  // heat's red-orange for a beat, the armour's block at half; each press the next of a hull hit from
  // the left and a block from the right. The page tints each material toward heat's colour where the
  // game lays an overlay over it.
  hit() {
    const rig = this.rig;
    if (!rig || rig.dead) return;
    const kinds = [["hull", -1], ["block", 1]], [kind, side] = kinds[(this.hits = (this.hits || 0) + 1) % 2];
    this.hitK = kind === "block" ? 0.5 : 1;
    rig.jolt({x: -side * 0.5, y: 0, z: 1}, this.hitK);
    if (!(this.hitT >= 0)) {
      const T = window.THREE;
      this.hitMats = [];
      rig.model.traverse(n => { if (n.isMesh && !n.userData.halo) for (const m of [].concat(n.material)) if (m.color && !this.hitMats.some(h => h[0] === m)) this.hitMats.push([m, m.color.clone(), m.emissive ? m.emissive.clone() : null]); });
      this.heat = new T.Color(HIT.colour[0], HIT.colour[1], HIT.colour[2]);
    }
    this.hitT = 0;
  }
  // Each launch in the air flies its flight (MechView3D._fly, flightAt), lit as it leaves, its light
  // dying over its fade, and is hidden at home once its time is up.
  fly(dt) {
    const T = window.THREE;
    for (const f of this.flights) {
      const was = f.t; f.t += dt;
      if (f.t < 0) continue;
      if (f.t >= f.seconds + f.hang) { f.node.visible = false; f.node.position.copy(f.rest); f.node.quaternion.copy(f.restQ); f.node.scale.set(1, 1, 1); f.done = true; this.burn(f.node, 1); continue; }
      if (was < 0) { leaveFlight(f); f.node.visible = true; this.burn(f.node, f.light); }
      else if (f.fade > 0) this.burn(f.node, flightLight(f, f.t));
      // The world's once it leaves (MechView3D._fly): placed in its parent's frame as that stood then.
      const at = flightAt(f, f.t), parent = f.node.parent;
      const world = f.frame.clone().multiply(new T.Matrix4().compose(at.position, at.quaternion, new T.Vector3(1, 1, 1)));
      if (parent) { parent.updateWorldMatrix(true, false); world.premultiply(parent.matrixWorld.clone().invert()); }
      world.decompose(f.node.position, f.node.quaternion, f.node.scale);
    }
    this.flights = this.flights.filter(f => !f.done);
  }
  burn(node, k) {   // MechView3D._burn: every lit part under a launch at k rests over its own
    if (!this.rig) return;
    node.traverse(n => { if (n.isMesh && !n.userData.halo) for (const m of [].concat(n.material)) if (m.userData.lit) this.rig.lightTo(m, restOf(m), k); });
  }
  stepHit(dt) {
    this.hitT += dt;
    const k = HIT.peak * this.hitK * hitK(this.hitT), done = this.hitT >= HIT.up + HIT.hold + HIT.down;
    for (const [m, c, e] of this.hitMats || []) {
      m.color.copy(c).lerp(this.heat, done ? 0 : k);
      if (e && !m.userData.lit) m.emissive.copy(e).lerp(this.heat, done ? 0 : k * 0.6);
    }
    if (done) { this.hitT = -1; this.hitMats = []; }
  }
  // The machine lost (MechView3D.lose): its lit parts gutter out; again lights it.
  lose() {
    const rig = this.rig;
    if (!rig) return;
    if (rig.dead) { rig.revive(); this.landT = -1; this.landK = 0; this.swayK = 1; } else { rig.airborne = !!(this.hover || this.flyer); rig.kill(); this.landT = 0; this.landK = 0; }
    this.emit();
  }
  // The glTF as JSON with its binary embedded: an artifact does not serve .glb (tools/hangar_data.py).
  // The page fetches it itself, as it fetches the content files, and three.js only parses it.
  // Its textures sit in the embedded binary, and r128 decodes those by fetch() on a blob:
  // address wherever createImageBitmap exists (Chrome, Safari); the artifact viewer's content
  // policy refuses that fetch ("Failed to fetch", 3 October). The plugin hands the parser an
  // image-element loader instead, which the policy allows for blob: images.
  async loadModel(id) {
    const r = await fetch("hangar/models/" + id + ".model.json?v=" + Date.now(), {cache: "no-store"});   // past any cache between, as the page's fetchJson
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
  // Hold what a status holds or let it go, as the machine carrying it would in the game
  // (MechView3D.hold_statuses): its form, its spin.
  holdStatus(name, on) {
    if (!this.rig) return;
    if (this.rig.forms[name]) this.setForm(name, on);
    if (this.rig.heldSpins[name]) { this.rig.holdSpin(name, on); this.emit(); }
  }
  // Hold one of the sidecar's forms or let it go, as the status of its name would in the game.
  setForm(name, on) {
    if (!this.rig) return;
    this.rig.setForm(name, on);
    this.emit();
    // and again once it has turned, so the panel shows the acts it plays now
    const f = this.rig.forms[name], rig = this.rig;
    if (f) setTimeout(() => { if (this.rig === rig) this.emit(); }, (f.duration / Math.max(0.05, this.speedK || 1) + 0.1) * 1000);
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
      if (this.hitT >= 0) this.stepHit(dt * this.speedK);
      this.stand(dt * this.speedK);
      if (this.flights && this.flights.length) this.fly(dt * this.speedK);
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
    }
    if (rig.current) this.emitTick();
  }
  // Where the machine stands, playing or paused: a flyer or a hover off the grid by the skirmish's lift
  // (none on the route, which the map draws), a hover's balance on top; lost, its lift and its drift
  // ease out together after its lights have begun to go, until what hangs lowest rests on the grid
  // (MechView3D.lose: MechRig.collapse_floor).
  stand(dt) {
    if (!this.rig || this.isShape) return;
    if (this.landT >= 0) {
      this.landT += dt;
      const g = clamp((this.landT - COLLAPSE.at) / COLLAPSE.land, 0, 1);
      this.landK = g * g * (3 - 2 * g); this.swayK = 1 - this.landK;
      if (g >= 1) this.landT = -1;
    }
    const k = this.swayK ?? 1, route = this.mode === "route", lift = route ? 0 : (this.lift || 0);
    const land = this.rig.airborne && !route ? -this.rig.collapseFloor : lift;
    let y = lift + (land - lift) * (this.landK || 0);
    if (this.balance) {
      this.pivot.rotation.order = "YXZ";
      this.pivot.rotation.x = this.balance.pitch * k;
      this.pivot.rotation.z = this.balance.roll * k;
      y += this.balance.heave * k;
    }
    this.pivot.position.y = y;
  }
  // The machine's full speed on the map in its own model units a second (MechRig.map_speed):
  // the route's step, which the map fits to it, at the map's time for its move.
  topSpeed() { return this.route.STEP / mechSecondsPerHex(this.movespeed || 5); }
  emitTick() { const now = performance.now(); if (!this.lastTick || now - this.lastTick > 90) { this.lastTick = now; this.emit(); } }
  // A blow (MechView3D.strike): Fire fires the machine's weapons one press at a time, mount by
  // mount and then each fixed weapon with its own act, each turning onto a target first where it
  // can (a turret, a waist, a hover's pivot; here a bearing to one side and then the other) and
  // only it moving and flaring, a gun kicking and a melee piece that lunges jabbing (MuzzleFlare.lunges),
  // as the game does. A burn weapon's fire flares with its mount. (Melee, the old swing every
  // machine made before its weapons fired, is gone: no weapon strikes that way now.)
  strike(ranged = true) {
    if (!this.rig) return;
    const rig = this.rig, mounts = [...new Set(this.flares.map(f => f.pin).filter(p => typeof p === "number"))].sort((a, b) => a - b);
    const marked = Object.keys((this.side || {}).fx || {}).map(c => "fx:" + c);   // fixed weapons with a business end marked: they kick their joint and flare (MechView3D.strike)
    const fixed = Object.keys(rig.fires || {}), shots = [...mounts, ...marked, ...fixed, ...(rig.hiddenFire ? ["@hidden"] : [])];
    if (!ranged || !shots.length) {
      rig.strike(ranged);
      for (const part of this.burns || []) if (part.visible !== false && part.parent && part.parent.visible !== false) rig.flashUnder(part);
      return;
    }
    const next = shots[this.shot++ % shots.length];
    if (next === "@hidden") {   // the hidden mounts' slice (MechView3D.strike): the Cottonmouth's drum turns two chambers on and flashes its top chamber, no kick or flare at a mount
      let lead = 0;
      if (this.hover || this.flyer || rig.pivots) { this.aimSide = -this.aimSide; rig.aim("@body", 22 * this.aimSide, Math.max(0.8, rig.hiddenSpan() + AIM_HOLD)); lead = AIM_UP; }
      if (!rig.fireHidden(lead)) rig.strike(true, [], null, lead);
      return;
    }
    if (typeof next === "string" && next.startsWith("fx:")) {   // a fixed weapon with its business end marked: its aim joint or the waist or the pivot turns, its own joint kicks, it flares
      const cid = next.slice(3), node = rig.model.getObjectByName("fx_" + cid);
      let joint = rig.joints[rig.aims[cid]] ? rig.aims[cid] : (rig.joints.waist && rig.meta.waist.axis === "yaw" ? "waist" : ((this.hover || this.flyer || rig.pivots) ? "@body" : ""));
      let lead = 0;
      if (joint) { this.aimSide = -this.aimSide; rig.aim(joint, 22 * this.aimSide, 0.8); lead = AIM_UP; }
      const owner = node ? rig.jointOf(node) : "";
      rig.strike(true, owner ? [owner] : [], null, lead);
      for (const f of this.flares) if (f.pin === next) rig.fireFlare(f.mesh, f.look, lead + f.delay);
      return;
    }
    if (typeof next === "string") {   // a fixed weapon: the waist or a hover's pivot turns, then its own act fires (MechView3D.strike)
      let joint = rig.joints[rig.aims[next]] ? rig.aims[next] : (rig.joints.waist && rig.meta.waist.axis === "yaw" ? "waist" : ((this.hover || this.flyer || rig.pivots) ? "@body" : ""));
      let lead = 0;
      // held through its slice and a beat past it, as the game holds it (SkirmishScreen._aim_before)
      if (joint) { this.aimSide = -this.aimSide; rig.aim(joint, 22 * this.aimSide, Math.max(0.8, rig.fireSpan(next) + AIM_HOLD)); lead = AIM_UP; }
      if (!rig.fireAct(next, lead)) rig.strike(true, [], null, lead);
      for (const l of this.launches[next] || []) this.flights.push({...l, t: -l.delay - lead});   // and what it fires out flies (MechView3D.launch)
      return;
    }
    const n = next, pin = rig.hardpoints[n];
    let lead = 0, joint = rig.aimJointOver(pin);
    if (!joint && (this.hover || this.flyer || rig.pivots)) joint = "@body";   // a hover's, a flyer's, a tank's or a castered chassis's pivot (MechView3D.aim_joint_for)
    if (joint) { this.aimSide = -this.aimSide; rig.aim(joint, 22 * this.aimSide, 0.6); lead = AIM_UP; }
    const owner = rig.jointOf(pin), T = window.THREE;
    let recoil = null;
    if (!owner) {   // a gun on the body kicks the whole machine back along its line
      const q = new T.Quaternion(), qb = new T.Quaternion();
      pin.getWorldQuaternion(q); rig.body.getWorldQuaternion(qb);
      const fwd = new T.Vector3(0, 0, -1).applyQuaternion(q).applyQuaternion(qb.invert()).normalize();
      const back = fwd.multiplyScalar(-RECOIL_BODY).applyQuaternion(rig.body.quaternion).multiply(rig.body.scale);
      recoil = {x: back.x, y: back.y, z: back.z};
    }
    const jab = this.flares.some(f => f.pin === n && f.lunges);   // a melee piece fitted to a mount jabs, as the game strikes it
    rig.strike(!jab, owner ? [owner] : [], jab ? null : recoil, lead);
    for (const f of this.flares) if (f.pin === n) rig.fireFlare(f.mesh, f.look, lead + f.delay);
    for (const part of this.burns || []) if (part.parent === pin && part.visible !== false) rig.flashUnder(part);
  }
  // A weapon's muzzle flares on its mount (MechView3D.wear_flares): at its class's places (the
  // mount's variant's, at its scale there), in the look its tags give it (a fitted class alone,
  // its class's). A component that is no weapon takes none.
  async hangFlares(n, shape, cid, own = null) {   // `own`: a hand-built gun's places from its sidecar, in place of a class's; `n` "fx:<component>" a fixed weapon's marked business end
    const rig = this.rig, pin = rig && (typeof n === "string" && n.startsWith("fx:") ? rig.model.getObjectByName("fx_" + n.slice(3)) : rig.hardpoints[n]);
    if (!pin || (!shape && !own) || this.hidden(n)) return;
    if (!this.muzzles) this.muzzles = fetch("hangar/models/shapes/muzzles.json?v=" + Date.now(), {cache: "no-store"}).then(r => r.json()).catch(() => ({}));
    if (!this.kitOf) this.kitOf = fetch("content/components.json?v=" + Date.now(), {cache: "no-store"}).then(r => r.json()).then(j => {
      const out = {};
      for (const c of j.entries || []) out[c.id] = c;
      return out;
    }).catch(() => ({}));
    const [places, kit] = await Promise.all([this.muzzles, this.kitOf]);
    if (this.rig !== rig) return;
    const c = cid ? kit[cid] : null;
    if (c && (c.face || {}).kind !== "attack") return;
    const looks = flareLooks(c ? c.tags : [], shape), T = window.THREE, how = this.fitOf(n, shape);
    const worn = own || (places[how.shape] || []).map(([p, size]) => [[p[0] * how.scale, p[1] * how.scale, p[2] * how.scale + how.sink], size * how.scale]);
    for (const [at, size] of worn) looks.forEach((look, k) => {
      const b = FLARES.beats[look], w = size * b.scale * Math.pow(FLARES.layerScale, k), col = FLARES.colours[look];
      const mat = new T.ShaderMaterial({uniforms: {colour: {value: new T.Vector3(col[0], col[1], col[2])}, strength: {value: 0}, rays: {value: b.rays}, spin: {value: 0}, ahead: {value: 4}, core: {value: FLARES.cores[look]}},
        vertexShader: FLARE_VERT, fragmentShader: FLARE_FRAG, transparent: true, depthWrite: false, side: T.DoubleSide});   // laid over, as the game lays it (flare.gdshader)
      const mesh = new T.Mesh(new T.PlaneGeometry(w, w), mat);
      mesh.position.set(at[0], at[1], at[2]); mesh.visible = false; mesh.userData.halo = true; mesh.renderOrder = 2 + k; mesh.frustumCulled = false;
      pin.add(mesh);
      this.flares.push({pin: n, mesh, look, delay: FLARES.layerDelay * k, lunges: lunges(c ? c.tags : [], shape)});
    });
  }
  // A burn weapon's fire over its class on each stock mount whose component burns (MechView3D.burn_rows):
  // the sidecar names each stock class (`stock_shapes`) and what each pin carries (`pins`); content
  // says what burns (its entry's keywords hold "burn"). It flares on a strike, here on either button.
  async wearBurns(side, id) {
    const shapes = side.stock_shapes || {}, pins = side.pins || {};
    // A fixed weapon's business end (MechView3D.wear_fx_flares): its flares at the fx_ node riding its joint.
    for (const [cid, size] of Object.entries(side.fx || {})) this.hangFlares("fx:" + cid, "", cid, [[[0, 0, 0], size]]);
    if (!Object.keys(shapes).length) return;
    for (const [pin, shape] of Object.entries(shapes)) this.hangFlares(Number(pin.slice(3)), shape, pins[pin] || "");
    if (!this.burnsOf) this.burnsOf = fetch("content/components.json?v=" + Date.now(), {cache: "no-store"}).then(r => r.json()).then(j => {
      const out = new Set();
      for (const c of j.entries || []) if (((c.face || {}).keywords || []).includes("burn")) out.add(c.id);
      return out;
    }).catch(() => new Set());
    const rig = this.rig, burning = await this.burnsOf;
    for (const [pin, shape] of Object.entries(shapes)) {
      const cid = pins[pin], n = Number(pin.slice(3));
      if (!cid || !burning.has(cid) || this.rig !== rig || this.hidden(n)) continue;
      let gltf;
      const how = this.fitOf(n, shape);
      try { gltf = await this.loadModel("shapes/burn_" + how.shape); } catch (e) { continue; }
      const node = rig && rig.hardpoints[n];
      if (this.rig !== rig || !node) return;   // a later visit replaced this rig
      const part = gltf.scene;
      part.scale.setScalar(how.scale);
      part.position.set(0, 0, how.sink);
      prepareMaterials(part);
      part.userData.burn = cid;
      node.add(part);
      rig.wearHalo(part);
      this.burns.push(part);
    }
  }
  seek(t) { if (this.rig && this.rig.current) { this.rig.seek(t); this.renderer && this.renderer.render(this.scene, this.camera); this.emit(); } }
}

window.HangarMotion = {Rig, Route, Stage, MovePath, HoverBalance, curve, cycleCurve, curveAt, sample, sampleCycle, clampDegrees, labelled, MOVE_REF_SPEED,
  plumes: (on) => { if (on !== undefined) PLUMES_ON = !!on; return PLUMES_ON; }};
})();
