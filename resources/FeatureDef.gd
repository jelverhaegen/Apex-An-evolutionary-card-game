
extends Resource
class_name FeatureDef

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var unlocks_by_category: Dictionary = {} # e.g. {"fauna": ["trait.stealth"]}
@export var data_version: int = 1
