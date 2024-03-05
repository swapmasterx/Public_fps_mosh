extends Control
class_name game_esc_menu

@export var action_items: Array[String]

@onready var Mus_bus_ID = AudioServer.get_bus_index("MUS")
@onready var Sfx_bus_ID = AudioServer.get_bus_index("SFX")
@onready var menu = %GameEscMenu
@onready var settings_grid_container = %SettingsGridContainer
@onready var main_menu_button = %"Main Menu"
@onready var menu_primary = %prime_menu
@onready var menu_0 = %menu_0
@onready var char_menu = %Char_Menu


var Menu_Origin_pos = Vector2.ZERO
var Menu_Origin_size = Vector2.ZERO

var menu_transition_time : float = 0.5

var current_Menu
var Menu_stack = []

func _ready():
	Menu_Origin_pos = Vector2 (0,0)
	Menu_Origin_size = get_viewport_rect().size
	current_Menu = menu_primary
	create_action_remap_items()

func move_to_next_menu(next_menu_id: String):
	var next_menu = menu_from_menu_ID(next_menu_id)
	current_Menu.global_position = Vector2(-Menu_Origin_size.x,0)
	next_menu.global_position = Menu_Origin_pos
	Menu_stack.append(current_Menu)
	current_Menu = next_menu
	
func move_to_prev_menu():
	var previous_menu = Menu_stack.pop_back()
	if previous_menu != null:
		previous_menu.global_position = Menu_Origin_pos
		current_Menu.global_position = Vector2(+Menu_Origin_size.x,0)
		current_Menu = previous_menu

func menu_from_menu_ID(menu_id: String) -> Control:
	match menu_id:
		"menu_primary":
			return menu_primary
		"menu_0":
			return menu_0
		_:
			return menu_primary

func _on_options_pressed():
	move_to_next_menu("menu_0")

func _on_back_pressed():
	move_to_prev_menu()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if char_menu.visible == true:
			char_menu.visible = !char_menu.visible
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				GlobalSignals.menu_off.emit()
		else:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				GlobalSignals.menu_on.emit()
			elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				GlobalSignals.menu_off.emit()
			menu.visible = !menu.visible

func _on_mus_slider_value_changed(value):
	AudioServer.set_bus_volume_db(Mus_bus_ID, linear_to_db(value))
	AudioServer.set_bus_mute(Mus_bus_ID, value < .05)


func _on_sound_slider_value_changed(value):
	AudioServer.set_bus_volume_db(Sfx_bus_ID, linear_to_db(value))
	AudioServer.set_bus_mute(Sfx_bus_ID, value < .05)

#Control input editing 
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
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GlobalSignals.menu_off.emit()

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://game_core/ui/menus/main_menu.tscn")

func _on_quit_game_pressed():
	get_tree().quit()
