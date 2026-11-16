class_name DomainGround
extends RefCounted

## The other world's ground in each domain's own tileset (Ryan, 29 October: "They all need
## their own tileset, first of all. Shouldn't all be painting green meadows"; 30 October:
## "walls and water certainly should change with tileset, even if they have no functional
## change", and of the grounds, "the different types need different backgrounds. Its very
## monotone now. It just needed to be less jarring"). A domain, by its `bleed` in content,
## paints every hex in its own idiom, each ground a tone of the domain's own a step apart on the
## posterize grid, and dressed in outlined pixel sprites, two pixels a design pixel, as flat,
## bright and chunky as the painted map is (Ryan, 20 September). Water is always the
## domain's liquid edged by a rim and stirred by ripples, the walls always a range filling the
## hex, so a hex's rule reads alike in every domain; a road follows the roads beside it. Every
## colour sits on the compositor's posterize grid (six levels a channel, bleed.gdshader), so
## what is drawn is what the map shows, and was picked by the three colourblind simulations
## against the HUD options, the enemy red and the rift's violets on the ground it is drawn on
## (docs/measurements.md, 30 October). The fight's backdrop keeps its palettes here too (BACKDROPS),
## its water the map's liquid (LIQUIDS), so a domain's colours change in one place. RIFTGATE_BLEED_DEBUG=1 gives the whole field to the
## painted world (Bleed.gradient), and tools/tileset_shot.gd draws every tileset side by side.

## Each domain's liquid, written once for the map's water and the fight's lake (30 October: the
## fight's lava had stayed the yellow-orange Ryan called acid after the map's went orange-red, and
## its Marsh kept a poison purple on the rift's violet): body, the rim at its edge, the deep under
## it and two glints, every colour on the posterize grid. The Peak's lava is orange-red, its crust
## the deep and the rim, its glints the hot light that runs through the fissures and the vents.
const LIQUIDS := {
	"plains": {"body": "3366ff", "rim": "ccffff", "deep": "3366cc", "glints": ["ccffff", "ffffff"]},
	"sand": {"body": "339999", "rim": "66cccc", "deep": "336666", "glints": ["66cccc", "ccffff"]},
	"marsh": {"body": "003333", "rim": "336666", "deep": "000000", "glints": ["336666", "669999"]},
	"lava": {"body": "ff6600", "rim": "990000", "deep": "330000", "glints": ["ff9900", "ffcc00"]},
}

## Each domain's tileset, by its bleed:
##   ground, grounds: the domain's ground, and each ground's own tone of it (two steps at
##   most in a channel of the posterize grid, three in all) or its water;
##   grid: the hex's outline; specks: the colours its decorative grounds are flecked with;
##   road: its edge and bed, and the sprite set along it (road_stone, if any);
##   rim, ripples: the water's edge and what drifts on it, a frame's step apart;
##   plain, rough, ruins: what stands on each decorative ground, [sprite, how many, and the
##   chance of each if not certain], the largest first (a road's hex takes the plain's, clear
##   of the road);
##   flat: sprites that lie on the ground, under the rest; fixed: sprites never mirrored.
const TILESETS := {
	"plains": {
		"ground": "339933",
		"grounds": {BattleMap.Terrain.ROAD: "669933", BattleMap.Terrain.ROUGH: "336633", BattleMap.Terrain.RUINS: "669966", BattleMap.Terrain.WATER: LIQUIDS.plains.body},
		"grid": "003300",
		"specks": ["336633", "66cc66"],
		"road": ["996633", "cc9966"],
		"rim": LIQUIDS.plains.rim,
		"ripples": ["ripple", "ripple", "glint"],
		"plain": [["tuft", 3], ["tuft_small", 3], ["bloom", 2], ["bloom_y", 2]],
		"rough": [["tree", 5], ["tree_small", 3]],
		"ruins": [["cottage_long", 1], ["cottage", 1], ["haystack", 1], ["bush", 1], ["tuft", 2]],
		"flat": ["tuft", "tuft_small", "bloom", "bloom_y"],
		"fixed": [],
	},
	"sand": {
		"ground": "cc9966",
		"grounds": {BattleMap.Terrain.ROAD: "cc9933", BattleMap.Terrain.ROUGH: "669933", BattleMap.Terrain.RUINS: "ffcc99", BattleMap.Terrain.WATER: LIQUIDS.sand.body},
		"grid": "663300",
		"specks": ["996633", "ffcc99"],
		"road": ["996633", "ffcc99"],
		"rim": LIQUIDS.sand.rim,
		"ripples": ["ripple", "ripple", "glint"],
		"plain": [["dune", 2, 0.7], ["rock", 1, 0.5], ["pebble", 3]],
		"rough": [["saguaro", 3], ["saguaro_small", 2], ["barrel", 2], ["shrub", 1]],
		"ruins": [["arch", 1], ["column", 1], ["skull", 1], ["block", 1], ["rock", 1]],
		"flat": ["dune", "pebble"],
		"fixed": ["saguaro", "saguaro_small"],
	},
	"marsh": {
		"ground": "333300",
		"grounds": {BattleMap.Terrain.ROUGH: "336633", BattleMap.Terrain.RUINS: "333333", BattleMap.Terrain.WATER: LIQUIDS.marsh.body},
		"grid": "000000",
		"specks": ["336633", "000000"],
		"road": ["333300", "663300"],
		"road_stone": "stone",
		"rim": LIQUIDS.marsh.rim,
		"ripples": ["ripple", "lily", "bubble", "ripple", "lily"],
		"plain": [["pool", 1, 0.7], ["reeds", 2, 0.5], ["grass", 3, 0.6]],
		"rough": [["deadtree", 2], ["deadtree_b", 2], ["reeds", 1], ["grass", 2]],
		"ruins": [["crypt", 1, 0.6], ["tomb", 2, 0.7], ["cross", 1, 0.6], ["skull", 1, 0.4], ["grass", 2, 0.5]],
		"flat": ["pool", "grass"],
		"fixed": [],
	},
	"lava": {
		"ground": "333333",
		"grounds": {BattleMap.Terrain.ROUGH: "330000", BattleMap.Terrain.RUINS: "663333", BattleMap.Terrain.WATER: LIQUIDS.lava.body},
		"grid": "000000",
		"specks": ["000000", "663333", "666666"],
		"road": ["000000", "666666"],
		"rim": LIQUIDS.lava.rim,
		"ripples": ["crust_big", "streak", "crust", "hot", "bubble", "streak"],
		"plain": [["boulder", 1, 0.4], ["shard", 1, 0.5], ["rock", 1, 0.6], ["pebble", 4]],
		"rough": [["fissure", 1], ["fissure_b", 1, 0.4], ["vent", 1, 0.6], ["boulder", 1], ["shard", 2], ["rock", 2, 0.6]],
		"ruins": [["temple", 1], ["pillar_broken", 1], ["block", 1], ["rock", 1]],
		"flat": ["pebble", "fissure", "fissure_b"],
		"fixed": [],
	},
}

## What moves with a sprite: [sprite, x and y in design pixels from the host's top left, its
## rise a frame]. A sprite with a variant a frame ("flame0", "flame1") shows the frame's.
const ATTACH := {
	"plains": {"cottage_long": ["puff", 10, -4, 2]},
	"sand": {},
	"marsh": {"crypt": ["wisp", 12, -3, 1]},
	"lava": {"temple": ["flame", 5, 4, 0], "vent": ["steam", 3, -5, 2]},
}

const ROAD_HALF := 3.5   # the road's half width in design pixels, its edge one more

## Each domain's inks: the colour each letter of its sprites is drawn in.
const INKS := {
	"plains": {"o": "003300", "1": "003300", "2": "339933", "3": "66cc33", "4": "ccff66", "t": "663300", "s": "336633", "g": "66cc66", "G": "336633", "f": "ffffff", "y": "ffff99", "k": "333300", "w": "ffffcc", "W": "cccc99", "r": "cc9933", "R": "996633", "h": "ffcc66", "d": "663300", "n": "333300", "m": "cc9966", "M": "663300", "S": "ffffff", "Z": "cccccc", "B": "ccffff", "x": "ffffff", "c": "3366cc"},
	"sand": {"o": "663300", "s": "cc9966", "S": "ffcc99", "D": "996633", "q": "003300", "c": "339933", "C": "66cc66", "e": "336633", "f": "ffff99", "n": "ffffcc", "N": "ffcc99", "K": "cc9966", "B": "ffffff", "b": "cccc99", "k": "333300", "y": "996633", "Y": "663300", "z": "330000", "m": "993300", "M": "663300", "l": "cc9966", "t": "cc9966", "T": "ffcc99", "W": "66cccc", "x": "ccffff", "v": "336666"},
	"marsh": {"o": "000000", "d": "333333", "m": "666666", "l": "999999", "G": "669933", "g": "336633", "p": "003333", "P": "336666", "t": "663300", "S": "cccccc", "s": "999999", "e": "666666", "B": "ffffff", "b": "cccccc", "w": "ccff99", "W": "ffffcc"},
	"lava": {"o": "000000", "d": "333333", "m": "666666", "l": "999999", "h": "cccccc", "c": "993300", "L": LIQUIDS.lava.glints[0], "H": LIQUIDS.lava.glints[1], "W": "ffff99", "k": LIQUIDS.lava.deep, "q": LIQUIDS.lava.rim, "g": LIQUIDS.lava.glints[0], "y": LIQUIDS.lava.glints[1]},
}

## Each domain's backdrop behind the fight (BattleBackdrop), kept beside its tileset so a domain's
## colours change in one place: sky, top to horizon; floor, far, middle, near; the rest dark to
## light unless named. Its water is the map's liquid (LIQUIDS), and the Peak's glow and crust
## are the lava's own. No domain wears the rift's violet, the enemy's register (30 October):
## the Marsh's sky is a cold night, its pools its bog's water and moss, never the genre's
## poison purple.
const BACKDROPS := {
	"plains": {
		"sky": ["2b5ec9", "3f78dc", "5c95e8", "86b6f2", "b8d8fa"],
		"cloud": ["fbfdff", "dce8f6", "a9bfdc"],
		"far": ["7ea6c6", "98bcd8"],
		"hill": ["4f8f58", "64a35e", "3d7549"],
		"floor": ["8ec466", "6aa84c", "4f8c3c"],
		"stripe": 0.05,
		"tuft": ["3e7834", "86c25a"],
		"speck": ["f4f4ee", "f2d850", "f28ca0"],
		"tree": ["21562d", "2f7036", "47903f", "6cb352"],
		"trunk": "5c3c24",
		"rock": ["5e5650", "857a70", "aea294"],
		"snow": ["bccde6", "eef4fc"],
		"stone": ["6c6c66", "94948a", "bcbcb0"],
		"roof": ["7e2a22", "b04234"],
		"water": [LIQUIDS.plains.deep, LIQUIDS.plains.body] + LIQUIDS.plains.glints,
		"road": ["9c8052", "bea26c", "d6bc86"],
	},
	"sand": {
		"sky": ["4472c0", "5c8acc", "84a8d4", "b6c6d0", "e4d8b4"],
		"cloud": ["fff8e8", "eadcc0", "cfbf9e"],
		"far": ["c8a07e", "dcb894"],
		"hill": ["d8a860", "eac27a", "b8884a"],
		"floor": ["e8c47a", "dcb062", "c89a4e"],
		"stripe": 0.045,
		"tuft": ["b0843e", "f0d290"],
		"speck": ["f6f2e6", "8c6a3a", "f6f2e6"],
		"tree": ["2a6a40", "3a8248", "54a058", "78bc6c"],
		"trunk": "6e5032",
		"rock": ["8c4c2c", "b46a3e", "d8925a"],
		"snow": ["e8c8a0", "f6e2c2"],
		"stone": ["a07a52", "c8a074", "e6c898"],
		"roof": ["8c4c2c", "b46a3e"],
		"water": [LIQUIDS.sand.deep, LIQUIDS.sand.body] + LIQUIDS.sand.glints,
		"road": ["b48a52", "c89e62", "dab478"],
	},
	"marsh": {
		"sky": ["0e1a1c", "1a2a2c", "2e3e3e", "4e5a58", "7a8478"],
		"cloud": ["d8dcc8", "a8b0a0", "7c8478"],
		"far": ["4a4e58", "5c6068"],
		"hill": ["3a4038", "4c5446", "2e342e"],
		"floor": ["687458", "55603f", "434d32"],
		"stripe": 0.05,
		"tuft": ["38422a", "7a8a56"],
		"speck": ["ccff99", "c8d0b8", "6e7e4a"],
		"tree": ["24262a", "33363a", "484c50", "62686a"],
		"trunk": "2a2a2e",
		"rock": ["34363a", "4a4c52", "686a70"],
		"snow": ["8a90a0", "aab0bc"],
		"stone": ["56585e", "76787e", "9a9ca0"],
		"roof": ["3a3a38", "545450"],
		"water": [LIQUIDS.marsh.deep, LIQUIDS.marsh.body] + LIQUIDS.marsh.glints,
		"road": ["4a4030", "5e5238", "766846"],
		"bog": ["336633", "669933"],
	},
	"lava": {
		"sky": ["180800", "2e1000", "4a1800", "772200", "aa3300"],
		"cloud": ["cc4400", "4a2c2a", "2a1a1c"],
		"far": ["3c2a2a", "5a3a32"],
		"hill": ["2a2024", "3a2c2e", "1e181a"],
		"floor": ["5a3e34", "443028", "32241e"],
		"stripe": 0.06,
		"tuft": ["241a18", "6e4a3a"],
		"speck": LIQUIDS.lava.glints + [LIQUIDS.lava.rim],
		"tree": ["1c1618", "2a2224", "3e3234", "5a4442"],
		"trunk": "2a2022",
		"rock": ["1e1819", "2e2627", "4a3a38"],
		"snow": ["6a4a42", "8a6052"],
		"stone": ["2e2a2e", "45403f", "62585a"],
		"roof": ["2a2022", "3e3234"],
		"water": [LIQUIDS.lava.deep, LIQUIDS.lava.body] + LIQUIDS.lava.glints,
		"road": ["4e4240", "62544e", "786a62"],
		"glow": [LIQUIDS.lava.rim, LIQUIDS.lava.body] + LIQUIDS.lava.glints,
		"crust": [LIQUIDS.lava.deep, LIQUIDS.lava.rim],
	},
}

## Each domain's sprites, a row of letters a row of design pixels, "." clear: authored with an
## outline one pixel round, lit from the upper left, every colour its domain's ink.
const SPRITES := {
	"plains": {
		"tree": [
			"...ooooo...",
			"..o33322o..",
			".o3443222o.",
			"o334322221o",
			"o343222221o",
			"o332222211o",
			"o222222111o",
			".o2221111o.",
			"..oo111oo..",
			"....oto....",
			"...soto....",
			"...sooos...",
		],
		"tree_small": [
			"..ooooo..",
			".o33322o.",
			"o3443221o",
			"o3432211o",
			"o2222111o",
			".o22111o.",
			"..oo1oo..",
			"...oto...",
			"..ssoss..",
		],
		"bush": [
			"..ooo..",
			".o332o.",
			"o32221o",
			"o22111o",
			".ooooo.",
		],
		"tuft": [
			"g.g.g",
			".GgG.",
		],
		"tuft_small": [
			"g.g",
			"GgG",
		],
		"bloom": ["f"],
		"bloom_y": ["y"],
		"cottage": [
			"......k......",
			".....khk.....",
			"....khrrk....",
			"...khrrrRk...",
			"..khrrrrrRk..",
			".khrrrrrrrRk.",
			"khrrrrrrrrrRk",
			"kkkkkkkkkkkkk",
			".kwwwwwwwwWk.",
			".kwnnwwwnnWk.",
			".kwnnddwnnWk.",
			".kwwwddwwwWk.",
			".kkkkkkkkkkk.",
			"..sssssssssss",
		],
		"cottage_long": [
			"..........kkk..",
			"...kkkkkkkkdk..",
			"..khhhhhhhhdhk.",
			".khrrrrrrrrrRk.",
			"khrrrrrrrrrrrRk",
			"kkkkkkkkkkkkkkk",
			".kwwwwwwwwwwWk.",
			".kwnnwddwwnnWk.",
			".kwnnwddwwnnWk.",
			".kwwwwddwwwwWk.",
			".kkkkkkkkkkkkk.",
			"..sssssssssssss",
		],
		"haystack": [
			"...k...",
			"..khk..",
			".khrrk.",
			".khrRk.",
			"khrrrRk",
			"krrrRRk",
			"kkkkkkk",
			".sssss.",
		],
		"puff": [
			".ZZ.",
			"ZSSZ",
			".ZZ.",
		],
		"ripple": [
			"BBB",
			".c.",
		],
		"glint": ["xB"],
	},
	"sand": {
		"saguaro": [
			"..qqq......",
			".qCceq.....",
			".qCceq.....",
			".qCceq..qq.",
			".qCceq.qCeq",
			".qCceq.qCeq",
			".qCceq.qCeq",
			".qCceqqqCeq",
			".qCcecccceq",
			".qCceqqqqq.",
			".qCceq.....",
			".qCceq.....",
			".qCceq.....",
			".qCceq.....",
			"..DqqqD....",
		],
		"saguaro_small": [
			"..qq....",
			".qCeq...",
			".qCeq.qq",
			".qCeqqCq",
			".qCcccCq",
			".qCeqqq.",
			".qCeq...",
			".qCeq...",
			"..DqqD..",
		],
		"barrel": [
			"..ff..",
			".qqqq.",
			"qCcceq",
			"qCcceq",
			"qCcceq",
			".qqqq.",
			"..DDD.",
		],
		"shrub": [
			".y.Y.y.",
			"yYyYyYy",
			".YyYyY.",
			"..DDD..",
		],
		"rock": [
			"..ooo.",
			".onNKo",
			"oNNKKo",
			".ooooo",
		],
		"rock_big": [
			"...oooo..",
			"..onnNKo.",
			".onNNNKKo",
			"oNNNKKKDo",
			"oNKKKKDDo",
			".ooooooo.",
		],
		"skull": [
			"BB.......BB",
			".BBb...bBB.",
			"...BBBBB...",
			"...BkBkB...",
			"...BBBBB...",
			"....BbB....",
			"....kBk....",
		],
		"arch": [
			"ooooooooooooooooo",
			"onnnnnnnnnnnnnnNo",
			"oNNNNNNNNoNNNNNKo",
			"oKKKKKKKKoKKKKKKo",
			"ooooooooooooooooo",
			".onNo.......onNo.",
			".onNo.......onNo.",
			".onKo.......onKo.",
			".onNo.......onNo.",
			".onNo.......onNo.",
			".onNo.......onKo.",
			".onKo.......onNo.",
			".onNo.......onNo.",
			"oooooo.....oooooo",
			"oNNNKo.....oNNNKo",
			"oooooo.....oooooo",
			".DDDDD.....DDDDD.",
		],
		"column": [
			".oooo.",
			"onnNKo",
			"oonNoo",
			".onKo.",
			".onNo.",
			".onNo.",
			".onKo.",
			".onNo.",
			"oooooo",
			".DDDD.",
		],
		"block": [
			".ooooo.",
			"onnnNKo",
			"oNNNKKo",
			".ooooo.",
		],
		"dune": [
			"....SSSSS.....",
			"..SSsssssSS...",
			".S.DDDDDDDsSS.",
			"...........DD.",
		],
		"pebble": ["SD"],
		"ripple": [
			"WWW",
			".v.",
		],
		"glint": ["xW"],
	},
	"marsh": {
		"deadtree": [
			".o............",
			"olo...........",
			"omo.........o.",
			".olo.o..o..olo",
			".omoolooloolo.",
			"..olomoomoomo.",
			"..omlo.omolmlo",
			"...omoololooo.",
			"....olomlo....",
			".....olmdo....",
			".....olmdo....",
			".....olmdo....",
			".....olmdo....",
			".....olmdo....",
			".....olmdo....",
			".....olmdo....",
			".....olmdo....",
			"....ollmddo...",
			".....ooooo....",
		],
		"deadtree_b": [
			"...........o.",
			"..........olo",
			"......o...omo",
			".....olo.olo.",
			".....omooomo.",
			"......olllo..",
			".oo...omoo...",
			"ollo..omo....",
			".oolo.omo....",
			"...ololo.ooo.",
			"....olmdolllo",
			"....olmdlooo.",
			"....olmdo....",
			"....olmdo....",
			"....olmdo....",
			"....olmdo....",
			"...ollmddo...",
			"....ooooo....",
		],
		"reeds": [
			"t..t...",
			"t..t.t.",
			"G.tGt..",
			"G..G.tG",
			"G.GG.G.",
			"gGgGGgG",
		],
		"grass": [
			"G.G.G",
			"gGgGg",
		],
		"pool": [
			"...PPPPPP...",
			".PPpppppppP.",
			"Pppppppppppp",
			".pppppppppp.",
			"...pppppp...",
		],
		"stone": [
			".oooo.",
			"oSSsso",
			"oSsseo",
			".oooo.",
		],
		"tomb": [
			"..ooo..",
			".oSSso.",
			"oSSsseo",
			"oSeeseo",
			"oSssseo",
			"oSssseo",
			"ooooooo",
		],
		"cross": [
			"..ooo..",
			"..oSo..",
			"oooSooo",
			"oSSSsso",
			"oooSooo",
			"..oSo..",
			"..oso..",
			"..oso..",
			"..ooo..",
		],
		"skull": [
			"..ooo..",
			".oBBBo.",
			"oBBBBbo",
			"oBoBobo",
			"oBBBBbo",
			".obBbo.",
			"..ooo..",
		],
		"crypt": [
			".......o.......",
			"......oSo......",
			".....oSSso.....",
			"....oSSSsso....",
			"...oSSSSssso...",
			"..ooooooooooo..",
			"..oSsoooooSeo..",
			"..oSsoooooSeo..",
			"..oSsoooooSeo..",
			"..oSsoooooSeo..",
			".ooooooooooooo.",
			".oSSSssssssseo.",
			"ooooooooooooooo",
		],
		"wisp": [
			".W.",
			"WwW",
			"wWw",
			".w.",
		],
		"ripple": [
			".PP.",
			"P..P",
		],
		"bubble": [
			".P.",
			"P.P",
			".P.",
		],
		"lily": [
			".GG",
			"Ggg",
			".g.",
		],
	},
	"lava": {
		"boulder": [
			"...oooo...",
			"..ollmmo..",
			".olmmmmdo.",
			"olmmmmddo.",
			"ommmmdddoo",
			"omdddddddo",
			".oooooooo.",
		],
		"rock": [
			"..ooo...",
			".olmmo..",
			"olmmddoo",
			"ommdddmo",
			".oooooo.",
		],
		"shard": [
			"...o..",
			"..oho.",
			"..ohoo",
			".ohloo",
			".ohloo",
			"ohlooo",
			"ohlooo",
			"oooooo",
		],
		"lavapool": [
			"..ooooooo..",
			".ocLLHLLco.",
			"ocLHWWHLLco",
			".ocLLHLLco.",
			"..ooooooo..",
		],
		"vent": [
			"....ooo....",
			"...ocWco...",
			"..omcHcmo..",
			".olmmcmmdo.",
			"olmmmmmmddo",
			"ooooooooooo",
		],
		"steam": [
			".hh..",
			"hhlh.",
			".llll",
			"..ll.",
		],
		"temple": [
			"ooooooooooooooooo",
			"ollllllllllllllmo",
			"ommmmmmmmmmmmmmdo",
			"ooooooooooooooooo",
			".olmo.......olmo.",
			".olmo.......olmo.",
			".olmo.......olmo.",
			".olmo.......olmo.",
			".olmo.......olmo.",
			".olmo.ooooo.olmo.",
			".olmo..omo..olmo.",
			".olmo..omo..olmo.",
			"ooooo.ooooo.ooooo",
		],
		"pillar_broken": [
			".o.oo.",
			"oloomo",
			"olmmmo",
			"olmmdo",
			"olmmdo",
			"olmmdo",
			"oooooo",
		],
		"block": [
			".ooooo.",
			"ollllmo",
			"ommmmdo",
			".ooooo.",
		],
		"flame0": [
			"...W...",
			"..WHW..",
			".LHWHL.",
			".LHHHL.",
			"..LLL..",
		],
		"flame1": [
			"..W....",
			"..HW.W.",
			".LHWHL.",
			".LHHHL.",
			"..LLL..",
		],
		"crust": [
			".qqq.",
			"qkkkq",
			"qkkq.",
			".qq..",
		],
		"crust_big": [
			"..qqqq.",
			".qkkkkq",
			"qkkkkkq",
			".qkkkq.",
			"..qqq..",
		],
		"hot": [
			"yy",
			"g.",
		],
		"streak": ["gyyyg"],
		"bubble": [
			".y.",
			"y.y",
			".y.",
		],
		"ember": ["H"],
		"pebble": ["mo"],
		"fissure": [
			"....oo...............",
			"..ooccoo..ooo........",
			".occLLccoocccoo..oo..",
			"ocLHccHLccHLHccoocco.",
			".occooccLWcccLLccWHco",
			"..oo..oocLcooccHLcco.",
			".......ocLco.ooccoo..",
			"........ocLco..oo....",
			".........oco.........",
			"..........o..........",
		],
		"fissure_b": [
			"................o...",
			".........oo...ooco..",
			"..oo...ooccoooccLco.",
			".occoooccWLcccHHco..",
			"ocLHcccLLccWHLcco...",
			".occLLHccooccLco....",
			"..oocccoo..oocLcoo..",
			"....ooo.....ocLLcco.",
			".............occHLco",
			"..............oocco.",
			"................oo..",
		],
	},
}

static var _textures: Dictionary = {}


## The bleed of the domain leading the battle on `field` (its `spawn_faction`), "" for none.
static func biome_of(field: Battlefield) -> String:
	if field == null or field.spawn_faction.is_empty():
		return ""
	return str(ContentDB.load_default().factions.get(field.spawn_faction, {}).get("bleed", ""))


## The tileset a bleed paints: its own, or the first domain's in content for a bleed with none.
static func key_of(biome: String) -> String:
	if TILESETS.has(biome):
		return biome
	for f in ContentDB.load_default().factions.values():
		if TILESETS.has(str(f.get("bleed", ""))):
			return str(f["bleed"])
	return str(TILESETS.keys()[0])


## The colour under a ground in a domain's tileset.
static func fill(biome: String, t: int) -> Color:
	var ts: Dictionary = TILESETS[key_of(biome)]
	return Color(str(ts["grounds"].get(t, ts["ground"])))


## Screen pixels a design pixel at a hex size: two at the map's.
static func scale_of(hex_px: float) -> int:
	return maxi(1, roundi(hex_px / 24.0))


## The roads beside a hex: a bit for each of Hex.DIRECTIONS whose neighbour is a road.
static func road_links(map: BattleMap, h: Vector2i) -> int:
	var links := 0
	for i in range(Hex.DIRECTIONS.size()):
		var n: Vector2i = h + Hex.DIRECTIONS[i]
		if (map.has(n) or map.margin.has(n)) and map.terrain_of(n) == BattleMap.Terrain.ROAD:
			links |= 1 << i
	return links


## One hex of the other world in a domain's tileset: its ground, and on it the domain's water
## or what stands on a decorative ground; a road runs to `links` (as road_links), across the
## hex when it has none. A wall hex's range is draw_ranges's, drawn after every hex's ground,
## since it stands taller than its hex. The second frame moves what moves. With `cell` off the
## hex has no outline of its own: ground with no cells, the scenery past the field (PaintedMap).
static func draw_hex(ci: CanvasItem, c: Vector2, hex_px: float, t: int, seed_value: int, frame: int, biome: String, links: int = 0, cell: bool = true) -> void:
	var key := key_of(biome)
	var ts: Dictionary = TILESETS[key]
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var s := scale_of(hex_px)
	var r := hex_px - 1.5
	var pts := MapOrient.corners(c, r)
	ci.draw_colored_polygon(pts, fill(key, t))
	match t:
		BattleMap.Terrain.WATER:
			_water(ci, key, ts, c, r, s, rng, frame)
		BattleMap.Terrain.MOUNTAIN:
			_specks(ci, ts, c, r, s, rng)
		BattleMap.Terrain.ROAD:
			_specks(ci, ts, c, r, s, rng)
			var road := links if links != 0 else (1 << 1) | (1 << 4)
			_road(ci, key, ts, c, hex_px, s, road)
			_scatter(ci, key, ts, c, r, s, rng, frame, _halved(ts["plain"]), road, 0.0)
		BattleMap.Terrain.ROUGH:
			_specks(ci, ts, c, r, s, rng)
			_scatter(ci, key, ts, c, r, s, rng, frame, ts["rough"], 0, 0.45)
		BattleMap.Terrain.RUINS:
			_specks(ci, ts, c, r, s, rng)
			_scatter(ci, key, ts, c, r, s, rng, frame, ts["ruins"], 0, 0.0)
		_:
			_specks(ci, ts, c, r, s, rng)
			_scatter(ci, key, ts, c, r, s, rng, frame, ts["plain"], 0, 0.0)
	if cell:
		Hud.stroke_poly(ci, pts, Color(Color(str(ts["grid"])), 0.35), 1.0)


## A wall in the painted world is one piece of a range that joins the wall hexes of its look
## beside it (Ryan, 16 November: "They could fill their hexes more and mesh together better. A
## mountain range should look like a continuous range, not a bunch of isolated chunks.
## Especially true for the gorge"). Each is a massif filling its hex, its top raised off the
## ground by its look's lift and running on into a joined neighbour's top with no edge between; a
## face drops to the ground only on a side where the range ends and the view sees it, and a dark
## edge rings the range only where it ends. On the top stands or lies what the look carries
## (RANGE_LOOKS): a crag's peaks, a city block's towers, a gorge's rocks and scrub; a crag's
## peaks stand on the line to each joined neighbour too, so a ridge runs on across its hexes.
## The walls are drawn by what they are (Ryan, 10 November: "The different spire types probably
## need to be represented in the painted world, for clarity"), told apart by their structure in
## every domain: crags peaks on a low base of rubble, mesas flat tops over banded faces, towers
## lit blocks on a plinth, cliffs a high plateau over cracked faces. Lit from the right as the
## domains' sprites are, in each domain's own inks (RANGE_INKS). Every wall of a map goes down in
## one call (draw_ranges): the bases, the farthest first; what lies on them; then what stands
## on them, each by its own foot, so a nearer peak stands in front of a farther one whatever hex
## each stands on.

## How each look of wall (BattleMap.WALL_LOOKS) stands, in design pixels: `lift`, how high its top
## stands off the ground; `lip`, whether the range's edge is broken rock or cut clean; `face`,
## what runs down its faces (rubble, strata, a plinth's band or cracks); `stands`, what stands
## on its top (peaks, towers or nothing); `lies`, how many rocks and tufts lie on a hex's top, at
## least and at most; `top`, `fleck` and `rim`, the inks (RANGE_INKS) of its top, the flecks in
## it and the lip where it breaks off over a face (a crag's base the dark rock of its base, so its
## peaks stand off it, unless that is the ground's own colour).
const RANGE_LOOKS := {
	"crags": {"lift": 5, "lip": "broken", "face": "rubble", "stands": "peaks", "lies": [0, 1], "top": "base", "fleck": "face_lo", "rim": "rock"},
	"mesas": {"lift": 10, "lip": "cut", "face": "strata", "stands": "", "lies": [1, 3], "top": "top", "fleck": "top_lo", "rim": "top_hi"},
	"towers": {"lift": 3, "lip": "cut", "face": "plinth", "stands": "towers", "lies": [0, 0], "top": "top", "fleck": "top_lo", "rim": "top_hi"},
	"cliffs": {"lift": 12, "lip": "broken", "face": "cracks", "stands": "", "lies": [1, 4], "top": "top", "fleck": "top_lo", "rim": "top_hi"},
}

## Each domain's rock for its walls, every colour one its own sprites are inked in (INKS, on the
## posterize grid): `out` the dark edge where a range ends; `top` the top, its light lip
## (`top_hi`) and its dark flecks (`top_lo`); a face lit, facing right (`face_hi`), and every other
## face (`face`); the darkest rock short of the edge (`face_lo`), a crack's, a mesa's dark band and
## a peak's shaded flank; `base` a crag's low base and a tower's face; `rock` a peak's and a
## tower's lit side. Each of a range's top, base and faces was picked by the three colourblind
## simulations against its domain's ground, the worst case kept (docs/measurements.md, 16
## November). `cap` and `cap_lo` top a peak (snow, a butte's pale top, a spire's light tip, lava);
## `lit` a lit window; `seam` what grows or glows in the rock's flecks and cracks (the Marsh's moss
## on its pale stone, the Peak's lava in its dark basalt; the rock's own dark elsewhere), so the two
## grey domains' walls differ by more than a crag's shape (Ryan, 30 October: "walls and water
## certainly should change with tileset"); `peak` the shape its crags stand up (a snowy mountain,
## a butte, a spire, a volcanic peak); `lies` its own sprites that lie on a top among the rocks.
const RANGE_INKS := {
	"plains": {"out": "333300", "top": "cccc99", "top_hi": "ffffcc", "top_lo": "cc9966", "face_hi": "663300", "face": "663300", "face_lo": "663300", "base": "663300", "rock": "cc9966", "cap": "ffffff", "cap_lo": "cccccc", "lit": "ffff99", "seam": "996633", "peak": "mountain", "lies": ["tuft_small", "tuft", "bloom_y"]},
	"sand": {"out": "330000", "top": "993300", "top_hi": "cc9966", "top_lo": "663300", "face_hi": "663300", "face": "663300", "face_lo": "330000", "base": "663300", "rock": "993300", "cap": "ffcc99", "cap_lo": "cc9966", "lit": "ffff99", "seam": "663300", "peak": "butte", "lies": ["pebble", "rock", "shrub"]},
	"marsh": {"out": "000000", "top": "999999", "top_hi": "cccccc", "top_lo": "666666", "face_hi": "666666", "face": "666666", "face_lo": "333333", "base": "666666", "rock": "999999", "cap": "cccccc", "cap_lo": "999999", "lit": "ffffcc", "seam": "669933", "peak": "spire", "lies": ["grass", "stone"]},
	"lava": {"out": "000000", "top": "666666", "top_hi": "999999", "top_lo": "333333", "face_hi": "993300", "face": "990000", "face_lo": "330000", "base": "666666", "rock": "999999", "cap": "ff9900", "cap_lo": "ffcc00", "lit": "ffff99", "seam": "ff9900", "peak": "volcanic", "lies": ["pebble", "shard"]},
}

## A crag's peaks by size, small to big, [half its base's width, its height] in design pixels, by
## the shape its domain stands up.
const PEAK_SIZES := {
	"mountain": [[6, 13], [10, 21], [13, 31]],
	"butte": [[4, 13], [6, 20], [8, 28]],
	"spire": [[3, 14], [4, 22], [6, 31]],
	"volcanic": [[6, 13], [10, 21], [13, 31]],
}

static var _ranges: Dictionary = {}   # a wall's base by everything it depends on (_range_base)
static var _noise := PackedByteArray()   # a 64 by 64 tile of _rhash, for the flecks and the cracks without a call a pixel


## The noise tile at a design pixel, with a salt shifting it.
static func _noise_at(x: int, y: int, salt: int) -> int:
	if _noise.is_empty():
		_noise.resize(64 * 64)
		for i in range(64 * 64):
			_noise[i] = _rhash(i % 64, i / 64, 101)
	return _noise[((y + salt * 17) & 63) * 64 + ((x + salt * 31) & 63)]


## The wall hexes beside `h` of its own look, as a bit for each of Hex.DIRECTIONS: the neighbours
## its range joins, on the field or in the scenery past it.
static func wall_links(map: BattleMap, h: Vector2i) -> int:
	var look := str(map.wall_look.get(h, ""))
	var links := 0
	for i in range(Hex.DIRECTIONS.size()):
		var n: Vector2i = h + Hex.DIRECTIONS[i]
		if (map.has(n) or map.margin.has(n)) and map.terrain_of(n) == BattleMap.Terrain.MOUNTAIN and str(map.wall_look.get(n, "")) == look:
			links |= 1 << i
	return links


## Every wall of a painted map, in one go: `walls`, each {"c": its hex's middle, "seed": int,
## "look": a BattleMap.WALL_LOOKS word, "links": wall_links, "tint": what multiplies its colours
## (the scenery's shade)}. The bases go down first, the farthest (highest on screen) first, so a
## nearer top laps over the foot of a farther range; then what lies on the tops; then what stands
## on them, each by its own foot.
static func draw_ranges(ci: CanvasItem, walls: Array, hex_px: float, frame: int, biome: String) -> void:
	var key := key_of(biome)
	var s := scale_of(hex_px)
	var order := walls.duplicate()
	order.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var pa: Vector2 = a["c"]
		var pb: Vector2 = b["c"]
		return pa.y < pb.y or (is_equal_approx(pa.y, pb.y) and pa.x < pb.x))
	var lies: Array = []
	var stands: Array = []
	for w in order:
		var look := str(w.get("look", "crags"))
		if not RANGE_LOOKS.has(look):
			look = "crags"
		var links := int(w.get("links", 0))
		var tint: Color = w.get("tint", Color.WHITE)
		var at: Vector2 = (w["c"] as Vector2).floor()
		var base := _range_base(key, look, links, hex_px, s)
		ci.draw_texture(base["tex"], at + base["at"], tint)
		var rng := RandomNumberGenerator.new()
		rng.seed = int(w.get("seed", 0))
		for p in _range_props(key, look, links, hex_px, s, rng):
			p["origin"] = at
			p["tint"] = tint
			(lies if bool(p["lies"]) else stands).append(p)
	for p in lies:
		_draw_range_prop(ci, key, p, s, frame)
	stands.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var fa: Vector2 = (a["origin"] as Vector2) + (a["foot"] as Vector2) * a["s"]
		var fb: Vector2 = (b["origin"] as Vector2) + (b["foot"] as Vector2) * b["s"]
		return fa.y < fb.y or (is_equal_approx(fa.y, fb.y) and fa.x < fb.x))
	for p in stands:
		_draw_range_prop(ci, key, p, s, frame)


static func _draw_range_prop(ci: CanvasItem, key: String, p: Dictionary, s: int, frame: int) -> void:
	var origin: Vector2 = p["origin"]
	var tint: Color = p["tint"]
	ci.draw_texture(p["tex"], origin + (p["at"] as Vector2) * s, tint)
	if p.has("steam"):
		# A crater's steam rises a step a frame, as the vents' does (ATTACH).
		var tex := _tex(key, "steam", false, s)
		var top: Vector2 = p["steam"]
		ci.draw_texture(tex, (origin + (top + Vector2(-2.0, -5.0 - 2.0 * frame)) * s).floor(), tint)


## A hex's edges in design pixels about its middle, in the view's layout (MapOrient): each {"a",
## "b": its corners, "n": its outward normal, "d": the middle's distance to it, "dir": the index
## in Hex.DIRECTIONS of the neighbour across it, "toward": that neighbour's middle}.
static func _hex_edges(r: float) -> Array:
	var pts := MapOrient.corners(Vector2.ZERO, r)
	var out: Array = []
	for i in range(6):
		var a := pts[i]
		var b := pts[(i + 1) % 6]
		var mid := (a + b) * 0.5
		var best := 0
		var best_dot := -INF
		for k in range(6):
			var v := MapOrient.to_pixel(Hex.DIRECTIONS[k], r)
			if v.dot(mid) > best_dot:
				best_dot = v.dot(mid)
				best = k
		out.append({"a": a, "b": b, "n": mid.normalized(), "d": mid.length(), "dir": best, "toward": MapOrient.to_pixel(Hex.DIRECTIONS[best], r)})
	return out


## A cheap hash of design-pixel coordinates and a salt, 0 to 255, so a pattern is the same every
## time it is drawn.
static func _rhash(x: int, y: int, salt: int = 0) -> int:
	var hv := (x * 73856093) ^ (y * 19349663) ^ (salt * 83492791)
	hv = (hv ^ (hv >> 13)) * 1274126177
	return (hv ^ (hv >> 16)) & 255


const RANGE_COLOURS := ["out", "top", "top_hi", "top_lo", "face_hi", "face", "face_lo", "base", "rock", "cap", "cap_lo", "lit", "seam"]


## A domain's range inks, its colours as colours.
static func _range_inks(key: String) -> Dictionary:
	var src: Dictionary = RANGE_INKS.get(key, RANGE_INKS["plains"])
	var out := src.duplicate()
	for k in RANGE_COLOURS:
		out[k] = Color(str(src[k]))
	return out


## One shade darker, down the range's ramp of inks: lit face, face, shaded face, the edge (a
## step the domain's ramp shares skipped, so a crack always shows).
static func _darker(ink: Dictionary, c: Color) -> Color:
	for k in ["face_hi", "face", "face_lo"]:
		if c == ink[k]:
			var i := ["face_hi", "face", "face_lo", "out"].find(k) + 1
			while i < 3 and ink[["face_hi", "face", "face_lo", "out"][i]] == c:
				i += 1
			return ink[["face_hi", "face", "face_lo", "out"][i]]
	return ink["out"]


## One wall's base: the massif in its hex, its top lifted by its look's lift, faced where the range
## ends toward the view, edged where it ends at all, and joined to the walls beside it in `links`
## (bits over Hex.DIRECTIONS); cached by everything it depends on, so a range's middle hexes
## share one. {"tex": ImageTexture, "at": its top left from the hex's middle in screen pixels}.
## Built in packed arrays, a row's span at a time where it can be: a battle paints every one
## before its first turn.
static func _range_base(key: String, look: String, links: int, hex_px: float, s: int) -> Dictionary:
	var ck := "%s/%s/%d/%d/%d/%d" % [key, look, links, roundi(hex_px * 4.0), s, int(MapOrient.wall_left)]
	if _ranges.has(ck):
		return _ranges[ck]
	var r := hex_px / float(s)
	var style: Dictionary = RANGE_LOOKS[look]
	var lift := int(style["lift"])
	var broken := str(style["lip"]) == "broken"
	var pattern := str(style["face"])
	var ink := _range_inks(key)
	var edges := _hex_edges(r)
	var nx := PackedFloat32Array()
	var ny := PackedFloat32Array()
	var dd := PackedFloat32Array()    # the middle's distance to each edge
	var lim := PackedFloat32Array()   # each edge's limit for the top, a pixel past it toward a joined neighbour
	var ax := PackedFloat32Array()
	var ay := PackedFloat32Array()
	var bx := PackedFloat32Array()
	var by := PackedFloat32Array()
	var joined := PackedByteArray()
	var on_x := PackedFloat32Array()  # the joined neighbours' middles
	var on_y := PackedFloat32Array()
	for e in edges:
		var n: Vector2 = e["n"]
		nx.append(n.x)
		ny.append(n.y)
		dd.append(float(e["d"]))
		var j := (links & (1 << int(e["dir"]))) != 0
		joined.append(1 if j else 0)
		lim.append(float(e["d"]) + (1.0 if j else 0.0))
		ax.append((e["a"] as Vector2).x)
		ay.append((e["a"] as Vector2).y)
		bx.append((e["b"] as Vector2).x)
		by.append((e["b"] as Vector2).y)
		if j:
			on_x.append((e["toward"] as Vector2).x)
			on_y.append((e["toward"] as Vector2).y)
	var x0 := floori(-r) - 2
	var y0 := floori(-r) - lift - 2
	var w := ceili(r) + 3 - x0
	var h := ceili(r) + 3 - y0
	var fl := float(lift)
	var cls := PackedByteArray()   # 0 nothing, 1 the top, 2 a face
	cls.resize(w * h)
	var fe := PackedByteArray()    # a face pixel's edge
	fe.resize(w * h)
	var fv := PackedByteArray()    # a face pixel's height above the ground
	fv.resize(w * h)
	# The top: the hex lifted, row by row, each row the span every edge allows.
	for py in range(h):
		var y := float(y0 + py) + 0.5 + fl
		var lo := -INF
		var hi := INF
		for k in range(6):
			var rest := lim[k] - ny[k] * y
			if nx[k] > 0.001:
				hi = minf(hi, rest / nx[k])
			elif nx[k] < -0.001:
				lo = maxf(lo, rest / nx[k])
			elif rest < 0.0:
				hi = -INF
		var a := maxi(0, ceili(lo - float(x0) - 0.5))
		var b := mini(w - 1, floori(hi - float(x0) - 0.5))
		for px in range(a, b + 1):
			cls[py * w + px] = 1
	# The faces: down from the lifted edge to the ground, on each edge the range ends at and the
	# view sees (its normal down the screen), never edge-on; each over its own columns and rows.
	for k in range(6):
		if joined[k] == 1 or ny[k] < 0.2 or absf(bx[k] - ax[k]) < 0.01:
			continue
		var c0 := maxi(0, floori(minf(ax[k], bx[k])) - x0 - 1)
		var c1 := mini(w - 1, ceili(maxf(ax[k], bx[k])) - x0 + 1)
		for px in range(c0, c1 + 1):
			var x := float(x0 + px) + 0.5
			var t := (x - ax[k]) / (bx[k] - ax[k])
			if t < 0.0 or t > 1.0:
				continue
			var ye := lerpf(ay[k], by[k], t)
			var r0 := maxi(0, floori(ye - fl) - y0 - 1)
			var r1 := mini(h - 1, ceili(ye) - y0 + 1)
			for py in range(r0, r1 + 1):
				var y := float(y0 + py) + 0.5
				if y > ye or y < ye - fl:
					continue
				var i := py * w + px
				if cls[i] == 1:
					continue
				cls[i] = 2
				fe[i] = k
				fv[i] = clampi(int(ye - y), 0, 255)
	# A broken lip: the range's edge bitten back a pixel or two in runs, a bite in a seen edge
	# showing the face behind it, one in a far edge the ground; each edge over the band along it.
	if broken:
		for k in range(6):
			if joined[k] == 1:
				continue
			var c0 := maxi(0, floori(minf(ax[k], bx[k])) - x0 - 3)
			var c1 := mini(w - 1, ceili(maxf(ax[k], bx[k])) - x0 + 3)
			var r0 := maxi(0, floori(minf(ay[k], by[k]) - fl) - y0 - 3)
			var r1 := mini(h - 1, ceili(maxf(ay[k], by[k]) - fl) - y0 + 3)
			var seen := ny[k] >= 0.2 and absf(nx[k]) < 0.99
			for py in range(r0, r1 + 1):
				var qy := float(y0 + py) + 0.5 + fl
				for px in range(c0, c1 + 1):
					var i := py * w + px
					if cls[i] != 1:
						continue
					var qx := float(x0 + px) + 0.5
					var inside := lim[k] - (qx * nx[k] + qy * ny[k])
					if inside >= 2.0:
						continue
					var bite := _rhash(floori((qx * ny[k] - qy * nx[k]) * 0.5), k, links + 7) % 3
					if inside < float(bite):
						if seen and py + 1 < h:
							cls[i] = 2
							fe[i] = k
							fv[i] = lift
						else:
							cls[i] = 0
	# The colours, and the edge: where the range ends, a pixel of its dark ink round it, never
	# where it goes on into a joined neighbour (on the ground there or lifted). Whether an empty
	# pixel is the range going on is asked once, kept in `on` (0 not yet asked, 1 it goes on, 2 not).
	_noise_at(0, 0, 0)
	var on := PackedByteArray()
	on.resize(w * h)
	var data := PackedByteArray()
	data.resize(w * h * 4)
	# A top in the ground's own colour would vanish into it (the Peak's darker rock is its ground):
	# it takes the rock's main colour there.
	var top_ink: Color = ink[str(style["top"])]
	if top_ink == Color(str(TILESETS[key]["ground"])):
		top_ink = ink["top"]
	var c_top := top_ink.to_abgr32()
	var c_rim := (ink[str(style["rim"])] as Color).to_abgr32()
	var c_fleck := (ink[str(style["fleck"])] as Color).to_abgr32()
	var c_out := (ink["out"] as Color).to_abgr32()
	var c_hi := (ink["face_hi"] as Color).to_abgr32()
	var c_top_hi := (ink["top_hi"] as Color).to_abgr32()
	var c_seam := (ink["seam"] as Color).to_abgr32()
	var tones := PackedInt64Array()   # each edge's face: lit facing right, shaded facing left
	var darks := PackedInt64Array()   # and one shade darker
	var pales := PackedInt64Array()   # and a mesa's pale band
	for k in range(6):
		# A face lit facing right, the rest the face's own: the shaded rock is the cracks' and the
		# peaks' (a face as dark as that read as the ground in the simulations, 16 November).
		var tone: Color = ink["face_hi"] if nx[k] > 0.3 else ink["face"]
		tones.append(tone.to_abgr32())
		darks.append(_darker(ink, tone).to_abgr32())
		pales.append((ink["top"] if tone != ink["top"] else ink["top_hi"]).to_abgr32())
	var flecks := 12 if pattern == "cracks" or pattern == "rubble" else 5
	var edge := PackedByteArray()
	edge.resize(w * h)
	for py in range(h):
		for px in range(w):
			var i := py * w + px
			var cl := cls[i]
			if cl == 0:
				continue
			# The edge first: any side of it empty and not the range going on.
			var is_edge := false
			var border := px == 0 or py == 0 or px == w - 1 or py == h - 1 or cls[i - 1] == 0 or cls[i + 1] == 0 or cls[i - w] == 0 or cls[i + w] == 0
			if border:
				for d in range(4):
					var qx := px + (1 if d == 0 else (-1 if d == 1 else 0))
					var qy := py + (1 if d == 2 else (-1 if d == 3 else 0))
					var inside := qx >= 0 and qy >= 0 and qx < w and qy < h
					if inside and cls[qy * w + qx] != 0:
						continue
					var known := on[qy * w + qx] if inside else 0
					if known == 0:
						known = 2
						var gx := float(x0 + qx) + 0.5
						var gy := float(y0 + qy) + 0.5
						for m in range(on_x.size()):
							var ux := gx - on_x[m]
							var uy := gy - on_y[m]
							var hit_ground := true
							var hit_top := true
							for k in range(6):
								var dp := ux * nx[k] + uy * ny[k]
								if dp > dd[k]:
									hit_ground = false
								if dp + fl * ny[k] > dd[k]:
									hit_top = false
							if hit_ground or hit_top:
								known = 1
								break
						if inside:
							on[qy * w + qx] = known
					if known == 2:
						is_edge = true
						break
			var col := c_out
			if is_edge:
				edge[i] = 1
			elif cl == 1:
				col = c_top
				if py + 1 < h and cls[i + w] == 2:
					col = c_rim   # the lip catches the light
				elif not border:   # no fleck on a top's outer pixel, so none is cut where two tops meet
					var f := _noise_at(x0 + px, y0 + py, 1)
					if f < flecks:
						col = c_seam if f < flecks / 3 else c_fleck
			else:
				var gx := x0 + px
				var gy := y0 + py
				var k := fe[i]
				var v := int(fv[i])
				col = tones[k]
				var crease := py > 0 and cls[i - w] == 1
				match pattern:
					"cracks":
						# Cracks down the cliff, each from the lip a run of its own length.
						if crease:
							col = c_out
						elif _noise_at(gx, k, 5) < 70 and v >= lift - 3 - _noise_at(gx, k, 11) % (lift - 2):
							col = c_seam if _noise_at(gx, k, 7) < 60 and v < lift - 1 else darks[k]
						elif _noise_at(gx, gy, 9) < 18:
							col = darks[k]
					"strata":
						# Bands in the rock, two pixels each, dark, the face's own and pale in turn.
						var band := (v / 2) % 3
						if crease:
							col = c_out
						elif band == 0:
							col = darks[k]
						elif band == 2:
							col = pales[k]
					"plinth":
						if crease:
							col = c_top_hi
						elif v <= 1:
							col = darks[k]
					_:
						# Rubble: the rock broken into lumps, dark and light flecks.
						var f := _noise_at(gx, gy, 13)
						if crease or f < 60:
							col = darks[k]
						elif f > 225:
							col = c_hi
			data.encode_u32(i * 4, col)
	# A mesa's flat top catches the light all round, a pixel inside its edge.
	if pattern == "strata":
		for py in range(1, h - 1):
			for px in range(1, w - 1):
				var i := py * w + px
				if cls[i] == 1 and edge[i] == 0 and (edge[i - 1] == 1 or edge[i + 1] == 1 or edge[i - w] == 1 or edge[i + w] == 1):
					data.encode_u32(i * 4, c_top_hi)
	var img := Image.create_from_data(w, h, false, Image.FORMAT_RGBA8, data)
	if s > 1:
		img.resize(w * s, h * s, Image.INTERPOLATE_NEAREST)
	var out := {"tex": ImageTexture.create_from_image(img), "at": Vector2(x0 * s, y0 * s)}
	_ranges[ck] = out
	return out


## What lies and stands on one wall's top, in design pixels about its hex's middle (`at` a
## texture's top left, `foot` where it stands): a crag's peaks, the one in the middle the tallest
## and one on the line to each joined neighbour, so the ridge runs on; a city block's towers on a
## grid filling the top; the rocks and the domain's own scrub lying about. Seeded by the hex, so a
## wall dresses the same every time.
static func _range_props(key: String, look: String, links: int, hex_px: float, s: int, rng: RandomNumberGenerator) -> Array:
	var r := hex_px / float(s)
	var style: Dictionary = RANGE_LOOKS[look]
	var lift := float(style["lift"])
	var ink := _range_inks(key)
	var edges := _hex_edges(r)
	var out: Array = []
	# Whether a spot on the ground of the hex keeps `keep` clear of the range's open edges (a
	# pixel from a joined one), and the spot pulled toward the middle until it does.
	var fits := func(q: Vector2, keep: float) -> bool:
		for e in edges:
			var room := keep if (links & (1 << int(e["dir"]))) == 0 else 1.0
			if q.dot(e["n"]) > float(e["d"]) - room:
				return false
		return true
	var held := func(p: Vector2, keep: float) -> Vector2:
		var q := p
		for step in range(12):
			if fits.call(q, keep):
				return q
			q *= 0.85
		return q
	match str(style["stands"]):
		"peaks":
			var shape := str(ink["peak"])
			var sizes: Array = PEAK_SIZES[shape]
			var spots: Array = [[Vector2(rng.randf_range(-2.0, 2.0), rng.randf_range(-4.0, -1.0)), 2]]
			var joined := 0
			for e in edges:
				if links & (1 << int(e["dir"])):
					joined += 1
					# The saddle on a joined edge carries one peak, the hex on its first three
					# directions' side standing it, so the ridge runs tall, saddle, tall.
					if int(e["dir"]) < 3:
						spots.append([(e["toward"] as Vector2) * 0.46 + Vector2(rng.randf_range(-0.75, 0.75), rng.randf_range(-0.75, 0.75)), 1])
			if joined < 2:
				spots.append([Vector2(-r * 0.45, r * 0.2), 1 if joined == 0 else 0])
				spots.append([Vector2(r * 0.45, r * 0.24), 0])
			if joined < 5:
				spots.append([Vector2(rng.randf_range(-3.0, 3.0), r * 0.5), 0])
			var crater := shape == "volcanic" and rng.randf() < 0.3
			for sp in spots:
				var size: int = sp[1]
				var hw := int(sizes[size][0])
				var ht := int(round(float(sizes[size][1]) * rng.randf_range(0.9, 1.1)))
				var g: Vector2 = held.call(sp[0], float(hw) * 0.6 + 1.0)
				var foot := (g - Vector2(0.0, lift)).round()
				var steam := crater and size == 2
				var tex := _peak_tex(key, shape, hw, ht, rng.randi_range(0, 3), steam, s)
				var p := {"lies": false, "foot": foot, "tex": tex, "at": foot - Vector2(float(hw + 1), float(ht)), "s": s}
				if steam:
					p["steam"] = foot - Vector2(0.0, float(ht))
				out.append(p)
		"towers":
			var tall := 0
			for e in edges:
				if links & (1 << int(e["dir"])):
					tall += 1
			for gy in [-0.62, 0.0, 0.62]:
				for gx in [-1.5, -0.5, 0.5, 1.5]:
					var g := Vector2(gx * r * 0.48 + rng.randf_range(-1.5, 1.5), gy * r * 0.62 + rng.randf_range(-1.5, 1.5))
					if not fits.call(g, 4.0) or rng.randf() < 0.2:
						continue
					var tw: int = [5, 7, 9][rng.randi_range(0, 2)]
					var lo := 10 + tall * 2
					var ht := rng.randi_range(lo, lo + 14)
					# A tower at the back of a block stands short, so the street behind it still
					# shows: no taller than the block's top runs back from it, and a few pixels more.
					for e in edges:
						var n: Vector2 = e["n"]
						if n.y > -0.2 or (links & (1 << int(e["dir"]))) != 0:
							continue
						var back := (g.dot(n) - float(e["d"])) / n.y   # straight up to the open edge
						var hit := g - Vector2(0.0, back)
						var ea: Vector2 = e["a"]
						var eb: Vector2 = e["b"]
						if hit.x >= minf(ea.x, eb.x) - 2.0 and hit.x <= maxf(ea.x, eb.x) + 2.0:
							ht = mini(ht, maxi(6, int(back) + 6))
					var broken := rng.randf() < 0.25
					var foot := (g - Vector2(0.0, lift)).round()
					ht = maxi(6, (ht / 3) * 3)
					var tex := _tower_tex(key, tw, ht, broken, rng.randi_range(0, 1), s)
					out.append({"lies": false, "foot": foot, "tex": tex, "at": foot - Vector2(float(tw / 2 + 1), float(ht + 3)), "s": s})
	var span: Array = style["lies"]
	var lying := rng.randi_range(int(span[0]), int(span[1]))
	var names: Array = ink["lies"]
	for n in range(lying):
		var g: Vector2 = held.call(Vector2(rng.randf_range(-r * 0.8, r * 0.8), rng.randf_range(-r * 0.75, r * 0.75)), 4.0)
		var foot := (g - Vector2(0.0, lift)).round()
		var tex: ImageTexture
		var pick := rng.randf()
		if look == "cliffs" and pick < 0.35:
			tex = _crack_tex(key, rng.randi_range(0, 3), s)
		elif pick < 0.6:
			tex = _boulder_tex(key, rng.randi_range(0, 2), s)
		else:
			var name := str(names[rng.randi_range(0, names.size() - 1)])
			tex = _tex(key, name, rng.randf() < 0.5, s)
		var size := tex.get_size() / float(s)
		out.append({"lies": true, "foot": foot, "tex": tex, "at": (foot - Vector2(floorf(size.x * 0.5), size.y)).round(), "s": s})
	return out


## A crag's peak, standing on its foot at the bottom middle, in its domain's shape: a mountain
## with snow on its top third, a butte with a pale top and banded sides, a needle of a spire, a
## jagged volcanic peak with lava down it (`crater`, a cone breathing steam). Lit from the right.
static func _peak_tex(key: String, shape: String, hw: int, ht: int, variant: int, crater: bool, s: int) -> ImageTexture:
	var ck := "%s/peak/%s/%d/%d/%d/%d/%d" % [key, shape, hw, ht, variant, int(crater), s]
	if _textures.has(ck):
		return _textures[ck]
	var ink := _range_inks(key)
	var lit: Color = ink["rock"]
	var mid: Color = ink["face_hi"]
	var shade: Color = ink["face_lo"] if ink["face_lo"] != ink["out"] else ink["face"]
	var w := 2 * hw + 3
	var h := ht + 1
	var cx := hw + 1
	var img := Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
	var spans: Array = []   # each row's [left, right]
	for y in range(h):
		var f := float(y) / float(maxi(1, ht - 1))
		var half := f * float(hw)
		match shape:
			"butte":
				var top := maxf(2.0, float(hw) * 0.62)
				half = top + (maxf(0.0, f - 0.72) / 0.28) * (float(hw) - top)
			"spire":
				half = f * float(hw) + (0.5 if (y + variant) % 3 == 0 else 0.0)
			"volcanic":
				half = f * float(hw) + (1.0 if _rhash(y, variant, 21) < 70 and y > 2 else 0.0)
				if crater:
					half = maxf(half, 2.0)
			_:
				half = f * float(hw) + (0.6 if _rhash(y, variant, 23) < 60 and y > 3 else 0.0)
		spans.append([clampi(cx - int(round(half)), 0, w - 1), clampi(cx + int(round(half)), 0, w - 1)])
	var cap_rows := 0
	match shape:
		"mountain":
			cap_rows = int(round(float(ht) * 0.32)) if ht >= 15 else 0
		"butte":
			cap_rows = 2
		"spire":
			cap_rows = 2
		"volcanic":
			cap_rows = 1 if crater else 0
	for y in range(h):
		var l: int = spans[y][0]
		var rr: int = spans[y][1]
		# The ridge line parting the shaded left flank from the lit right, leaning left as it
		# falls; a butte's flat sides part in thirds.
		var f := float(y) / float(maxi(1, ht - 1))
		var ridge := cx - int(round(f * float(hw) * 0.3))
		if shape == "butte":
			ridge = l + int(round(float(rr - l) * 0.35))
		for x in range(l, rr + 1):
			var col: Color = lit if x >= ridge else shade
			if shape == "spire" and x > l and x < rr:
				col = mid if x < rr - 1 else lit
				if x <= l + 1:
					col = shade
			var jag := _rhash(x, variant, 29) % 2
			if y < cap_rows + jag and shape == "mountain":
				col = ink["cap"] if x >= ridge else ink["cap_lo"]
			elif y < cap_rows and shape == "butte":
				col = ink["cap"] if y == 0 else ink["cap_lo"]
			elif y < cap_rows and shape == "spire":
				col = ink["cap"]
			elif y < cap_rows and crater:
				col = ink["cap_lo"]
			elif shape == "butte" and y > cap_rows and (y - cap_rows) % 4 == 0 and _rhash(x, y, variant) < 150:
				col = mid if col == lit else ink["out"]
			elif shape != "butte" and shape != "spire" and x > ridge + 1 and _rhash(x - y, variant, 31) < 26:
				col = mid   # a crease down the lit flank
			img.set_pixel(x, y, col)
		img.set_pixel(l, y, ink["out"])
		img.set_pixel(rr, y, ink["out"])
	img.set_pixel(cx, 0, ink["out"])
	if shape == "butte":
		for x in range(spans[0][0], spans[0][1] + 1):
			img.set_pixel(x, 0, ink["out"])
	# Lava down a volcanic peak's lit flank: a glowing thread from near its top.
	if shape == "volcanic" and (crater or variant == 0) and ht >= 15:
		var x := cx + 1
		for y in range(2, ht - 1):
			if _rhash(y, variant, 37) < 90:
				x += 1 if _rhash(y, variant, 41) < 128 else -1
			x = clampi(x, spans[y][0] + 1, spans[y][1] - 1)
			img.set_pixel(x, y, ink["cap"] if y % 3 != 0 else ink["cap_lo"])
	if s > 1:
		img.resize(w * s, h * s, Image.INTERPOLATE_NEAREST)
	var tex := ImageTexture.create_from_image(img)
	_textures[ck] = tex
	return tex


## A tower of a city block, standing on its foot at the bottom middle: its roof (a ruin's broken
## off in steps), its face of windows, some lit, its right side catching the light.
static func _tower_tex(key: String, tw: int, ht: int, broken: bool, variant: int, s: int) -> ImageTexture:
	var ck := "%s/tower/%d/%d/%d/%d/%d" % [key, tw, ht, int(broken), variant, s]
	if _textures.has(ck):
		return _textures[ck]
	var ink := _range_inks(key)
	var front: Color = ink["base"]
	var side: Color = ink["rock"]
	var dark: Color = ink["face_lo"] if ink["face_lo"] != front else ink["out"]
	var d := 3   # the roof, seen from above
	var w := tw + 2
	var h := ht + d + 1
	var img := Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
	var tops: Array = []   # each column's top row
	for x in range(w):
		var t := 0
		if broken and x > 0 and x < w - 1:
			t = _rhash(x / 2, variant, 43) % 4
		tops.append(t)
	for x in range(w):
		for y in range(int(tops[x]), h):
			var col: Color = front
			if x == 0 or x == w - 1 or y == int(tops[x]):
				col = ink["out"]
			elif y < d and not broken:
				col = ink["top_hi"]   # the roof
			elif y == d and not broken:
				col = ink["out"]
			elif x >= w - 1 - maxi(1, tw / 3):
				col = side   # the lit side
				if (y - d) % 3 == 2 and x % 2 == 0 and y < h - 2:
					col = front
			elif (y - d) % 3 == 2 and x % 2 == 1 and y < h - 2 and y > d:
				col = ink["lit"] if _rhash(x, y, variant) < 90 else dark
			img.set_pixel(x, y, col)
	for x in range(w):
		img.set_pixel(x, h - 1, ink["out"])
	if s > 1:
		img.resize(w * s, h * s, Image.INTERPOLATE_NEAREST)
	var tex := ImageTexture.create_from_image(img)
	_textures[ck] = tex
	return tex


## A crack running across a plateau's top: a dark line wandering a pixel at a time, its far lip
## catching the light.
static func _crack_tex(key: String, variant: int, s: int) -> ImageTexture:
	var ck := "%s/crack/%d/%d" % [key, variant, s]
	if _textures.has(ck):
		return _textures[ck]
	var ink := _range_inks(key)
	var w := 7 + variant * 2
	var img := Image.create_empty(w, 5, false, Image.FORMAT_RGBA8)
	var y := 2
	for x in range(w):
		if x > 0 and _rhash(x, variant, 47) < 100:
			y = clampi(y + (1 if _rhash(x, variant, 53) < 128 else -1), 1, 3)
		img.set_pixel(x, y, ink["top_lo"])
		img.set_pixel(x, y + 1, ink["top_hi"])
	if s > 1:
		img.resize(w * s, 5 * s, Image.INTERPOLATE_NEAREST)
	var tex := ImageTexture.create_from_image(img)
	_textures[ck] = tex
	return tex


## A loose rock lying on a range's top, in the top's own flecks and light, lit from the right: 0 a
## pebble, 1 a stone, 2 a boulder.
static func _boulder_tex(key: String, size: int, s: int) -> ImageTexture:
	var ck := "%s/boulder/%d/%d" % [key, size, s]
	if _textures.has(ck):
		return _textures[ck]
	var ink := _range_inks(key)
	var rows: Array = [
		[".oo.", "oxlo", ".oo."],
		[".ooo.", "oxllo", "oxxlo", ".ooo."],
		["..ooo..", ".oxlllo", "oxxxllo", "oxxxxlo", ".ooooo."],
	][clampi(size, 0, 2)]
	var w := str(rows[0]).length()
	var img := Image.create_empty(w, rows.size(), false, Image.FORMAT_RGBA8)
	for y in range(rows.size()):
		for x in range(w):
			var ch := str(rows[y])[x]
			if ch == "o":
				img.set_pixel(x, y, ink["out"])
			elif ch == "x":
				img.set_pixel(x, y, ink["top_lo"])
			elif ch == "l":
				img.set_pixel(x, y, ink["top_hi"])
	if s > 1:
		img.resize(w * s, rows.size() * s, Image.INTERPOLATE_NEAREST)
	var tex := ImageTexture.create_from_image(img)
	_textures[ck] = tex
	return tex


## A sprite as a texture, its letters inked in the domain's colours, `s` pixels a letter.
static func _tex(key: String, name: String, mirror: bool, s: int) -> ImageTexture:
	var ck := "%s/%s/%d/%d" % [key, name, int(mirror), s]
	if _textures.has(ck):
		return _textures[ck]
	var rows: Array = SPRITES[key][name]
	var ink: Dictionary = INKS[key]
	var w := 0
	for row in rows:
		w = maxi(w, str(row).length())
	var img := Image.create_empty(w * s, rows.size() * s, false, Image.FORMAT_RGBA8)
	for y in range(rows.size()):
		var row: String = rows[y]
		for x in range(row.length()):
			if row[x] != ".":
				img.fill_rect(Rect2i(x * s, y * s, s, s), Color(str(ink[row[x]])))
	if mirror:
		img.flip_x()
	var tex := ImageTexture.create_from_image(img)
	_textures[ck] = tex
	return tex


## Whether a point lies inside a pointy-top hex of circumradius `r` about `c`.
static func _inside(p: Vector2, c: Vector2, r: float) -> bool:
	var d := (p - c).abs()
	return d.x <= r * sqrt(3.0) * 0.5 and d.y <= r - d.x / sqrt(3.0)


## Whether a sprite's rect stands inside the hex, clear of its edge.
static func _fits(rect: Rect2, c: Vector2, r: float) -> bool:
	for p in [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]:
		if not _inside(p, c, r - 2.0):
			return false
	return true


## A list of what stands on a ground at half its numbers, for the hex a road runs through.
static func _halved(list: Array) -> Array:
	var out: Array = []
	for e in list:
		out.append([e[0], ceili(int(e[1]) * 0.5), e[2] if e.size() > 2 else 1.0])
	return out


## A ground's flecks: a few design pixels in the domain's speck colours.
static func _specks(ci: CanvasItem, ts: Dictionary, c: Vector2, r: float, s: int, rng: RandomNumberGenerator) -> void:
	var cols: Array = ts["specks"]
	for i in range(10):
		var p := c + Vector2(rng.randf_range(-0.85, 0.85) * r * 0.866, rng.randf_range(-0.8, 0.8) * r)
		if _inside(p, c, r - 3.0):
			ci.draw_rect(Rect2(p.floor(), Vector2(s, s)), Color(str(cols[i % cols.size()])))


## The midpoint of a hex's edge toward Hex.DIRECTIONS[i], on the hex's fill.
static func _edge_mid(i: int, hex_px: float) -> Vector2:
	return MapOrient.to_pixel(Hex.DIRECTIONS[i], hex_px) * 0.5 * (hex_px - 1.5) / hex_px


## The road's ends: the midpoints of the edges it runs to.
static func _road_ends(hex_px: float, links: int) -> Array:
	var ends: Array = []
	for i in range(Hex.DIRECTIONS.size()):
		if links & (1 << i):
			ends.append(_edge_mid(i, hex_px))
	return ends


static func _seg_dist(p: Vector2, b: Vector2) -> float:
	var t := clampf(p.dot(b) / b.length_squared(), 0.0, 1.0)
	return p.distance_to(b * t)


## How far a point (from the hex's middle) stands from the road.
static func _road_dist(p: Vector2, ends: Array) -> float:
	var d := INF
	for e in ends:
		d = minf(d, _seg_dist(p, e))
	return d


## The road through a hex, from its middle to each edge in `links`, a bed with an edge, laid on
## the design pixels' grid so it reads as the sprites do; cached by links, as every hex with
## the same roads beside it lays the same road. Three road hexes round a corner make a loop
## with the ground showing in its middle (Ryan, 30 October: "can these types of triples have a
## gap in the middle?"), a road two wide a ladder of them.
static func _road(ci: CanvasItem, key: String, ts: Dictionary, c: Vector2, hex_px: float, s: int, links: int) -> void:
	var ck := "%s/road/%d/%d/%d" % [key, links, roundi(hex_px), s]
	if not _textures.has(ck):
		var r := hex_px - 1.5
		var cols := int(ceil(sqrt(3.0) * r / s)) + 2
		var rows := int(ceil(2.0 * r / s)) + 2
		var mid := Vector2(cols * s, rows * s) * 0.5
		var ends := _road_ends(hex_px, links)
		var edge := Color(str(ts["road"][0]))
		var bed := Color(str(ts["road"][1]))
		var img := Image.create_empty(cols * s, rows * s, false, Image.FORMAT_RGBA8)
		for y in range(rows):
			for x in range(cols):
				var p := Vector2(x + 0.5, y + 0.5) * s - mid
				if not _inside(p, Vector2.ZERO, r):
					continue
				var d := _road_dist(p, ends)
				if d <= ROAD_HALF * s:
					img.fill_rect(Rect2i(x * s, y * s, s, s), bed)
				elif d <= (ROAD_HALF + 1.0) * s:
					img.fill_rect(Rect2i(x * s, y * s, s, s), edge)
		_textures[ck] = ImageTexture.create_from_image(img)
	var tex: ImageTexture = _textures[ck]
	ci.draw_texture(tex, (c - tex.get_size() * 0.5).floor())
	if ts.has("road_stone"):
		var stone := _tex(key, str(ts["road_stone"]), false, s)
		var at: Array = [Vector2.ZERO]
		for e in _road_ends(hex_px, links):
			at.append(e * 0.55)
		for p in at:
			ci.draw_texture(stone, (c + p - stone.get_size() * 0.5).floor())


## Whether a sprite standing in `rect` would stand on the road (its `ends`, as _road_ends).
static func _on_road(rect: Rect2, c: Vector2, ends: Array, s: int) -> bool:
	var foot := Vector2(rect.get_center().x, rect.end.y)
	for p in [foot, rect.get_center(), rect.position, Vector2(rect.end.x, rect.position.y)]:
		if _road_dist(p - c, ends) <= (ROAD_HALF + 2.0) * s:
			return true
	return false


## What stands on a ground: each sprite of `list` set where it fits inside the hex, off the
## road, overlapping the ones set before by at most `overlap` of the smaller (rough's, a
## forest's crowns), then drawn back to front, the flat ones first.
static func _scatter(ci: CanvasItem, key: String, ts: Dictionary, c: Vector2, r: float, s: int, rng: RandomNumberGenerator, frame: int, list: Array, links: int, overlap: float) -> void:
	var placed: Array = []
	var ends := _road_ends(r + 1.5, links)
	for entry in list:
		var name: String = entry[0]
		var chance: float = entry[2] if entry.size() > 2 else 1.0
		for k in range(int(entry[1])):
			if rng.randf() >= chance:
				continue
			var mirror: bool = not ts["fixed"].has(name) and rng.randf() < 0.5
			var size := _tex(key, name, mirror, s).get_size()
			for attempt in range(30):
				var foot := c + Vector2(rng.randf_range(-0.8, 0.8) * r * 0.866, rng.randf_range(-0.5, 0.78) * r)
				var rect := Rect2((foot - Vector2(size.x * 0.5, size.y)).floor(), size)
				if not _fits(rect, c, r):
					continue
				if links != 0 and _on_road(rect, c, ends, s):
					continue
				if _crowded(rect.grow(s) if overlap == 0.0 else rect, placed, overlap):
					continue
				placed.append({"name": name, "rect": rect, "mirror": mirror, "flat": ts["flat"].has(name)})
				break
	placed.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a["flat"] != b["flat"]:
			return a["flat"]
		return a["rect"].end.y < b["rect"].end.y)
	for p in placed:
		var rect: Rect2 = p["rect"]
		ci.draw_texture(_tex(key, p["name"], p["mirror"], s), rect.position)
		_attach(ci, key, p["name"], rect, p["mirror"], s, frame)


## Whether a rect overlaps one set before by more than `overlap` of the smaller.
static func _crowded(rect: Rect2, placed: Array, overlap: float) -> bool:
	for p in placed:
		var other: Rect2 = p["rect"]
		if not rect.intersects(other):
			continue
		var cut := rect.intersection(other).get_area()
		if cut > overlap * minf(rect.get_area(), other.get_area()):
			return true
	return false


## A sprite's moving companion (ATTACH), set by its host and stepped by the frame.
static func _attach(ci: CanvasItem, key: String, name: String, rect: Rect2, mirror: bool, s: int, frame: int, tint: Color = Color.WHITE) -> void:
	var a = ATTACH.get(key, {}).get(name)
	if a == null:
		return
	var which: String = a[0]
	if SPRITES[key].has(which + str(frame)):
		which += str(frame)
	var tex := _tex(key, which, mirror, s)
	var x := float(a[1]) * s
	if mirror:
		x = rect.size.x - x - tex.get_width()
	ci.draw_texture(tex, (rect.position + Vector2(x, float(a[2] - a[3] * frame) * s)).floor(), tint)


## The water: the domain's liquid, a rim inside its edge and ripples drifting a step a frame.
static func _water(ci: CanvasItem, key: String, ts: Dictionary, c: Vector2, r: float, s: int, rng: RandomNumberGenerator, frame: int) -> void:
	Hud.stroke_poly(ci, MapOrient.corners(c, r - 2.0 - s), Color(str(ts["rim"])), float(s) + 1.0)
	var ripples: Array = ts["ripples"]
	for i in range(7):
		var tex := _tex(key, str(ripples[i % ripples.size()]), false, s)
		var p := c + Vector2(rng.randf_range(-0.55, 0.55) * r * 0.866, rng.randf_range(-0.5, 0.45) * r)
		p += Vector2(2.0, -1.0) * s * frame
		ci.draw_texture(tex, (p - tex.get_size() * 0.5).floor())
