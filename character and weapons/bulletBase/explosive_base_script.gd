extends RigidBody3D

class_name Projectile

var triggered = false

var impact_damage : float = 10
var impact_damage_max_falloff : float = 10
var blast_damage : float = 1000
@export var proj_headshot_multiplier : float = 1
@export var bullet = false
@export var explodes = true
@export var contact_impact = false
@export var contact_det = false
@export var fuse_on_impact = true
@export var insta_det = false
@onready var blast_radius = $explosionRadius
@onready var fuse_timer = $fuse_timer
@onready var timeout_timer = $timeout_timer
var projectile_speed : float = 1
var proj_falloff_start
var proj_falloff_end
var AoE_falloff_start : float = 1
var AoE_falloff_end : float = 1.75
var AoE_falloff_reduction : float = 50

var projectile_start
var projectile_end

func _ready():
	set_as_top_level(true)
	if fuse_on_impact == false:
		triggered = true
		print("light the fuse, I was thrown")
		fuse_timer.start()
	if bullet == true:
		timeout_timer.start()
	else:
		pass

func _on_body_entered(_body):
	if bullet == true:
		print("I hit the floor, delete me")
		queue_free()
	if fuse_on_impact == true:
		if not triggered:
			if insta_det == true:
				detenation()
				queue_free()
			elif insta_det == false:
				fuse_timer.start()
				print("light the fuse, I hit the floor")
				triggered = true
	elif fuse_on_impact == false:
		pass

func detenation():
	print("kaboom!")
	var aoe_hit_detect = blast_radius.get_overlapping_areas()
	for hit_obj in aoe_hit_detect:
		var AoE_falloff_distance = self.global_position.distance_to(hit_obj.global_position)
		var normalized_falloff = (AoE_falloff_distance-AoE_falloff_start)/(AoE_falloff_end-AoE_falloff_start)
		if normalized_falloff > 1:
			normalized_falloff = 1
		if normalized_falloff < 0:
			normalized_falloff = 0
		var damage_after_falloff = (normalized_falloff*(blast_damage/100*AoE_falloff_reduction))+((1-normalized_falloff)*blast_damage)
		if hit_obj.is_in_group("team_2") and hit_obj is DamageHitBox:
			print(AoE_falloff_distance)
			hit_obj.take_hit_normal(round(damage_after_falloff))
			print("explosion hit someone")

func _on_timer_timeout():
	if explodes == true:
		detenation()
		queue_free()
	else:
		print("projectile timed out")
		queue_free()

func _on_contact_explosion_area_entered(hit_obj):
	projectile_end = self.global_position
	
	var proj_distance = projectile_start.distance_to(projectile_end)
	
	var normalized_falloff = (proj_distance-proj_falloff_start)/(proj_falloff_end-proj_falloff_start)
	if normalized_falloff > 1:
		normalized_falloff = 1
	if normalized_falloff < 0:
		normalized_falloff = 0
	var damage_after_falloff = (normalized_falloff*impact_damage_max_falloff)+((1-normalized_falloff)*impact_damage)
	if bullet == true:
		if hit_obj.is_in_group("team_2") and hit_obj is DamageHitBox:
			hit_obj.take_hit_normal(round(damage_after_falloff))
			print("bullet hit someone")
			queue_free()
		elif hit_obj.is_in_group("team_2") and hit_obj is HeadHitBox:
			hit_obj.take_hit_normal(round(damage_after_falloff*proj_headshot_multiplier))
		else:
			print("bullet hit a wall")
			queue_free()
	elif contact_impact == true:
		var aoe_hit_detect = blast_radius.get_overlapping_areas()
		for hit_obj2 in aoe_hit_detect:
			if hit_obj2.is_in_group("team_2") and hit_obj is DamageHitBox:
				hit_obj2.take_hit_normal(impact_damage)
				print("projectile hit someone")
			elif hit_obj2.is_in_group("team_2") and hit_obj is HeadHitBox:
				hit_obj2.take_hit_normal(impact_damage)
				print("projectile hit someone")
		if contact_det == true:
			detenation()
			queue_free()


func _on_timeout_timer_timeout():
	queue_free()
