extends TextureButton

@export_enum ("AltFire","Ability1","Ability2","Primary") var ability_id: int = 0
@onready var cooldown_visual = $cooldown_visual
@onready var cooldown_timing = $cooldown_time
@onready var time = $time
@onready var duration_visual = $duration_visual
@onready var oncooldown_block = $cooldown_darken
@onready var key = $key
@onready var duration_time = $duration_time
@onready var locked_out_icon = $lockedOut
@export var timing_info = WeaponStats
@export var lockout_info = ALH

func _ready():
	cooldown_timing.wait_time = timing_info.reload_speed
	duration_time.wait_time = timing_info.ability_duration
	cooldown_visual.max_value = cooldown_timing.wait_time
	duration_visual.max_value = duration_time.wait_time
	set_process(false)

func _process(_delta):
	duration_visual.value = duration_time.time_left
	if (cooldown_timing.time_left > 0):
		cooldown_visual.value = cooldown_timing.time_left
		oncooldown_block.value = 100
		if (cooldown_timing.time_left > 3):
			time.text = "%3.0f" % cooldown_timing.time_left
		else:
			time.text = "%3.1f" % cooldown_timing.time_left

func _physics_process(_delta):
	if (cooldown_timing.time_left > 0):
		pass
	elif (duration_time.time_left > 0):
		pass
	else:
		match ability_id:
			0: 
				if Input.is_action_pressed("alt_fire") and lockout_info.altfire_input == true:
					initiate_cooldown_timers()
				if lockout_info.altfire_input == true:
					locked_out_icon.visible = false
				if lockout_info.altfire_input == false:
					locked_out_icon.visible = true
			1: 
				if Input.is_action_pressed("ability1") and lockout_info.ability1_input == true:
					initiate_cooldown_timers()
				if lockout_info.ability1_input == true:
					locked_out_icon.visible = false
				if lockout_info.ability1_input == false:
					locked_out_icon.visible = true
			2: 
				if Input.is_action_pressed("ability2") and lockout_info.ability2_input == true:
					initiate_cooldown_timers()
				if lockout_info.ability2_input == true:
					locked_out_icon.visible = false
				if lockout_info.ability2_input == false:
					locked_out_icon.visible = true
			3: 
				if Input.is_action_pressed("shoot") and lockout_info.primary_input == true:
					initiate_cooldown_timers()
				if lockout_info.primary_input == true:
					locked_out_icon.visible = false
				if lockout_info.primary_input == false:
					locked_out_icon.visible = true
					
		
func initiate_cooldown_timers():
	cooldown_timing.wait_time = timing_info.reload_speed
	duration_time.wait_time = timing_info.ability_duration
	set_process(true)
	duration_time.start()
	
func _on_cooldown_time_timeout():
	disabled = false
	oncooldown_block.value = 0
	time.text = ""
	set_process(false)


func _on_duration_time_timeout():
	cooldown_timing.start()
