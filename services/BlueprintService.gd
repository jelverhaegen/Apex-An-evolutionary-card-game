
extends Node

const GENETIC_CODES_DIR := "user://genetic_codes"

signal genetic_code_saved(id: String, path: String)
signal genetic_code_deleted(id: String)

# ------------------------------------------------------------------------------
# Public API
# ------------------------------------------------------------------------------

func ensure_genetic_code_dir() -> void:
	var da := DirAccess.open("user://")
	if da == null:
		return
	if not da.dir_exists("genetic_codes"):
		da.make_dir("genetic_codes")

func create_genetic_code(id: String, name: String, author: String, organism_type: String, subtype: String) -> GeneticCode:
	var gc := GeneticCode.new()
	gc.id = id
	gc.name = name
	gc.author = author
	gc.organism_type = organism_type   # "fauna" | "flora" | "microorganism"
	gc.subtype = subtype               # e.g., "carnivore" | "herbivore" | "plantae" | "bacteria"
	gc.data_version = 1
	gc.created_at = Time.get_unix_time_from_system()
	gc.ep_allocations = {"attack_pct": 0, "health_pct": 0, "traits_pct": 100}
	gc.priorities = []
	gc.selected_traits = []
	return gc


func save_genetic_code(gc: GeneticCode) -> bool:
	ensure_genetic_code_dir()

	# Defensive checks
	if gc == null:
		push_error("BlueprintService.save_genetic_code: gc is null")
		return false
	if not (gc is Resource):
		push_error("BlueprintService.save_genetic_code: gc is not a Resource")
		return false

	var safe := _safe_filename(gc.id)
	var path := "%s/%s.tres" % [GENETIC_CODES_DIR, safe]

	# Godot 4: Resource first, path second
	var err := ResourceSaver.save(gc, path)
	if err == OK:
		genetic_code_saved.emit(gc.id, path)
		return true

	push_error("BlueprintService.save_genetic_code: save failed (err=%d) for %s" % [err, path])
	return false


func load_genetic_code(id: String) -> GeneticCode:
	var safe := _safe_filename(id)
	var path := "%s/%s.tres" % [GENETIC_CODES_DIR, safe]
	if not FileAccess.file_exists(path):
		return null
	var res := load(path)
	return res as GeneticCode

func list_genetic_codes() -> Array[GeneticCode]:
	ensure_genetic_code_dir()
	var out: Array[GeneticCode] = []
	var da := DirAccess.open(GENETIC_CODES_DIR)
	if da == null:
		return out
	da.list_dir_begin()
	var f := da.get_next()
	while f != "":
		if f.ends_with(".tres"):
			var res := load("%s/%s" % [GENETIC_CODES_DIR, f])
			if res is GeneticCode:
				out.append(res)
		f = da.get_next()
	da.list_dir_end()
	return out

func delete_genetic_code(id: String) -> bool:
	var safe := _safe_filename(id)
	var path := "%s/%s.tres" % [GENETIC_CODES_DIR, safe]
	if not FileAccess.file_exists(path):
		return false
	var da := DirAccess.open(GENETIC_CODES_DIR)
	if da == null:
		return false
	var err := da.remove(path.get_file()) # remove file inside dir
	if err == OK:
		genetic_code_deleted.emit(id)
		return true
	push_error("BlueprintService.delete_genetic_code: failed (%s) for %s" % [err, path])
	return false

# ------------------------------------------------------------------------------
# Simple validation (no ContentDB dependencies yet)
# ------------------------------------------------------------------------------

func validate_genetic_code_simple(gc: GeneticCode) -> Dictionary:
	var errors: Array[String] = []

	# Presence
	if gc.id.strip_edges() == "":
		errors.append("Missing id")
	if gc.name.strip_edges() == "":
		errors.append("Missing name")

	# Organism & subtype
	if not _is_valid_organism(gc.organism_type):
		errors.append("Invalid organism_type: %s" % gc.organism_type)
	if gc.subtype.strip_edges() == "":
		errors.append("Subtype is required")

	# Allocations sum to ~100
	var attack_pct := int(gc.ep_allocations.get("attack_pct", 0))
	var health_pct := int(gc.ep_allocations.get("health_pct", 0))
	var traits_pct := int(gc.ep_allocations.get("traits_pct", 0))
	var total := attack_pct + health_pct + traits_pct
	if abs(total - 100) > 1:
		errors.append("EP allocations must total 100% (±1). Got: %d" % total)

	# Category allocation constraints
	if gc.organism_type == "flora" and attack_pct > 0:
		errors.append("Flora cannot allocate attack_pct > 0")
	if gc.organism_type == "microorganism" and (attack_pct > 0 or health_pct > 0):
		errors.append("Microorganisms cannot allocate attack/health")

	# Selected traits basic structure (no lookups yet)
	for t in gc.selected_traits:
		if not t.has("trait_id"):
			errors.append("Selected trait entry missing 'trait_id'")
			continue
		var trait_id := String(t.get("trait_id"))
		if trait_id.strip_edges() == "":
			errors.append("Selected trait has empty id")
		var stacks := int(t.get("stacks", 1))
		if stacks < 1:
			errors.append("Trait %s must have stacks >= 1" % trait_id)

	return {"is_valid": errors.is_empty(), "errors": errors}

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

func _safe_filename(id: String) -> String:
	return id.replace(".", "_").replace(":", "_").replace("/", "_").replace("\\", "_")

func _is_valid_organism(s: String) -> bool:
	return s == "fauna" or s == "flora" or s == "microorganism"
