
extends Resource
class_name GeneticCode

@export var id: String = ""
@export var name: String = ""
@export var author: String = ""
@export var organism_type: String = ""
@export var subtype: String = ""
@export var priorities: Array[Dictionary] = [] # e.g. [{"type":"health_min","value":5}]
@export var ep_allocations: Dictionary = {} # e.g. {"attack_pct":40,"health_pct":40,"traits_pct":20}
@export var selected_traits: Array[Dictionary] = [] # e.g. [{"trait_id":"trait.stealth","stacks":1}]
@export var notes: String = ""
@export var created_at: int = 0
@export var data_version: int = 1
