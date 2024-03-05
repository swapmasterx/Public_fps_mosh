extends PanelContainer

@onready var debug_panel = %DebugPanel

func _process(delta):
	if visible:
		pass

func _input(event):
	if event.is_action_pressed("Character Debug"):
		debug_panel.visible = !debug_panel.visible

func add_property(title:String, value, order):
	var target
	target = $MarginContainer/VBoxContainer.find_child(title, true, false)
	if !target:
		target = Label.new()
		$MarginContainer/VBoxContainer.add_child(target)
		target.name = title
		target.text = title + ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value)
		$MarginContainer/VBoxContainer.move_child(target, order)
