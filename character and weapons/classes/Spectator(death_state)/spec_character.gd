extends CharacterBody3D

class_name spectator


# TODO: Add descriptions for each value

@export_category("Spectator")

@export var base_speed : float = 5.0
@export var crouch_speed : float = 1.0
@export var acceleration : float = 10.0
@export var rise_velocity : float = 5
@export var decend_velocity : float = 5
@export var mouse_sensitivity : float = 0.1

@export_group("Nodes")
var stats : Buff
@export var HEAD : Node3D
@export var CAMERA : Camera3D
@export var CAMERA_ANIMATION : AnimationPlayer
@export var COLLISION_MESH : CollisionShape3D
@export var PRIMARY : WeaponSlot
@export var ABILITY_ALTFIRE : WeaponSlot
@export var ABILITY_1 : WeaponSlot
@export var ABILITY_2 : WeaponSlot
@export var HEALTHCOMPONENT : HealthComponent

@export_group("Controls")
@export var DOWN : String ="spectator decend"
@export var UP : String = "jump"
@export var LEFT : String = "move_left"
@export var RIGHT : String = "move_right"
@export var FORWARD : String = "move_forward"
@export var BACKWARD : String = "move_back"
@export var PAUSE : String = "ui_cancel"


@export_group("Feature Settings")
@export var in_air_momentum : bool = true
@export var motion_smoothing : bool = false
@export var crouch_enabled : bool = true
@export_enum("Hold to Crouch", "Toggle Crouch") var crouch_mode : int = 0
@export var dynamic_fov : bool = true

var vel := Vector3.ZERO
var extraVel := Vector3.ZERO

# Member variables
var speed : float = base_speed
# States: normal, crouching, sprinting
var state : String = "normal"

var jump_count : int = 0
# Get the gravity from the project settings to be synced with RigidBody nodes


var menu_active : bool = false

var in_spawn : bool = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float):

	# Add some debug data
	$HealthComponent/UserInterface/DebugPanel.add_property("Movement Speed", speed, 1)
	$HealthComponent/UserInterface/DebugPanel.add_property("Velocity", get_real_velocity(), 2)

	
	handle_free_fly()
	
	var input_dir = Vector2.ZERO
	if menu_active == false:
		input_dir = Input.get_vector(LEFT, RIGHT, FORWARD, BACKWARD)
	handle_movement(delta, input_dir)
	
	handle_state(input_dir)

	update_camera_fov()
	update_collision_scale()

func handle_free_fly():
	if menu_active == false:
		if Input.is_action_pressed(UP):
			velocity.y += rise_velocity
			velocity.y = max (rise_velocity, 10)
		if Input.is_action_pressed(DOWN):
			velocity.y -= decend_velocity
			velocity.y = min (rise_velocity, -10)
		if Input.is_action_pressed("crouchCtrl"):
			velocity.y = 0


func handle_movement(delta, input_dir):
	var direction = input_dir.rotated(-HEAD.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	move_and_slide()
	
	
	if in_air_momentum:
		if is_on_floor():
			if motion_smoothing:
				velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
				velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
			else:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
		
	else:
		if motion_smoothing:
			velocity.x = lerp(velocity.x, direction.x * speed * 2, acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * speed * 2, acceleration * delta)
		else:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed


func handle_state(_moving):
	
	if crouch_enabled:
		if crouch_mode == 0:
			if Input.is_action_pressed("crouchCtrl"):
				if state != "crouching":
					enter_crouch_state()
			elif state == "crouching":
				enter_normal_state()
		elif crouch_mode == 1:
			if Input.is_action_just_pressed("crouchCtrl"):
				match state:
					"normal":
						enter_crouch_state()
					"crouching":
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

func update_camera_fov():
	CAMERA.fov = lerp(CAMERA.fov, 90.0, 0.3)


func update_collision_scale():
	COLLISION_MESH.scale.y = lerp(COLLISION_MESH.scale.y, 1.0, 0.2)

func _process(delta):

	$HealthComponent/UserInterface/DebugPanel.add_property("FPS", 1.0/delta, 0)
	$HealthComponent/UserInterface/DebugPanel.add_property("State", state, 0)
	
	HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func look_rotation(event):
	HEAD.rotation_degrees.y -= event.relative.x * mouse_sensitivity
	HEAD.rotation_degrees.x -= event.relative.y * mouse_sensitivity

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		look_rotation(event)
