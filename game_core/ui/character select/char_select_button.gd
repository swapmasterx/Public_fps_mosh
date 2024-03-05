extends TextureButton

signal char_change

@export var char_name: String = "#char_name#"
@export var char_prev_image: Texture2D
@export_range(0,3) var char_ID: int

@onready var char_name_text = %charName
@onready var char_link = $"../../../../../../"
@onready var char_menu = $"../../../"
@onready var char_prev_placeholder = $"../../../MarginContainer2/char_prev_placeholder"

func _process(_delta):
	char_name_text.set_text(str(char_name))

func _on_pressed():
	if char_link.in_spawn == true:
		ChangeCharacterHandler.get_character_ID(char_ID)
	
	elif char_link.in_spawn == false:
		print("You need to be in a spawn room to change characters.")

func _on_mouse_entered():
	if disabled == false:
		char_prev_placeholder.texture = char_prev_image
