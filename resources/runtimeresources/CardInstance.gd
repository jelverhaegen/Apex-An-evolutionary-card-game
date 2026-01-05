
extends Resource
class_name CardInstance

@export var source: Dictionary = {} # {"genetic_code_id": "", "me_cost": 1}
@export var organism_type: String = ""
@export var subtype: String = ""
@export var final_stats: Dictionary = {} # {"attack": 0, "health": 0, "ep_spent": {"attack":0,"health":0,"traits":0}}
@export var final_traits: Array[Dictionary] = [] # [{"trait_id":"trait.stealth","stacks":1,"ep_total":2}]
@export var runtime_state: Dictionary = {} # {"current_health":0,"damage_taken":0,"ready":true,"used":false}
@export var zone: String = ""
@export var flags: Dictionary = {}
@export var instance_id: int = 0
