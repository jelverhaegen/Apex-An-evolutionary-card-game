
# res://scripts/PlaceholderScreen.gd
extends Control

# Set this in the Inspector per scene:
#   PlaceholderTutorial.tscn   -> "placeholder_tutorial"
#   PlaceholderDuel.tscn       -> "placeholder_duel"
#   PlaceholderBiomes.tscn     -> "placeholder_biomes"
#   PlaceholderLab.tscn        -> "placeholder_lab"
#   PlaceholderSettings.tscn   -> "placeholder_settings"
@export var title_key: String = ""

# Robust lookup: find nodes by name anywhere under this root.
# The second parameter (recursive=true) searches through all descendants.
@onready var info_label : Label  = find_child("InfoLabel", true, false)
@onready var back_button: Button = find_child("BackButton", true, false)

func _ready() -> void:
	# ----- Apply localized text from Strings autoload -----
	if info_label:
		info_label.text = Strings.TEXTS.get(title_key, "Coming soon")
	else:
		push_warning('InfoLabel node not found (ensure a Label named "InfoLabel" exists).')

	if back_button:
		back_button.text = Strings.TEXTS.get("back", "Back")
		back_button.pressed.connect(_on_back_button_pressed)
		back_button.grab_focus() # accessibility: allow immediate Enter/Space
	else:
		push_warning('BackButton node not found (ensure a Button named "BackButton" exists).')

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

# Esc returns to Main Menu from any placeholder screen
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
