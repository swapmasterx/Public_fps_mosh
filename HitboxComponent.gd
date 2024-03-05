extends Area3D
class_name DamageHitBox

@export var health_component : HealthComponent

func take_hit_normal(damage):
	if health_component:
		health_component.take_damage(damage)
