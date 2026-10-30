extends SceneTree

## Paints the skirmish's battle backdrops (BattleBackdrop) for every domain's bleed and every
## ground into PNGs, headless (an image needs no renderer), for judging the painter quickly:
##   godot --headless --path . -s tools/backdrop_shot.gd -- <out dir> [width height horizon] [seed]
## The default size is the 1080 phone's foes' ground in art pixels (540x330, the horizon at 86).


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var out := args[0] if args.size() >= 1 else "build/backdrops"
	var size := Vector2i(540, 330)
	var horizon := 86
	if args.size() >= 4:
		size = Vector2i(int(args[1]), int(args[2]))
		horizon = int(args[3])
	var seed_value := int(args[4]) if args.size() >= 5 else 7
	DirAccess.make_dir_recursive_absolute(out)
	var t0 := Time.get_ticks_msec()
	var n := 0
	for biome in BattleBackdrop.PALETTES.keys():
		for terrain in BattleMap.TERRAIN_NAMES.keys():
			var img := BattleBackdrop.paint(str(biome), int(terrain), seed_value, size, horizon)
			img.save_png("%s/%s_%s.png" % [out, biome, BattleMap.TERRAIN_NAMES[terrain]])
			n += 1
	print("painted %d backdrops in %d ms" % [n, Time.get_ticks_msec() - t0])
	quit(0)
