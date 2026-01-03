
# res://scripts/MainMenu.gd
extends Control

# Node references
@onready var title_label      : Label  = $CenterContainer/MenuVBox/TitleLabel
@onready var tutorial_button  : Button = $CenterContainer/MenuVBox/TutorialButton
@onready var duel_button      : Button = $CenterContainer/MenuVBox/DuelButton
@onready var biomes_button    : Button = $CenterContainer/MenuVBox/BiomesButton
@onready var lab_button       : Button = $CenterContainer/MenuVBox/LabButton
@onready var settings_button  : Button = $CenterContainer/MenuVBox/SettingsButton

func _ready() -> void:
	# ---- Set UI text from global Strings autoload ----
	# Ensure you have Strings.gd autoloaded with a TEXTS dictionary.
	title_label.text      = Strings.TEXTS.get("main_menu_title", "Apex: An Evolutionary Card Game")
	tutorial_button.text  = Strings.TEXTS.get("tutorial", "Tutorial")
	duel_button.text      = Strings.TEXTS.get("duel", "Casual Duel (Hotseat)")
	biomes_button.text    = Strings.TEXTS.get("biomes", "Biomes (Decks)")
	lab_button.text       = Strings.TEXTS.get("lab", "Genetic Engineering Lab (Card Creation)")
	settings_button.text  = Strings.TEXTS.get("settings", "Settings")

	# ---- Accessibility: initial focus ----
	if tutorial_button:
		tutorial_button.grab_focus()

	# ---- Connect button signals ----
	tutorial_button.pressed.connect(_on_tutorial_pressed)
	duel_button.pressed.connect(_on_duel_pressed)
	biomes_button.pressed.connect(_on_biomes_pressed)
	lab_button.pressed.connect(_on_lab_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/PlaceholderTutorial.tscn")

func _on_duel_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/PlaceholderDuel.tscn")

func _on_biomes_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/PlaceholderBiomes.tscn")

func _on_lab_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/PlaceholderLab.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/PlaceholderSettings.tscn")

# Esc handling on Main Menu (optional: quit app)
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
