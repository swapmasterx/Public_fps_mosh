extends TextureRect

@export var totalHP: HealthComponent

@onready var setmaxHPnodes = totalHP.maxHP

func _set(property, value):
	Transform2D()
