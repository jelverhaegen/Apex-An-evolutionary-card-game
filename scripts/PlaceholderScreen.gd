
# res://scripts/PlaceholderScreen.gd
extends Control

# Set this in the Inspector per scene:
#   PlaceholderTutorial.tscn  -> "placeholder_tutorial"
#   PlaceholderDuel.tscn      -> "placeholder_duel"
#   PlaceholderBiomes.tscn    -> "placeholder_biomes"
#   PlaceholderLab.tscn       -> "placeholder_lab"
#   PlaceholderSettings.tscn  -> "placeholder_settings"
@export var title_key: String = ""

# Node references (adjust names if your nodes differ)
@onready var info_label : Label  = $InfoLabel
@onready var back_button: Button = $BackButton

func _ready() -> void:
	# ----- Apply localized text from Strings autoload -----
	# Title/Info line
	if info_label:
		info_label.text = Strings.TEXTS.get(title_key, "Coming soon")
	else:
		push_warning("InfoLabel node not found in this scene.")

	# Back button label
	if back_button:
		back_button.text = Strings.TEXTS.get("back", "Back")
		back_button.pressed.connect(_on_back_button_pressed)
		back_button.grab_focus() # accessibility: allow immediate Enter/Space
	else:
		push_warning("BackButton node not found in this scene.")

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

# Esc returns to Main Menu from any placeholder screen
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
