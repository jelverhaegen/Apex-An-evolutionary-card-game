
extends Resource
class_name TraitDef

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var categories: Array[String] = []
@export var is_single_instance: bool = true
@export var ep_bounds: Dictionary = {"min": 1, "max": 10}
@export var current_ep_steps: Array[int] = []
@export var stacking_rules: Dictionary = {}
@export var ui_tags: Array[String] = []
@export var data_version: int = 1
@export var allowed_subtypes_by_category: Dictionary = {} 
