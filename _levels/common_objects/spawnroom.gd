extends Area3D

class_name SpawnRoom

@export var team_designation: int = 0
@export var spawnroom_id: int = 0
var occupied = false
@onready var spawnroom = $"."


func _on_body_entered(_body):
	GlobalSignals.entered_spawn.emit()

func _on_body_exited(_body):
	GlobalSignals.left_spawn.emit()
