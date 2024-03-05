extends RigidBody3D

class_name GenericProjectile

@export var shoot = false

@export var impact_damage : float = 250
@export var blast_damage : float = 1000
@export var projectile_speed : float = 1

func _ready():
	set_as_top_level(true)
	
func _physics_process(delta):
	if shoot:
		apply_central_impulse(transform.basis.z * projectile_speed)
		shoot = false


func _on_timer_timeout():
	print("projectile timed out")
	queue_free()


func _on_area_3d_area_entered(hit_obj):
	if hit_obj.is_in_group("team_2") and hit_obj is DamageHitBox:
		hit_obj.take_hit_normal(impact_damage)
		print("bullet hit someone")
		queue_free()
	else:
		print("bullet hit a wall")
		queue_free()



func _on_body_entered(body):
	print("bullet hit hit a wall")
	queue_free()
