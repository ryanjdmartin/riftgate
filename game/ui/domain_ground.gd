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
##   walls: the ranges a wall hex shows one of (draw_walls);
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
		"walls": ["walls", "walls_b"],
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
		"walls": ["walls", "walls_b"],
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
		"walls": ["walls", "walls_b"],
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
		"walls": ["walls", "walls_b"],
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
	"lava": {"temple": ["flame", 5, 4, 0], "vent": ["steam", 3, -5, 2], "walls": ["steam", 17, -5, 2]},
}

const ROAD_HALF := 3.5   # the road's half width in design pixels, its edge one more
const WALL_FOOT := 0.46   # a range's foot below its hex's middle, in hex sizes

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
		"walls": [
			"...................k....................",
			"..................kSk...................",
			"..................kSk...................",
			"..................kSk...................",
			".................kSSZk..................",
			".................kSSZk..................",
			".................kSSZk..................",
			"................kSSSSZk.................",
			"................kSSSSZk.................",
			"................kSSSSZk.................",
			"...............kSSSSSZZk................",
			"...............kSSSmmMZk................",
			"..............kmmmmmmMMMk...............",
			"..............kmmmmmmmMMk...............",
			"..............kmmmmmmmMMk...............",
			".............kmmmmmmmmMMMk..............",
			"..........k..kmmmmmmmmMMMk..............",
			".........kSk.kmmmmmmmmMMMk..............",
			".........kSkkmmmmmmmmmmMMMk...k.........",
			"........kSSZkmmmmmmmmmmMMMk..kSk........",
			"........kSSZkmmmmmmmmmmMMMk..kSk........",
			"........kSSZkmmmmmmmmmmMMMMkkSSZk.......",
			".......kmmSMZkmmmmmmmmmMMMMkkmSMk.......",
			".......kmmmmMkmmmmmmmmmMMMMkkmmMk.......",
			"......kmmmmmMMkmmmmmmmmmMMMkmmmMMk......",
			"......kmmmmmMMkmmmmmmmmmMMMkmmmmMk......",
			".....kmmmmmmMMMkmmmmmmmmMMkmmmmmMMk.....",
			".....kmmmmmmMMMkmmmmmmmmMMkmmmmmMMk.....",
			".....kmmmmmmMMMkmmmmmmmmMkmmmmmmMMMk....",
			"....kmmmmmmmmMMMkmmmmmmmmkmmmmmmMMMk....",
			"....kmmmmmmmmMMMkmmmmmmmmkmmmmmmMMMk....",
			"...kmmmmmmmmmMMMMkmmmmmmkmmmmmmmmMMMk...",
			"...kmmmmmmmmmMMMMkmmmmmmkmmmmmmmmMMMk...",
			"..kmmmmmmmmmmMMMMMkmmmmkmmmmmmmmmMMMMk..",
			"..kmmmmmmmmmmmMMMMkmmmmkmmmmmmmmmMMMMk..",
			"..kmmmmmmmmmmmMMMMkmmmmkmmmmmmmmmMMMMk..",
			".kmmmmmmmmmmmmMMMMMkmmkmmmmmmmmmmmMMMMk.",
			".kmmmmmmmmmmmmMMMMMkmmkmmmmmmmmmmmMMMMk.",
			"kmmmmmmmmmmmmmMMMMMMkkmmmmmmmmmmmmMMMMMk",
			".kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk.",
		],
		"walls_b": [
			"..........................k.............",
			".........................kSk............",
			".........................kSk............",
			".........................kSk............",
			"........................kSSZk...........",
			"........................kSSZk...........",
			"........................kSSZk...........",
			"............k..........kSSSSZk..........",
			"...........kSk.........kSSSSZk..........",
			"...........kSk.........kSSSSZk..........",
			"...........kSk........kSSmSSMZk.........",
			"..........kSSZk.......kmmmSmMMk.........",
			"..........kSSZk.......kmmmmmMMk.........",
			"..........kSSZk......kmmmmmmmMMk........",
			".........kSSSSZk.....kmmmmmmmMMk........",
			".........kSSmmZk.....kmmmmmmmMMk........",
			"........kSmmmmZZk...kmmmmmmmmMMMk.......",
			"........kmmmmmMMk...kmmmmmmmmMMMk.......",
			"........kmmmmmMMk...kmmmmmmmmmMMk.......",
			".......kmmmmmmMMMk.kmmmmmmmmmmMMMk......",
			".......kmmmmmmmMMk.kmmmmmmmmmmMMMk......",
			".......kmmmmmmmMMk.kmmmmmmmmmmMMMk......",
			"......kmmmmmmmmMMMkkmmmmmmmmmmMMMk......",
			"......kmmmmmmmmMMMkmmmmmmmmmmmMMMMk.....",
			".....kmmmmmmmmmMMMkmmmmmmmmmmmmMMMk.....",
			".....kmmmmmmmmmmMMkmmmmmmmmmmmmMMMk.....",
			".....kmmmmmmmmmmMkmmmmmmmmmmmmmMMMMk....",
			"....kmmmmmmmmmmmMkmmmmmmmmmmmmmMMMMk....",
			"....kmmmmmmmmmmmkmkmmmmmmmmmmmmMMMMk....",
			"....kmmmmmmmmmmmkmkmmmmmmmmmmmmmMMMMk...",
			"...kmmmmmmmmmmmkmmMkmmmmmmmmmmmmMMMMk...",
			"...kmmmmmmmmmmkmmmMMkmmmmmmmmmmmMMMMk...",
			"..kmmmmmmmmmmmkmmmMMkmmmmmmmmmmmMMMMMk..",
			"..kmmmmmmmmmmkmmmmMMMkmmmmmmmmmmMMMMMk..",
			"..kmmmmmmmmmmkmmmmmMMkmmmmmmmmmmMMMMMk..",
			".kmmmmmmmmmmkmmmmmmMMMkmmmmmmmmmmMMMMMk.",
			".kmmmmmmmmmkmmmmmmmMMMMkmmmmmmmmmMMMMMk.",
			".kmmmmmmmmmkmmmmmmmMMMMkmmmmmmmmmMMMMMk.",
			"kmmmmmmmmmkmmmmmmmmMMMMMkmmmmmmmmMMMMMMk",
			".kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk.",
		],
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
		"walls": [
			"...............zzzzzzzzzzzz.............",
			"..............zTTTTTTTtttttz............",
			"..............zttttttttttttz............",
			"..............zmmmmmmmMMMMMz............",
			"..............zmmmmmmmMMMMMz............",
			"..............zmmmmmmmMMMMMz............",
			"..............zmmMmmmmMMMMMz............",
			"..............zmmMmmmmMMMMMz............",
			"..............zmmMmmmmMMMMMz............",
			"..............zmmMmMmmMMMMMz............",
			"..............zmmmmMmmMMMMMz............",
			"..............zmmmmMmmMMMMMz............",
			".............zmmmmmMmmmMMMMMz...........",
			".............zmmmmmMmmmMMMMMz...........",
			".............zmmmmmMmmmMMMMMz...........",
			".............zmmmmmmmmmMMMMMz...........",
			".............zmmmmmmmmmMMMMMz...........",
			".............zmmmmmmmmmMMMMMz...........",
			".............zmmmmmmmmmMMMMMz...........",
			".............zmmmmmmmmmMMMMMz...........",
			".............zmmmmmmmmmMMMMMz...........",
			".....zzzzzzz.zmmmmmmmmmMMMMMz...........",
			"....zTTTTtttzzmmmmmmmmmMMMMMz...........",
			"....ztttttttzmmmmmmmmmmMMMMMMz..........",
			"....zmmmmMMMzmmmmmmmmmmMMMMMMzzzzzz.....",
			"....zmmmmMMMzmmmmmmmmmmMMMMMzTTTtttz....",
			"....zmmmmMMMzmmmmmmmmmmMMMMMzttttttz....",
			"....zmmMmMMMzmmmmmmmmmmMMMMMzmmmMMMz....",
			"....zmmMmMMMzmmmmmmmmmmMMMMMzmmMMMMz....",
			"....zmmMmMMMzmmmmmmmmmmMMMMMzmmMMMMz....",
			"...zmmmMmMMMMzmmmmmmmmmMMMMMzmmMMMMz....",
			"...zmmmmmMMMMzmmmmmmmmmMMMMMzmmMMMMz....",
			"...zmmmmmMMMMzmmmmmmmmmMMMMMzmmMMMMz....",
			"...zmmmmmMMMMzmmmmmmmmmMMMMzmmmMmMMMz...",
			"...zmmmmmMMMMzmmmmmmmmmMMMMzmmmmmMMMz...",
			"..zlllllllMMMMzlllllllllMMzllllllMMMMz..",
			".zllllllllMMMMMzllllllllMzlllllllMMMMMz.",
			"zlllllllllMMMMMMzlllllllzlllllllllMMMMMz",
			".zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz.",
		],
		"walls_b": [
			".......zzzzzzzzz......................",
			"......zTTTTTttttz.....................",
			"......ztttttttttz.....................",
			"......zmmmmmMMMMz.....................",
			"......zmmmmmMMMMz.....................",
			"......zmmmmmMMMMz.....................",
			"......zmmmmmMMMMz.....................",
			"......zmmmmmMMMMz.....................",
			"......zmmmmmMMMMz.....................",
			"......zmmmmmMMMMz.....................",
			"......zmmmmmMMMMz.....................",
			"......zmmmmmMMMMz.....................",
			".....zmmmmmmmMMMMz....................",
			".....zmmmmmmmMMMMz....................",
			".....zmmmmmmmMMMMz.zzzzzzzzzzzzz......",
			".....zmmmMmmmMMMMzzTTTTTTTTtttttz.....",
			".....zmmmMmmmMMMMzztttttttttttttz.....",
			".....zmmmMmmmMMMMzzmmmmmmmmMMMMMz.....",
			".....zmmmMmmmMMMMzzmmmmmmMmMMMMMz.....",
			".....zmmmMmmmMMMMzzmmmmmmMmMMMMMz.....",
			".....zmmmMmmmMMMMzzmmmmmmMmMMMMMz.....",
			".....zmmmMmmmMMMMzzmmmmmmMmMMMMMz.....",
			".....zmmmmmmmMMMMzzmmmmmmMmMMMMMz.....",
			"....zmmmmmmmmMMMMMzmmmmmmMmMMMMMz.....",
			"....zmmmmmmmmMMMMzmmmmmmmMmMMMMMMz....",
			"....zmmmmmmmmMMMMzmmmmmmmmmMMMMMMz....",
			"....zmmmmmmmmMMMMzmmmmmmmmmMMMMMMz....",
			"....zmmmmmmmmMMMMzmmmmmmMmmMMMMMMz....",
			"....zmmmmmmmmMMMMzmmmmmmMmmMMMMMMz....",
			"....zmmmmmmmmMMMMzmmmmmmMmmMMMMMMz....",
			"....zmmmmmmmmMMMMzmmmmmmMmmMMMMMMz....",
			"....zmmmmmmmmMMMMzmmmmmmmmmMMMMMMz....",
			"....zmmmmmmmmMMMMzmmmmmmmmmMMMMMMz....",
			"....zmmmmmmmmMMMzmmmmmmmmmmmMMMMMMz...",
			"...zmmmmmmmmmMMMzmmmmmmmmmmmMMMMMMz...",
			"...zmmmmmmmmmMMMzmmmmmmmmmmmMMMMMMz...",
			"..zlllllllllllMzllllllllllllMMMMMMMz..",
			".zllllllllllllzlllllllllllllMMMMMMMMz.",
			"zllllllllllllzlllllllllllllllMMMMMMMMz",
			".zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz.",
		],
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
		"walls": [
			"............o.................",
			"...........odo................",
			"...........oldo...............",
			"...........olo................",
			"...........olo................",
			"...........olo.......o........",
			"...........oldo.....omo.......",
			"...........oldo.....omo.......",
			"...........olddo....olo.......",
			"..o........olddo....oldo......",
			".omo.......olmdo.....oo.......",
			".omo.......olmdo....oldo......",
			".olo.......olmdo....oldo......",
			".olo.......olmdo.....odo......",
			".oldo......olmddo...olddo.....",
			".oldo......olmddo...olmdo.....",
			".olddo....omlmdddo..olmdo.....",
			".olddo.....olmdddo..olmdo.....",
			".olddo.....olmdddo..olmddo....",
			".olmdo....omlmmdddo.olmddo....",
			".olmddo....olmmoddo.olmdddo...",
			".olmdo.....olmomodo.olmdddo...",
			".olmddo...omlmoldoo.olmdddo...",
			"omlmdddo..omlmoldodoolmmddo...",
			".olmddo....olmmodoo.olmmdddo..",
			"omlmdddo..omlmmododoolmmdddo..",
			".olmdddo...olmolddooolmmdddo..",
			".olmmdddo.ollmolmdoomlmmddddo.",
			"omlmmdddo.ollmolmddomlmmddddo.",
			".olmmdddo..olmolmddomlmmddddo.",
			"ollmmddddo.olmolmddollmmdddddo",
			".olmmdddo.ollomlmdddolmmmdddo.",
			".olmmddddoollollmdddolmmmddddo",
			"ollmmddddoollollmdddolmmmddddo",
			"olmmmdddddolmolmmddddommmddddo",
			".ooooooooo.oooooooooooooooooo.",
		],
		"walls_b": [
			"........................o..",
			".......................odo.",
			".......................odo.",
			".......................odo.",
			".......................oo..",
			"......................oldo.",
			"......................oldo.",
			"......................oldo.",
			".........o...........omldo.",
			"........odo..........oodo..",
			".......omdo.........omlddo.",
			".......omdo.........omlddo.",
			".......omdo.........ollddo.",
			"........oo..........olmddo.",
			".......oldo.........olmdo..",
			".......oldo........omlmddo.",
			"......olldo.........olmddo.",
			"......olmdo........olmmddo.",
			".....omldddo.......olmdddo.",
			"......olddo.......omlmddddo",
			".....ollddo.......olmmdddo.",
			".....olmddo.......olmmdddo.",
			".....olmddooo....omlmmddddo",
			"....ollmddomdo...ollmmdddo.",
			"....olmmddooo...omlmmmddddo",
			"....olmmddoldo...olmmmdddo.",
			"....olmdddoldo..omlmmdddddo",
			"...ollmddomlddo..ommmddddo.",
			"...olmmddollddo.olmmmdddddo",
			"...olmmddolmddo.olmmmdddddo",
			"..ollmmddolmddoollmmmdddddo",
			"..olmmmddolmddoolmmmmdddddo",
			"..olmmmdomlmdddolmmmmdddddo",
			"..olmmmddommddomlmmmmdddddo",
			".ollmmddolmmdddolmmmddddddo",
			".olmmmddolmmdddommmmdddddo.",
			".olmmmdomlmmddddommmddddddo",
			"omlmmmdollmmddddommmddddddo",
			".ooooooooooooooooooooooooo.",
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
		"walls": [
			"................oooooooo................",
			"...............occcWcccco...............",
			"..............ommLHHHHLddo..............",
			".............ommmmLcdLcdddo.............",
			".............ommmLcLLcddddo.............",
			"............ommmmLcmLcdddddo............",
			"............ommmLcLcLcdddddo............",
			"...........ommmmmLcmLcddddddo...........",
			"...........ommmmmLcmLcddddddo...........",
			"..........ommmmmLcmmmLcddddddo..........",
			"..........ommmmmLcmmmLcddddddo..........",
			"..........ommmmLcmLcmLcddddddo..........",
			".........ommmmmLcLcmmLcdddddddo.........",
			".........ommmmLcmLcmmLcdddddddo.........",
			"........ommmmmmLcLcmmLcddddddddo........",
			"........ommmmmLcmLcmmLcddddddddo........",
			"........ommmmLcmmLcmmmLcdddddddo........",
			".......ommmmmLcmLcmmmmLcddddddddo.......",
			".......ommmmmLcmLcmmmmLcddddddddo.......",
			"......ommmmmmLcmLcmmmLcddddddddddo......",
			"......ommmmmLcmmLcmmmmLcdddddddddo......",
			"......ommmmmLcmmmLcmmmdLcddddddddo......",
			".....ommmmmmmLcmLcmmmmLcddddddddddo.....",
			".....ommmmmmLcmmLcmmmmLcddddddddddo.....",
			".....ommmmmmLcmmLcmmmmLcddddddddddo.....",
			"....ommmmmmLcmmmLcmmmmLcdddddddddddo....",
			"....ommmmmmLcmmLcmmmmmLcdddddddddddo....",
			"....ommmmmmLcmmLcmmmmmLcdddddddddddo....",
			"...ommmmmmLcmmmLcmmmmmLcddddddddddddo...",
			"...ommmmmmLcmmmmLcmmmmLcddddddddddddo...",
			"...ommmmmmLcmmmmmmmmmmLcddddddddddddo...",
			"..ommmmmmLcmmmmmmmmmmmLcdddddddddddddo..",
			"..ommmmmmLcmmmmmmmmmmmmLcddddddddddddo..",
			"..ommmmmmLcmmmmmmmmmmmmLcddddddddddddo..",
			".ommmmmmmLcmmmmmmmmmmmmmLcddddddddddddo.",
			".ommmmmmLcmmmmmmmmmmmmmmLcddddddddddddo.",
			".ommmmmmmLcmmmmmmmmmmmmLcdddddddddddddo.",
			"ommmmmmmmmmmmmmmmmmmmmmmLcdddddddddddddo",
			".oooooooooooooooooooooooooooooooooooooo.",
		],
		"walls_b": [
			".....................o..................",
			"....................omo.................",
			"....................omo.................",
			"....................omo.................",
			"....................omo.................",
			"...................ommdo................",
			"...................ommdo................",
			"...................ommmo................",
			"..................ommmmdo...............",
			"..................ommmmdo...............",
			"..................ommmmdo...............",
			"..........o......ommmmmddo..............",
			".........omo.....ommmmmddo..............",
			".........omo.....ommmmmmdo..............",
			".........omo....ommmmmmmddo.............",
			"........ommdo...ommmmmmmddo.............",
			"........ommdo...ommmmmmmddo.............",
			"........ommdo..ommmmmmmmdddo............",
			".......ommmmdo.ommmmmmmmmddo...o........",
			".......ommmmdo.ommmmmmmmmddo..omo.......",
			"......ommmmmddoommmmmmmmmddo..omo.......",
			"......ommmmmddommmmmmmmmmdddo.omo.......",
			"......ommmmmLdommmmmmmmmmdddoommdo......",
			".....ommmmmmLdommmmmmmmmmdddoommdo......",
			".....ommmmmmmommmmmmmmmmmmddommmddo.....",
			".....ommmmmmmommmmmmmmmmmmddommmmLo.....",
			"....ommmmmmmmommmmmmmmmmmmddommmmLo.....",
			"....ommmmmmmommmmmmmmmmmmmdommmmmLdo....",
			"....ommmmmmmommmmmmmmmmmmmdommmmmdLo....",
			"...ommmmmmmmommmmmmmmmmmmmommmmmmdLdo...",
			"...ommmmmmmommmmmmmmmmmmmmommmmmmdLdo...",
			"..ommmmmmmmommmmmmmmmmmmmmommmmmmmddo...",
			"..ommmmmmmmommmmmmmmmmmmmommmmmmmmdddo..",
			"..ommmmmmmommmmmmmmmmmmmmommmmmmmmdddo..",
			".ommmmmmmmommmmmmmmmmmmmommmmmmmmmddddo.",
			".ommmmmmmmommmmmmmmmmmmmommmmmmmmmddddo.",
			".ommmmmmmmommmmmmmmmmmmmommmmmmmmmmdddo.",
			"ommmmmmmmommmmmmmmmmmmmommmmmmmmmmmddddo",
			".oooooooooooooooooooooooooooooooooooooo.",
		],
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
## hex when it has none. A wall hex's range is draw_walls's, drawn after every hex's ground,
## since it stands taller than its hex. The second frame moves what moves.
static func draw_hex(ci: CanvasItem, c: Vector2, hex_px: float, t: int, seed_value: int, frame: int, biome: String, links: int = 0) -> void:
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
	Hud.stroke_poly(ci, pts, Color(Color(str(ts["grid"])), 0.35), 1.0)


## A wall hex's range: one of the domain's, its foot low in the hex and its peaks standing up
## out of it into the hexes above (Ryan, 30 October: "The wall objects on all can be larger,
## or at least taller"), so the ranges go down after every hex's ground, the top rows' first.
## A wall is drawn by what it is (`look`, BattleMap.WALL_LOOKS; Ryan, 10 November: "The
## different spire types probably need to be represented in the painted world, for clarity"):
## crags are the domain's range sprites; mesas a stepped flat-topped block, towers a few tall
## blocks with lit windows, cliffs a low ridge the whole hex wide so neighbours join, each
## built from the domain's wall inks (BLOCK_INKS).
static func draw_walls(ci: CanvasItem, c: Vector2, hex_px: float, seed_value: int, frame: int, biome: String, look: String = "crags") -> void:
	var key := key_of(biome)
	var ts: Dictionary = TILESETS[key]
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var s := scale_of(hex_px)
	var foot := c + Vector2(0.0, hex_px * WALL_FOOT)
	if look != "crags" and BLOCK_INKS.has(key):
		var tex := _block_tex(key, look, rng.randi_range(0, 2), s)
		var pos := (foot - Vector2(tex.get_width() * 0.5, tex.get_height())).floor()
		ci.draw_texture(tex, pos)
		return
	var name: String = ts["walls"][rng.randi() % ts["walls"].size()]
	var mirror := rng.randf() < 0.5
	var tex := _tex(key, name, mirror, s)
	var rect := Rect2((foot - Vector2(tex.get_width() * 0.5, tex.get_height())).floor(), tex.get_size())
	ci.draw_texture(tex, rect.position)
	_attach(ci, key, name, rect, mirror, s, frame)


## The ink letters a domain's block walls (mesas, towers, cliffs) are built from: its range
## sprite's outline, body, shade and light.
const BLOCK_INKS := {
	"plains": {"out": "k", "body": "m", "shade": "M", "light": "S"},
	"sand": {"out": "z", "body": "m", "shade": "M", "light": "l"},
	"marsh": {"out": "o", "body": "m", "shade": "d", "light": "l"},
	"lava": {"out": "o", "body": "m", "shade": "d", "light": "c"},
}


## A block wall as a texture in design pixels at `s` pixels each, cached by look and variant.
## Sizes are in design pixels, a hex 24 wide from middle to corner: a mesa 34 wide and 22 tall
## in two steps; towers 36 wide, three blocks 26 to 36 tall with windows; a cliff 42 wide
## (the hex's whole width) and 18 tall with cracks.
static func _block_tex(key: String, look: String, variant: int, s: int) -> ImageTexture:
	var ck := "%s/block/%s/%d/%d" % [key, look, variant, s]
	if _textures.has(ck):
		return _textures[ck]
	var ink: Dictionary = INKS[key]
	var letters: Dictionary = BLOCK_INKS[key]
	var out := Color(str(ink[letters["out"]]))
	var body := Color(str(ink[letters["body"]]))
	var shade := Color(str(ink[letters["shade"]]))
	var light := Color(str(ink[letters["light"]]))
	var w := 42
	var h := 40
	var img := Image.create_empty(w * s, h * s, false, Image.FORMAT_RGBA8)
	var px := func(x: int, y: int, col: Color) -> void:
		if x >= 0 and y >= 0 and x < w and y < h:
			img.fill_rect(Rect2i(x * s, y * s, s, s), col)
	# A block: outlined, its top strip light, its right third in shade.
	var block := func(x0: int, y0: int, bw: int, bh: int, windows: bool) -> void:
		for y in range(y0, y0 + bh):
			for x in range(x0, x0 + bw):
				var edge := x == x0 or x == x0 + bw - 1 or y == y0 or y == y0 + bh - 1
				var col := body
				if edge:
					col = out
				elif y <= y0 + 1:
					col = light
				elif x >= x0 + bw - maxi(2, bw / 3):
					col = shade
				elif windows and (y - y0) % 4 == 0 and (x - x0) % 3 == 1 and y > y0 + 2 and y < y0 + bh - 2:
					col = light if ((x * 7 + y * 13 + variant) % 5) != 0 else shade
				px.call(x, y, col)
	match look:
		"mesas":
			var top_w := 22 + variant * 2
			block.call(4, 18, 34, 22, false)          # the base
			block.call(10 - variant, 8, top_w, 12, false)   # the top step
		"towers":
			var heights: Array = [[34, 26, 30], [28, 36, 24], [30, 22, 34]][variant]
			var x := 3
			for i in range(3):
				var bh: int = heights[i]
				var bw := 10 + (i + variant) % 2
				block.call(x, h - bh, bw, bh, true)
				x += bw + 2
		_:
			block.call(0, 22, 42, 18, false)          # the ridge, edge to edge
			for i in range(3):
				var cx := 6 + i * 13 + (variant * 3) % 5
				for y in range(25, 39):
					if (y + i) % 3 != 0:
						px.call(cx, y, shade)
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
static func _attach(ci: CanvasItem, key: String, name: String, rect: Rect2, mirror: bool, s: int, frame: int) -> void:
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
	ci.draw_texture(tex, (rect.position + Vector2(x, float(a[2] - a[3] * frame) * s)).floor())


## The water: the domain's liquid, a rim inside its edge and ripples drifting a step a frame.
static func _water(ci: CanvasItem, key: String, ts: Dictionary, c: Vector2, r: float, s: int, rng: RandomNumberGenerator, frame: int) -> void:
	Hud.stroke_poly(ci, MapOrient.corners(c, r - 2.0 - s), Color(str(ts["rim"])), float(s) + 1.0)
	var ripples: Array = ts["ripples"]
	for i in range(7):
		var tex := _tex(key, str(ripples[i % ripples.size()]), false, s)
		var p := c + Vector2(rng.randf_range(-0.55, 0.55) * r * 0.866, rng.randf_range(-0.5, 0.45) * r)
		p += Vector2(2.0, -1.0) * s * frame
		ci.draw_texture(tex, (p - tex.get_size() * 0.5).floor())
