extends Label

@onready var slider_val = $"../player count"

func _process(_delta):
	set_text(str(slider_val.value))
