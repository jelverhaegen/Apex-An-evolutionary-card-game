
extends Resource
class_name Biome

@export var id: String = ""
@export var name: String = ""
@export var owner: String = ""
@export var features: Array[String] = []
@export var cards: Array[Resource] = [] # Will use CardEntry resources
@export var validation_state: Dictionary = {"is_valid": true, "errors": []}
@export var created_at: int = 0
@export var updated_at: int = 0
@export var data_version: int = 1
