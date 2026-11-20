extends TestCase

## A model's textures ride inside its .glb, and its import (gltf/embedded_image_handling 1,
## Extract Textures) copies each one out beside it as <model>_<texture>.png, the file the game
## draws, its .import keeping the md5 of the pixels it was copied from. A model rebuilt and
## committed without the copies the import then writes leaves them behind: every fresh
## checkout's first import writes them again, and a session that restores them puts back a
## texture the model no longer carries (found 18 November on the Badger, the Kite and the
## Needletail; in October four of the Prairie Dog's, read then as the importer's noise). A model
## that drops a texture leaves its copy behind too, imported and exported for nothing. Both fail
## here until the copies follow the model: the fix is the import, then a commit of what it wrote.

const EXTRACT_TEXTURES := 1   # gltf/embedded_image_handling in a .glb's .import
const GLB_JSON := 0x4E4F534A
const GLB_BIN := 0x004E4942


func test_every_copy_holds_the_texture_inside_its_model() -> void:
	var models := 0
	var textures := 0
	for glb in _extracting_models():
		models += 1
		var names := {}
		for t in _textures_of(glb):
			textures += 1
			var name := str(t["name"])
			assert_true(name.is_valid_filename() and name != "" and not name.contains("."), "%s names its texture %d plainly (%s), so its copy's name is its own" % [glb, t["index"], name])
			assert_false(names.has(name), "%s names one texture %s" % [glb, name])
			names[name] = true
			assert_eq(t["mime"], "image/png", "%s carries its %s as a PNG" % [glb, name])
			var copy := _copy_path(glb, name)
			if not FileAccess.file_exists(copy + ".import"):
				assert_true(false, "%s is beside %s: run the import and commit what it writes" % [copy, glb])
				continue
			var inside := _md5(t["bytes"])
			assert_eq(_recorded_md5(copy), inside, "%s was copied from the %s inside %s, not an older one: run the import and commit what it writes" % [copy, name, glb])
			assert_eq(_md5(FileAccess.get_file_as_bytes(copy)), inside, "%s holds the pixels of the %s inside %s, never a restored older copy" % [copy, name, glb])
	assert_true(models >= 2, "the models under art/ are found (%d)" % models)
	assert_true(textures >= models, "and their textures (%d)" % textures)


func test_no_copy_outlives_its_texture() -> void:
	var carried := {}
	var folders := {}
	for glb in _extracting_models():
		folders[glb.get_base_dir()] = true
		for t in _textures_of(glb):
			carried[_copy_path(glb, str(t["name"]))] = true
	for folder in folders.keys():
		for f in DirAccess.get_files_at(folder):
			if not f.ends_with(".png"):
				continue
			var path := "%s/%s" % [folder, f]
			if _recorded_md5(path) == "":
				continue   # a PNG of its own, no model's copy
			assert_true(carried.has(path), "%s copies a texture no model in its folder carries: delete it and its .import" % path)


func test_a_texture_reads_as_the_importer_reads_it() -> void:
	# The md5 the import records is of the decoded pixels, never the file's bytes: two encodings
	# of one picture are one texture.
	var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.8, 0.2, 0.1, 1.0))
	var once := img.save_png_to_buffer()
	img.set_pixel(1, 1, Color(0.1, 0.2, 0.8, 1.0))
	var other := img.save_png_to_buffer()
	img.set_pixel(1, 1, Color(0.8, 0.2, 0.1, 1.0))
	var again := img.save_png_to_buffer()
	assert_eq(_md5(again), _md5(once), "one picture, one md5")
	assert_ne(_md5(other), _md5(once), "a pixel moved, another md5")


# ---------------------------------------------------------------- reading a model

## Every .glb under art/ whose import copies its textures out.
func _extracting_models() -> Array[String]:
	var out: Array[String] = []
	var dirs: Array[String] = ["res://art"]
	while not dirs.is_empty():
		var dir: String = dirs.pop_back()
		for sub in DirAccess.get_directories_at(dir):
			dirs.append("%s/%s" % [dir, sub])
		for f in DirAccess.get_files_at(dir):
			if not f.ends_with(".glb"):
				continue
			var path := "%s/%s" % [dir, f]
			var cfg := ConfigFile.new()
			if cfg.load(path + ".import") == OK and int(cfg.get_value("params", "gltf/embedded_image_handling", -1)) == EXTRACT_TEXTURES:
				out.append(path)
	out.sort()
	return out


## The textures a .glb carries: [{index, name, mime, bytes}], read from its JSON and its binary
## chunk as the glTF 2.0 binary format lays them out.
func _textures_of(glb: String) -> Array:
	var data := FileAccess.get_file_as_bytes(glb)
	var json: Dictionary = {}
	var bin := PackedByteArray()
	var at := 12
	while at + 8 <= data.size():
		var size := data.decode_u32(at)
		var kind := data.decode_u32(at + 4)
		var chunk := data.slice(at + 8, at + 8 + size)
		if kind == GLB_JSON:
			json = JSON.parse_string(chunk.get_string_from_utf8())
		elif kind == GLB_BIN:
			bin = chunk
		at += 8 + size
	var out: Array = []
	var images: Array = json.get("images", [])
	for i in images.size():
		var image: Dictionary = images[i]
		var view: Dictionary = json["bufferViews"][int(image["bufferView"])]
		var from := int(view.get("byteOffset", 0))
		out.append({"index": i, "name": str(image.get("name", "")), "mime": str(image.get("mimeType", "")),
			"bytes": bin.slice(from, from + int(view["byteLength"]))})
	return out


## Where the import writes a model's texture: beside the model, under the model's name.
func _copy_path(glb: String, texture: String) -> String:
	return "%s/%s_%s.png" % [glb.get_base_dir(), glb.get_file().get_basename(), texture]


## The md5 of a PNG's decoded pixels, the one the import keys a copy on.
func _md5(png: PackedByteArray) -> String:
	var img := Image.new()
	if png.is_empty() or img.load_png_from_buffer(png) != OK:
		return ""
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_MD5)
	ctx.update(img.get_data())
	return ctx.finish().hex_encode()


## The md5 a copy's .import says it was copied from; empty for a PNG no model's import wrote.
func _recorded_md5(copy: String) -> String:
	var cfg := ConfigFile.new()
	if cfg.load(copy + ".import") != OK:
		return ""
	var params = cfg.get_value("remap", "generator_parameters", {})
	return str(params.get("md5", "")) if params is Dictionary else ""
