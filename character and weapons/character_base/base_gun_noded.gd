extends Node3D
class_name WeaponSlot



@export_category("Components")
@export var buff_grab : CharacterBody3D
@export var body_hit_effect : bool = false
@export var crit_hit_effect : bool = false
@export var firing_effect : bool = false
@export var is_buffable = true
@export var stats : WeaponStats
@onready var spread_curve: Path2D = %spread
@onready var muzzle = %muzzle
@onready var melee_box = %Area3D
@onready var controls = $"../../../Controls"
@export var ability_lockout_handler : ALH

var headshot_multiplier_bonus : float = 0.0
var damage_multiplier : float = 0.0
var attack_speed_multiplier : float = 0.0
var infinite_ammo = false
var can_fire = true
var reloading = false
var spray_vector
enum {NULL, BUFF, HITSCAN, PROJECTILE, SHOTGUN}
@onready var camera = $".."
@export var Anim : AnimationPlayer
@export var decal = preload("res://character and weapons/character_base/bullet_debug.tscn")

var menu_active : bool = false

func _ready():
	whoWasPunched.clear()
	reloading = false
	can_fire = true
	stats.ammo = stats.max_ammo
	GlobalSignals.menu_on.connect(on_menu_on)
	GlobalSignals.menu_off.connect(on_menu_off)
	spray_vector = spread_curve.get_curve()
	ability_lockout_handler.disable_lockout(stats.Primary_lockout_check, stats.AltFire_lockout_check, stats.Ability1_lockout_check, stats.Ability2_lockout_check)

func on_menu_on():
	menu_active = true

func on_menu_off():
	menu_active = false

var distance

func Get_Camera_Collision(_spread: Vector2 = Vector2.ZERO):
	var cameraRay = get_viewport().get_camera_3d()
	var viewport = get_viewport().get_size()
	
	var rayOrigin = cameraRay.project_ray_origin(viewport/2)
	var rayEnd = (rayOrigin + cameraRay.project_ray_normal((viewport/2)+Vector2i(_spread))*stats.rangeValue)
	
	var newIntersection = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd)
	newIntersection.set_collision_mask(0b11_10010000)
	newIntersection.set_collide_with_areas(true)
	
	var intersect = get_world_3d().direct_space_state.intersect_ray(newIntersection)
	
	if not intersect.is_empty():
		distance = rayOrigin.distance_to(intersect.position)
		print(distance)
		var colPoint = intersect.position
		return colPoint
	else:
		return rayEnd

func empty():
	if not reloading and stats.ammo <= 0: 
		reload()
		print ("reloading")
		

func _physics_process(delta):
	recoil_recovery(delta)
	if stats.ammo <= 0:
		can_fire = false
	if menu_active == false:
		shooting_options()

var burst_fire_count: int = 0

func firing_types(input):
	match stats.firing_type:
	#single fire
			0:
				if Input.is_action_just_pressed(input):
					fire()
					print ("shooting single")
					empty()
	#automatic fire
			1:
				fire()
				print ("shooting auto")
				empty()
	#burst fire
			2:
				ability_lockout_handler.enable_lockout(stats.Primary_lockout_check, stats.AltFire_lockout_check, stats.Ability1_lockout_check, stats.Ability2_lockout_check)
				while burst_fire_count < stats.burstfire_shot_count and stats.ammo > 0:
					burst_fire()
					#print ("shooting burst")
					empty()
					burst_fire_count += 1
					await get_tree().create_timer(stats.burstfire_delay).timeout
				if burst_fire_count >= stats.burstfire_shot_count:
					await get_tree().create_timer(stats.burstfire_lockout).timeout
					ability_lockout_handler.disable_lockout(stats.Primary_lockout_check, stats.AltFire_lockout_check, stats.Ability1_lockout_check, stats.Ability2_lockout_check)
					burst_fire_count = 0
				
					
	#charge shot
			3:
				print ("is charging")
				if Input.is_action_just_released(input):
					print ("is shooting")
					fire()
					empty()
	#ability with duration, buff for self
			4:
				fire()
				print ("using ability duration")
				buff_grab.buff_apply(stats.buff_handler_1)
				empty()
		#prime then fire
			5:
				print ("priming ability")
				Input.is_action_just_pressed(input)
				fire()
				print ("using ability primed")
				empty()
		#ability with duration, buff for self, interupts primary
			6:
				fire()
				print ("using ability duration, disables primary WIP")
				buff_grab.buff_apply(stats.buff_handler_1)
				await get_tree().create_timer(stats.ability_duration).timeout
				empty()
			#shoot with prefire delay
			7:
				print ("shoot with prefire delay")
				await get_tree().create_timer(stats.ability_duration).timeout
				fire()
				empty()
			#buff and shoot with prefire delay
			8:
				can_fire = false
				print ("buff and shoot with prefire delay")
				buff_grab.buff_apply(stats.buff_handler_1)
				ability_lockout_handler.enable_lockout(stats.Primary_lockout_check, stats.AltFire_lockout_check, stats.Ability1_lockout_check, stats.Ability2_lockout_check)
				await get_tree().create_timer(stats.ability_duration).timeout
				ability_lockout_handler.disable_lockout(stats.Primary_lockout_check, stats.AltFire_lockout_check, stats.Ability1_lockout_check, stats.Ability2_lockout_check)
				fire()
				empty()
			#cancelble reload
			9:
				if reloading == true and stats.ammo > 0:
					if Input.is_action_just_pressed(input):
						end_reload()
						empty()
				if can_fire == true and stats.ammo > 0 :
					fire()
					#print ("shooting auto")
					empty()
				
	#if Input.is_action_pressed(str(stats.input)) and reloading == true:
		#end_reload()

func shooting_options():
	if stats.can_manually_reload == true:
		if Input.is_action_just_pressed("reload") and not reloading and stats.ammo < stats.max_ammo:
			reload()
			print ("reloading")
	match stats.weapon_slot:
		1:
			if Input.is_action_pressed(controls.Primary) and can_fire and ability_lockout_handler.primary_input == true:
				burst_fire_count = 0
				firing_types(controls.Primary)
		2:
			if Input.is_action_pressed(controls.Alt_Fire) and can_fire and ability_lockout_handler.altfire_input == true:
				burst_fire_count = 0
				firing_types(controls.Alt_Fire)
		3:
			if Input.is_action_pressed("ability1") and can_fire and ability_lockout_handler.ability1_input == true:
				burst_fire_count = 0
				firing_types("ability1")
		4:
			if Input.is_action_pressed("ability2") and can_fire and ability_lockout_handler.ability2_input == true:
				burst_fire_count = 0
				firing_types("ability2")
		5:
			if Input.is_action_pressed("shoot") and ability_lockout_handler.primary_input == true:
				firing_types("shoot")
		
		
func gun_anim():
	if Anim != null:
		Anim.stop(true)
		Anim.play(str(stats.fire_animation_call))

#melee detection variables

var whoWasPunched: Array = []
var meleebox_checktime
var meleebox_active: bool = false
func melee_hitbox():
	whoWasPunched.clear()
	meleebox_checktime = get_tree().create_timer(stats.melee_box_duration)
	meleebox_checktime.timeout.connect(on_melee_box_timeout)
	meleebox_active = true
	while meleebox_active == true:
		for hit_obj in melee_box.get_overlapping_areas():
			if whoWasPunched.has(hit_obj):
				pass
			else:
				if hit_obj.is_in_group("team_2") and hit_obj is DamageHitBox:
					hit_obj.take_hit_normal(stats.damage)
					whoWasPunched.append(hit_obj)
		await get_tree().create_timer(0.1).timeout
	

func on_melee_box_timeout():
	meleebox_active = false
	whoWasPunched.clear()
	
func fire_shotgun(_spread):
	var cam_col_2 = Get_Camera_Collision(_spread)
	hit_scan_gun(cam_col_2)

func weapon_proj_sets():
	var camCollision = Get_Camera_Collision()
	match stats.Type2:
		NULL:
			print("no type set")
		BUFF:
			#print("using buff")
			buff_weapon(camCollision)
		HITSCAN:
			#print("using hitscan")
			hit_scan_gun(camCollision)
		PROJECTILE:
			#print("using projectile")
			launch_projectile(camCollision)
		SHOTGUN:
			#print("using shotgun")
			shotgun_gun()

var firing_speed

func firingSpeed_and_ammoConsumption():
	firing_speed = stats.firing_speed * buff_grab.firing_speed_multiplier
	can_fire = false
	if stats.is_primary == true:
		if buff_grab.infinite_ammo == false:
			stats.ammo -= stats.ammo_per_shot
			stats.ammo = max(stats.ammo, 0)
		if buff_grab.infinite_ammo == true:
			stats.ammo -= 0
	else:
		stats.ammo -= stats.ammo_per_shot

func burst_fire():
	firingSpeed_and_ammoConsumption()
	weapon_proj_sets()
	gun_anim()
	stats.recoil()
	if stats.uses_melee_box == true:
		melee_hitbox()
	await get_tree().create_timer(firing_speed).timeout
	if not reloading:
		can_fire = true

func fire():
	firingSpeed_and_ammoConsumption()
	weapon_proj_sets()
	gun_anim()
	stats.recoil()
	if stats.uses_melee_box == true:
		melee_hitbox()
	ability_lockout_handler.enable_lockout(stats.Primary_lockout_check, stats.AltFire_lockout_check, stats.Ability1_lockout_check, stats.Ability2_lockout_check)
	await get_tree().create_timer(firing_speed).timeout
	ability_lockout_handler.disable_lockout(stats.Primary_lockout_check, stats.AltFire_lockout_check, stats.Ability1_lockout_check, stats.Ability2_lockout_check)
	if not reloading:
		can_fire = true

func buff_weapon(_camCollision):
	pass

func hit_scan_gun(colPoint):
	var bulletDirection = (colPoint - muzzle.get_global_transform().origin).normalized()
	var newIntersect = PhysicsRayQueryParameters3D.create(muzzle.get_global_transform().origin,colPoint+bulletDirection*2)
	newIntersect.set_collision_mask(0b11_10010000)
	newIntersect.set_collide_with_areas(true)
	var bulletCollision = get_world_3d().direct_space_state.intersect_ray(newIntersect)
	
	if bulletCollision:
		var bulMark = decal.instantiate()
		var world = get_tree().get_root().get_child(0)
		world.add_child(bulMark)
		bulMark.global_translate(bulletCollision.position)
		hit_scan_damage(bulletCollision.collider)



func hit_scan_damage(collider):
	var normalized_falloff = (distance-stats.damage_falloff_start)/(stats.damage_falloff_end-stats.damage_falloff_start)
	if normalized_falloff > 1:
		normalized_falloff = 1
	if normalized_falloff < 0:
		normalized_falloff = 0
	var damage_after_falloff = (normalized_falloff*stats.damage_maxFalloff)+((1-normalized_falloff)*stats.damage)
	
	var damage
	if is_buffable == true:
		damage = ((damage_after_falloff * buff_grab.damage_multiplier)/stats.projectiles_per_shot)
		if collider.is_in_group("team_2") and collider is DamageHitBox:
			collider.take_hit_normal(round(damage))
		elif collider.is_in_group("team_2") and collider is HeadHitBox:
			collider.take_hit_normal(round(damage*stats.headshot_multiplier))
			if crit_hit_effect == true:
				buff_grab.buff_apply(stats.crit_hit_effect)
	elif is_buffable == false:
		damage = damage_after_falloff/stats.projectiles_per_shot
		if collider.is_in_group("team_2") and collider is DamageHitBox:
			collider.take_hit_normal(round(damage))
		elif collider.is_in_group("team_2") and collider is HeadHitBox:
			collider.take_hit_normal(round(damage*stats.headshot_multiplier))

func launch_projectile(Point: Vector3):
	var Direction = (Point - muzzle.get_global_transform().origin).normalized()
	var Proj = stats.projectileToLoad.instantiate()
	Proj.set_linear_velocity(Direction*stats.projectileSpeed)
	#Proj.projectile_speed = stats.projectileSpeed
	muzzle.add_child(Proj)
	var projectile_start = Proj.global_position
	#Proj.projectile_end
	Proj.projectile_start = projectile_start
	Proj.proj_falloff_start = stats.damage_falloff_start
	Proj.proj_falloff_end = stats.damage_falloff_end
	Proj.AoE_falloff_start = stats.AoE_falloff_start
	Proj.AoE_falloff_end = stats.AoE_falloff_end
	Proj.AoE_falloff_reduction = stats.AoE_falloff_reduction
	
	if is_buffable == true:
		var damage_i = stats.damage * buff_grab.damage_multiplier
		var damage_imf = stats.damage_maxFalloff * buff_grab.damage_multiplier
		var damage_b = stats.blast_damage * buff_grab.damage_multiplier
		Proj.impact_damage = damage_i
		Proj.impact_damage_max_falloff = damage_imf
		Proj.blast_damage = damage_b 
		Proj.proj_headshot_multiplier = stats.headshot_multiplier
	elif is_buffable == false:
		Proj.impact_damage = stats.damage
		Proj.impact_damage_max_falloff = stats.damage_maxFalloff
		Proj.blast_damage = stats.blast_damage
		Proj.proj_headshot_multiplier = stats.headshot_multiplier

func shotgun_gun():
	randomize()
	print(str(spray_vector))
	for point in spray_vector.get_point_count():
		var SprayPoint:Vector2 = spray_vector.get_point_position(point)
		
		SprayPoint.x = SprayPoint.x + randf_range(-stats.spread_random, stats.spread_random)
		SprayPoint.y = SprayPoint.y + randf_range(-stats.spread_random, stats.spread_random)
		
		fire_shotgun(SprayPoint)
		
func recoil_recovery(delta):
	if stats.recoil_enabled == true:
		stats.vertical_angle = lerp(stats.vertical_angle, 0.0, stats.recoil_recovery_speed * delta)
		stats.horizontal_angle = lerp(stats.horizontal_angle, 0.0, stats.recoil_recovery_speed * delta)
		camera.rotation_degrees.x = stats.vertical_angle
		camera.rotation_degrees.y = stats.horizontal_angle

func breach_loading():
	while stats.ammo < stats.max_ammo:
		await get_tree().create_timer(stats.reload_speed).timeout
		if Anim != null:
			Anim.play(str(stats.reload_animation_call))
		stats.ammo += stats.breach_load_count

func reload():
	reloading = true
	can_fire = false
	if Anim != null:
		Anim.play(str(stats.reload_animation_call))
	await get_tree().create_timer(stats.ability_duration).timeout
	await get_tree().create_timer(stats.reload_speed).timeout
	if reloading == true:
		if stats.breach_load == true:
			while stats.ammo < stats.max_ammo and reloading == true:
				await get_tree().create_timer(stats.reload_speed).timeout
				if reloading == true:
					if Anim != null:
						Anim.play(str(stats.breach_reload_animation_call))
					stats.ammo += stats.breach_load_count
		else:
			if reloading == true:
				var ammo_to_add = (stats.max_ammo - stats.ammo)
				stats.ammo += ammo_to_add
	if stats.ammo == stats.max_ammo:
		end_reload()

func end_reload():
	if stats.ammo > 0:
		can_fire = true
	reloading = false

func ammo_value_cap():
	stats.ammo = max (stats.ammo, stats.max_ammo)
	stats.ammo = min (stats.ammo, 0)


