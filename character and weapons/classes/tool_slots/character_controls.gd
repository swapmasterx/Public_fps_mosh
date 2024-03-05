extends MultiplayerSynchronizer

# Set via RPC to simulate is_action_just_pressed.
@export var jumping := false

# Synchronized property.
@export var direction := Vector2.ZERO
@export var JUMP : String = "jump"
@export var LEFT : String = "move_left"
@export var RIGHT : String = "move_right"
@export var FORWARD : String = "move_forward"
@export var BACKWARD : String = "move_back"
@export var Primary : String = "shoot"
@export var Alt_Fire : String = "alt_fire"
@export var Ability1 : String = "ability1"
@export var Ability2 : String = "ability2"



func _ready():
	# Only process for the local player.
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


@rpc("call_local")
func jump():
	jumping = true


func _process(_delta):
	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_vector(LEFT, RIGHT, FORWARD, BACKWARD)
	if Input.is_action_just_pressed(JUMP):
		jump.rpc()
