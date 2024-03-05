extends CharacterBody3D

# TODO: Add descriptions for each value

@export_category("Character")
@export var base_speed : float = 5.0
@export var crouch_speed : float = 1.0
@export var acceleration : float = 10.0
@export var jump_velocity : float = 4.5
@export var mouse_sensitivity : float = 0.1

@export_group("Nodes")
var stats : Buff
@export var CAMERA_ANIMATION : AnimationPlayer
@export var COLLISION_MESH : CollisionShape3D
@export var AIMCAST : RayCast3D
@export var PRIMARY : WeaponSlot
@export var ABILITY_ALTFIRE : WeaponSlot
@export var ABILITY_1 : WeaponSlot
@export var ABILITY_2 : WeaponSlot
@export var HEALTHCOMPONENT : HealthComponent
@export var HITBOX : DamageHitBox
@export var HEADHITBOX : HeadHitBox
@export var Player : bool = true

@export_group("Controls")
# We are using UI controls because they are built into Godot Engine so they can be used right away
@export var JUMP : String = "jump"
@export var LEFT : String = "move_left"
@export var RIGHT : String = "move_right"
@export var FORWARD : String = "move_forward"
@export var BACKWARD : String = "move_back"
@export var PAUSE : String = "ui_cancel"
@export var CROUCH : String = "crouchCtrl"

# Uncomment if you want full controller support
#@export var LOOK_LEFT : String
#@export var LOOK_RIGHT : String
#@export var LOOK_UP : String
#@export var LOOK_DOWN : String

@export_group("Feature Settings")
@export var immobile : bool = false
@export var jumping_enabled : bool = true
@export var in_air_momentum : bool = true
@export var motion_smoothing : bool = false
@export var crouch_enabled : bool = true
@export_enum("Hold to Crouch", "Toggle Crouch") var crouch_mode : int = 0
@export var dynamic_fov : bool = true

# Buff tracker lists
var duration_time : float = -1
var buffers : Array = []
var damage_multiplier : float
var firing_speed_multiplier : float
var infinite_ammo = false
var damage_taken_multi : float
var dot_duration : float
var dot_damage : float
var dot_damage_rate : float
var move_speed_mult : float
var jump_hight_mult : float
var dash_time : float
var dash_speed : float
# Member variables
var speed : float = base_speed
# States: normal, crouching, sprinting
var state : String = "normal"
var low_ceiling : bool = false # This is for when the cieling is too low and the player needs to crouch.

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") # Don't set this as a const, see the gravity section in _physics_process


func _ready():
	update_multipliers()

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
	damage_taken_multi = 1.0
	dot_duration = 0.0
	dot_damage = 0.0
	dot_damage_rate = 0
	move_speed_mult = 1.0
	jump_hight_mult = 1.0
	dash_time = 0.0
	dash_speed = 0.0
	for data in buffers:
		damage_multiplier += data.damage_multiplier
		firing_speed_multiplier += data.attack_speed_multiplier
		if data.infinite_ammo == true:
			infinite_ammo = true
		damage_taken_multi += data.damage_taken_mult
		dot_duration += data.dot_duration
		dot_damage += data.dot_damage
		dot_damage_rate += data.dot_damage_rate
		move_speed_mult += data.move_speed_mult 
		jump_hight_mult += data.jump_hight_mult
		dash_time += data.dash_time
		dash_speed += data.dash_speed

func remove_buff(data, bufftimer = null):
#remove your buff modifiers
	print("buff timout called")
	if bufftimer != null:
		damage_multiplier -= data.damage_multiplier
		firing_speed_multiplier -= data.attack_speed_multiplier
		infinite_ammo = false
		damage_taken_multi -= data.damage_taken_mult
		dot_duration -= data.dot_duration
		dot_damage -= data.dot_damage
		dot_damage_rate -= data.dot_damage_rate
		move_speed_mult -= data.move_speed_mult 
		jump_hight_mult -= data.jump_hight_mult
		dash_time -= data.dash_time
		dash_speed -= data.dash_speed
		buffers.remove_at(0)
		print("timer null called")
		bufftimer.queue_free()

func _physics_process(delta):
	
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity") # If the gravity changes during your game, uncomment this code
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	handle_jumping()
	
	var input_dir = Vector2.ZERO
	if !immobile:
		input_dir = Input.get_vector(LEFT, RIGHT, FORWARD, BACKWARD)
	
	handle_state(input_dir)


func handle_jumping():
	if jumping_enabled:
		if Input.is_action_just_pressed(JUMP) and is_on_floor():
			velocity.y += jump_velocity


func handle_state(_moving):
	
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
	var _prev_state = state
	state = "normal"
	speed = base_speed

func enter_crouch_state():
	#print("entering crouch state")
	var _prev_state = state
	state = "crouching"
	speed = crouch_speed


