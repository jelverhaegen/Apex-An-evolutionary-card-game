
extends Resource
class_name StatCostTables

@export var base_stats: Dictionary = {} # e.g. {"fauna": {1: {"atk":0,"hp":1}, ...}}
@export var me_tier_ep_additions: Dictionary = {} # e.g. {"fauna": {1: 4, 2: 7, ...}}
@export var attack_ep_steps: Dictionary = {} # e.g. {"fauna": [2,1,2], ...}
@export var health_ep_steps: Dictionary = {} # e.g. {"fauna": [1,1,2], ...}
@export var bounds: Dictionary = {"ep_min_per_increment": 1, "ep_max_per_increment": 10}
@export var data_version: int = 1
