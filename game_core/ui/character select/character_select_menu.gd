extends Control
class_name Character_Menu

@onready var char_menu = %Char_Menu
@onready var esc_menu = %GameEscMenu

func _input(event):
	if event.is_action_pressed("Change Character"):
		if esc_menu.visible == true:
			pass
		else:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				GlobalSignals.menu_on.emit()
			elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				GlobalSignals.menu_off.emit()
			char_menu.visible = !char_menu.visible
