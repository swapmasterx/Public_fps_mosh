extends Node3D

var shotty_guy = preload("res://character and weapons/classes/Damage/shotgun/shotty_demo.tscn")
#var Axel_demo = preload("res://character and weapons/classes/Roamer/Axel/Axel.tscn")
#var ROSE_MAN = preload("res://character and weapons/classes/Pick/Rose_man/Rose_man.tscn")
var char_fill: String = "Your character has yet to be"
func get_character_ID(char_ID):
	match char_ID:
		0:
			print("If you see this then you are using the default ID which should not change character.")
		1:
			print(char_fill)
		2:
			print(char_fill)
		3:
			print(char_fill)
		4:
			print(char_fill)

