
extends Node
# NOTE: no `class_name` here because this script is used as an Autoload singleton.
#       The autoload name (in Project Settings > Autoload) should be: BiomeService

const BIOMES_DIR := "user://biomes"

signal biome_saved(id: String, path: String)
signal biome_deleted(id: String)

# ------------------------------------------------------------------------------
# Public API
# ------------------------------------------------------------------------------

func ensure_biomes_dir() -> void:
	var da := DirAccess.open("user://")
	if da == null:
		return
	if not da.dir_exists("biomes"):
		da.make_dir("biomes")

func create_biome(id: String, name: String, owner: String) -> Biome:
	var b := Biome.new()
	b.id = id
	b.name = name
	b.owner = owner
	b.features = []
	b.cards = []
	b.validation_state = {"is_valid": true, "errors": []}
	b.data_version = 1
	b.created_at = Time.get_unix_time_from_system()
	b.updated_at = b.created_at
	return b

func add_card_entry(biome: Biome, genetic_code_id: String, me_cost: int, alias: String = "") -> void:
	var entry := CardEntry.new()
	entry.genetic_code_id = genetic_code_id
	entry.me_cost = me_cost
	entry.display_alias = alias
	biome.cards.append(entry)
	biome.updated_at = Time.get_unix_time_from_system()

func save_biome(biome: Biome) -> bool:
	ensure_biomes_dir()

	# Defensive checks
	if biome == null:
		push_error("BiomeService.save_biome: biome is null")
		return false
	if not (biome is Resource):
		push_error("BiomeService.save_biome: biome is not a Resource")
		return false

	var safe := _safe_filename(biome.id)
	var path := "%s/%s.tres" % [BIOMES_DIR, safe]

	# Godot 4: Resource first, path second
	var err := ResourceSaver.save(biome, path)
	if err == OK:
		biome_saved.emit(biome.id, path)
		return true

	push_error("BiomeService.save_biome: save failed (err=%d) for %s" % [err, path])
	return false

func load_biome(id: String) -> Biome:
	var safe := _safe_filename(id)
	var path := "%s/%s.tres" % [BIOMES_DIR, safe]
	if not FileAccess.file_exists(path):
		return null
	var res := load(path)
	return res as Biome

func list_biomes() -> Array[Biome]:
	ensure_biomes_dir()
	var out: Array[Biome] = []
	var da := DirAccess.open(BIOMES_DIR)
	if da == null:
		return out
	da.list_dir_begin()
	var f := da.get_next()
	while f != "":
		if f.ends_with(".tres"):
			var res := load("%s/%s" % [BIOMES_DIR, f])
			if res is Biome:
				out.append(res)
		f = da.get_next()
	da.list_dir_end()
	return out

func delete_biome(id: String) -> bool:
	var safe := _safe_filename(id)
	var path := "%s/%s.tres" % [BIOMES_DIR, safe]
	if not FileAccess.file_exists(path):
		return false
	var da := DirAccess.open(BIOMES_DIR)
	if da == null:
		return false
	var err := da.remove(path.get_file()) # remove the file inside user://biomes
	if err == OK:
		biome_deleted.emit(id)
		return true
	push_error("BiomeService.delete_biome: failed (err=%d) for %s" % [err, path])
	return false

# ------------------------------------------------------------------------------
# Simple validation (Content‑DB‑free; good for early compile & I/O tests)
# ------------------------------------------------------------------------------


func validate_biome_simple(biome: Biome, blueprint_service: Node = null) -> Dictionary:
	var errors: Array[String] = []

	# Features: no duplicates
	var seen := {}
	for fid in biome.features:
		if seen.has(fid):
			errors.append("Duplicate feature: %s" % fid)
		seen[fid] = true

	# Exactly 20 cards
	if biome.cards.size() != 20:
		errors.append("Deck must contain exactly 20 cards (has %d)" % biome.cards.size())

	# Resolve BlueprintService (autoload) if not passed
	var bs: Node = blueprint_service
	if bs == null:
		bs = get_node_or_null("/root/BlueprintService")

	# Validate each card entry (ME range + GC exists + simple GC validation)
	for i in range(biome.cards.size()):
		var ce: CardEntry = biome.cards[i]

		if ce.me_cost < 1 or ce.me_cost > 10:
			errors.append("Card %d has invalid ME tier: %d" % [i, ce.me_cost])

		var gc: GeneticCode = null
		if bs != null and bs.has_method("load_genetic_code"):
			gc = bs.load_genetic_code(ce.genetic_code_id) as GeneticCode

		if gc == null:
			errors.append("Card %d references missing Genetic Code: %s" % [i, ce.genetic_code_id])
			continue

		# Validate the Genetic Code structurally (simple version; no ContentDB)
		var v: Dictionary = {"is_valid": true, "errors": []}
		if bs != null and bs.has_method("validate_genetic_code_simple"):
			v = bs.validate_genetic_code_simple(gc)
		if not v["is_valid"]:
			errors.append("Card %d Genetic Code invalid: %s" % [i, String(v["errors"].join("; "))])

	return {"is_valid": errors.is_empty(), "errors": errors}


# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

func _safe_filename(id: String) -> String:
	return id.replace(".", "_").replace(":", "_").replace("/", "_").replace("\\", "_")
