extends Node3D


func _on_bullet_hole_despawn_timeout():
	die()

func die():
	queue_free()
