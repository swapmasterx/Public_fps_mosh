extends Control
class_name game_esc_ui

signal start_game()

@export var action_items: Array[String]

@onready var Mus_bus_ID = AudioServer.get_bus_index("MUS")
@onready var Sfx_bus_ID = AudioServer.get_bus_index("SFX")
@onready var menu = %GameEscMenu
@onready var settings_grid_container = %SettingsGridContainer
@onready var main_menu_button = %main_menu

func _ready():
	create_action_remap_items()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		menu.visible = !menu.visible

func _on_mus_slider_value_changed(value):
	AudioServer.set_bus_volume_db(Mus_bus_ID, linear_to_db(value))
	AudioServer.set_bus_mute(Mus_bus_ID, value < .05)


func _on_sound_slider_value_changed(value):
	AudioServer.set_bus_volume_db(Sfx_bus_ID, linear_to_db(value))
	AudioServer.set_bus_mute(Sfx_bus_ID, value < .05)

func create_action_remap_items() -> void:
	var previous_item = settings_grid_container.get_child(settings_grid_container.get_child_count() - 1)
	for index in range(action_items.size()):
		var action = action_items[index]		
		var label = Label.new()
		label.text = action
		settings_grid_container.add_child(label)
		
		var button = RemapButton.new()
		button.action = action
		button.focus_neighbor_top = previous_item.get_path()
		previous_item.focus_neighbor_bottom = button.get_path()
		if index == action_items.size() - 1:
			main_menu_button.focus_neighbor_top = button.get_path()
			button.focus_neighbor_bottom = main_menu_button.get_path()
		previous_item = button
		settings_grid_container.add_child(button)

func _on_return_to_game_pressed():
	menu.visible = !menu.visible

func _on_quit_pressed():
	get_tree().quit()
	
func _on_main_menu_start_game() -> void:
	start_game.emit()

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://game_core/ui/menus/main_menu.tscn")
