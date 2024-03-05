extends CharacterBody3D

class_name Playable_Character


# TODO: Add descriptions for each value

@export_category("Character")

@export_enum("Brute","Damage","Objective","Pick","Roamer","Support") var class_type
@export_enum("Team 0", "Team 1", "Team 2") var team = 1
@export var player := 1 :
	set(id):
		player = id
		$Controls.set_multiplayer_authority(id)
@export var base_speed : float = 5.0
@export var crouch_speed : float = 1.0
@export var acceleration : float = 10.0
@export var jump_velocity : float = 4.5
@export var jump_total : int = 0
@export var mouse_sensitivity : float = 0.1

@export_group("Nodes")
var stats : Buff
@export var HEAD : Node3D
@export var CAMERA : Camera3D
@export var CAMERA_ANIMATION : AnimationPlayer
@export var COLLISION_MESH : CollisionShape3D
@export var HEALTHCOMPONENT : HealthComponent
@export var Primary : WeaponSlot
@export var HITBOX : DamageHitBox
@export var HEADHITBOX : HeadHitBox

@export_group("Controls")
@onready var input = $Controls
@export var JUMP : String = "jump"
@export var LEFT : String = "move_left"
@export var RIGHT : String = "move_right"
@export var FORWARD : String = "move_forward"
@export var BACKWARD : String = "move_back"
@export var PAUSE : String = "ui_cancel"
@export var CROUCH : String = "crouchCtrl"


@export_group("Feature Settings")
var jumping_enabled : bool = true
@export var in_air_momentum : bool = true
@export var motion_smoothing : bool = false
var crouch_enabled : bool = true
@export_enum("Hold to Crouch", "Toggle Crouch") var crouch_mode : int = 0
@export var dynamic_fov : bool = true
@onready var dash_timer = %dash_timer

# Buff tracker lists
var duration_time : float = -1
var buffers : Array = []
var damage_multiplier : float
var firing_speed_multiplier : float
var infinite_ammo = false
var quickreload : int
var damage_taken_multi : float
var healing_received_multi : float
var self_damage : float
#var dot_duration : float
var dot_damage : float
#var dot_damage_rate : float
var move_speed_mult : float
var jump_hight_mult : float
var grounded_dash_active = false
var directional_dash_active = false
var leap_active = false
var omni_dash_active = false
var dash_time : float
var dash_speed : float

var vel := Vector3.ZERO
var extraVel := Vector3.ZERO

# Member variables
var speed : float = base_speed
# States: normal, crouching, sprinting
var state : String = "normal"
var low_ceiling : bool = false # This is for when the cieling is too low and the player needs to crouch.

var jump_count : int = 0
# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") # Don't set this as a const, see the gravity section in _physics_process

var menu_active : bool = false

var in_spawn : bool = false

func _ready():
	if player == multiplayer.get_unique_id():
		$head/Camera3D.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GlobalSignals.menu_on.connect(on_menu_on)
	GlobalSignals.menu_off.connect(on_menu_off)
	GlobalSignals.entered_spawn.connect(while_in_spawn)
	GlobalSignals.left_spawn.connect(not_in_spawn)
	update_multipliers()

func on_menu_on():
	print ("char menulock on")
	menu_active = true

func on_menu_off():
	print ("char menulock off")
	menu_active = false

func while_in_spawn():
	print ("in spawn")
	in_spawn = true

func not_in_spawn():
	print ("left spawn")
	in_spawn = false

func buff_apply(data:Buff):
	if data.duration != 0:
		var bufftimer:Timer = Timer.new()
		bufftimer.one_shot = true
		add_child(bufftimer)
		bufftimer.timeout.connect(remove_buff.bind(data, bufftimer))
		bufftimer.start(data.duration)
		str(data.duration)
	#weapon buffs
	buffers.append(data)
	update_multipliers()

func update_multipliers():
	damage_multiplier = 1.0
	firing_speed_multiplier = 1.0
	infinite_ammo = false
	quickreload = 0
	damage_taken_multi = 1.0
	healing_received_multi = 1.0
	self_damage = 0
	#dot_duration = 0.0
	dot_damage = 0.0
	#dot_damage_rate = 0
	move_speed_mult = 1.0
	jump_hight_mult = 1.0
	dash_time = 0.0
	dash_speed = 0.0
	grounded_dash_active = false
	directional_dash_active = false
	leap_active = false
	omni_dash_active = false
	for data in buffers:
		damage_multiplier += data.damage_multiplier
		firing_speed_multiplier += data.attack_speed_multiplier
		if data.infinite_ammo == true:
			infinite_ammo = true
		quickreload += data.quickreload
		damage_taken_multi += data.damage_taken_mult
		healing_received_multi += data.healing_received_multi
		#dot_duration += data.dot_duration
		dot_damage += data.dot_damage
		#dot_damage_rate += data.dot_damage_rate
		move_speed_mult += data.move_speed_mult 
		jump_hight_mult += data.jump_hight_mult
		self_damage = data.self_damage
		dash_time += data.dash_time
		dash_speed += data.dash_speed
		if data.grounded_dash_active == true:
			dash_timer.wait_time = dash_time
			print(dash_timer.wait_time)
			dash_timer.start()
			grounded_dash_active = true
		if data.directional_dash_active == true:
			directional_dash_active = true
		if data.leap_active == true:
			leap_active = true
			dash_timer.wait_time = dash_time
			print(dash_timer.wait_time)
			dash_timer.start()
		if data.omni_dash_active == true:
			omni_dash_active = true
	if quickreload > 0:
		print("quickload activated")
		if Primary:
			Primary.stats.ammo = quickreload
			Primary.end_reload()
		else: 
			print("No primary defined")
		
	HEALTHCOMPONENT.take_damage(self_damage)
	self_damage = 0

func remove_buff(data, bufftimer = null):
#remove your buff modifiers
	print("buff timout called")
	if bufftimer != null:
		damage_multiplier -= data.damage_multiplier
		firing_speed_multiplier -= data.attack_speed_multiplier
		infinite_ammo = false
		quickreload -= data.quickreload
		damage_taken_multi -= data.damage_taken_mult
		healing_received_multi -= data.healing_received_multi
		#dot_duration -= data.dot_duration
		dot_damage -= data.dot_damage
		#dot_damage_rate -= data.dot_damage_rate
		move_speed_mult -= data.move_speed_mult 
		jump_hight_mult -= data.jump_hight_mult
		grounded_dash_active = false
		directional_dash_active = false
		leap_active = false
		omni_dash_active = false
		dash_time -= data.dash_time
		dash_speed -= data.dash_speed
		buffers.remove_at(0)
		bufftimer.queue_free()

func leap_logic() -> void:
	set_velocity(($Head/Camera3D.global_transform.origin - $Head.global_transform.origin).normalized()*dash_speed)
	velocity.y = gravity 

func grounded_dash_logic(delta: float) -> void:
	if not is_on_floor():
		set_velocity(($head/Camera3D.global_transform.origin - $head.global_transform.origin).normalized()*dash_speed)
		velocity.y = gravity * delta
	elif is_on_floor():
		set_velocity(($head/Camera3D.global_transform.origin - $head.global_transform.origin).normalized()*dash_speed)
		velocity.y = -2
	#velocity.y = gravity * delta
	


func _physics_process(delta: float):

	# Add some debug data
	$HealthComponent/UserInterface/DebugPanel.add_property("Movement Speed", base_speed * move_speed_mult, 1)
	$HealthComponent/UserInterface/DebugPanel.add_property("Velocity", get_real_velocity(), 2)
	# Gravity
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity") # If the gravity changes during your game, uncomment this code
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		jump_count = 0
	
	if grounded_dash_active == true:
		grounded_dash_logic(delta)
	if leap_active == true:
		leap_logic()
	
	handle_jumping()
	
	var input_dir = Vector2.ZERO
	if menu_active == false:
		input_dir = $Controls.direction
	handle_movement(delta, input_dir)
	
	low_ceiling = $CrouchCeilingDetection.is_colliding()
	
	handle_state(input_dir)

	update_camera_fov()
	update_collision_scale()

func handle_jumping():
	var total_jump = jump_velocity * jump_hight_mult
	if jumping_enabled:
		if menu_active == false:
			if input.jumping:
				if is_on_floor():
					velocity.y += total_jump
				if not is_on_floor():
					jump_count += 1
					if (jump_count <= jump_total):
						velocity.y = 0
						velocity.y += total_jump
	input.jumping = false

func handle_movement(delta, input_dir):
	var direction = input_dir.rotated(-HEAD.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	move_and_slide()
	var final_speed = speed * move_speed_mult
	
	
	if in_air_momentum:
		if is_on_floor():
			if motion_smoothing:
				velocity.x = lerp(velocity.x, direction.x * final_speed, acceleration * delta)
				velocity.z = lerp(velocity.z, direction.z * final_speed, acceleration * delta)
			else:
				velocity.x = direction.x * final_speed
				velocity.z = direction.z * final_speed
		
	else:
		if motion_smoothing:
			velocity.x = lerp(velocity.x, direction.x * final_speed * 2, acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * final_speed * 2, acceleration * delta)
		else:
			velocity.x = direction.x * final_speed
			velocity.z = direction.z * final_speed


func handle_state(moving):
	
	if crouch_enabled:
		if crouch_mode == 0:
			if Input.is_action_pressed("crouchCtrl"):
				if state != "crouching":
					enter_crouch_state()
			elif state == "crouching" and !$CrouchCeilingDetection.is_colliding():
				enter_normal_state()
		elif crouch_mode == 1:
			if Input.is_action_just_pressed("crouchCtrl"):
				match state:
					"normal":
						enter_crouch_state()
					"crouching":
						if !$CrouchCeilingDetection.is_colliding():
							enter_normal_state()


func enter_normal_state():
	#print("entering normal state")
	var prev_state = state
	state = "normal"
	speed = base_speed

func enter_crouch_state():
	#print("entering crouch state")
	var prev_state = state
	state = "crouching"
	speed = crouch_speed

func update_camera_fov():
	CAMERA.fov = lerp(CAMERA.fov, 90.0, 0.3)


func update_collision_scale():
	if state == "crouching": # Add your own crouch animation code
		COLLISION_MESH.scale.y = lerp(COLLISION_MESH.scale.y, 0.75, 0.2)
	else:
		COLLISION_MESH.scale.y = lerp(COLLISION_MESH.scale.y, 1.0, 0.2)

func _process(delta):

	$HealthComponent/UserInterface/DebugPanel.add_property("FPS", 1.0/delta, 0)
	$HealthComponent/UserInterface/DebugPanel.add_property("State", state, 0)
	#Potentally defunc mouse mode swap code. Keeping in case future changes need it
	#if Input.is_action_just_pressed("ui_cancel"):w
		#if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func look_rotation(event):
	HEAD.rotation_degrees.y -= event.relative.x * mouse_sensitivity
	HEAD.rotation_degrees.x -= event.relative.y * mouse_sensitivity

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if grounded_dash_active or directional_dash_active == false:
			look_rotation(event)


func _on_dash_timer_timeout():
	print("dash timer expired")
	grounded_dash_active = false
	directional_dash_active = false
	leap_active = false
	omni_dash_active = false
	velocity.x = 0
	velocity.z = 0
