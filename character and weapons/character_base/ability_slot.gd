extends Node

class_name baseweapon

signal primed_ability

@export var hp : HealthComponent
@export var gun : baseweapon
@export var char : CharacterBody3D
@export var buff_handler : Buff
@export var max_ammo : int = 0
@export var ammo : int = 0
var ammo_per_shot : int = 1
@export var firing_type : int = 0
@export var cooldown_time : float = 0
@export var ability_charge_delay : float = 0
@export var ability_duration : float = 0
@export var can_switch_to : bool

var can_fire = true
var reloading = false
@onready var Anim = $".."/Head/Camera/AnimationHitscanGun


func empty():
	if not reloading and ammo <= 0: 
		reload()
		print ("ability on cooldown")

func _physics_process(delta):
	if ammo <= 0:
		can_fire = false
	#has duration, buff for self
	if Input.is_action_just_pressed("ability1") and can_fire:
		if firing_type == 1:
			fire()
			print ("using ability duration")
			await get_tree().create_timer(ability_duration).timeout
			empty()
	#has no duration
		elif firing_type == 0:
			fire()
			print ("using ability no duration")
			empty()
	#prime then fire
		elif firing_type == 2:
			print ("priming ability")
			Input.is_action_just_pressed("shoot")
			fire()
			print ("using ability primed")
			empty()
	#has duration and can be cancled
		elif firing_type == 3:
			fire()
			print ("using ability duration")
			await get_tree().create_timer(ability_duration).timeout
			if Input.is_action_just_pressed("ability1"):
				print ("ability cancled")
				get_tree().set_timer(ability_duration).time = 0
			empty()

func fire():
	can_fire = false
	ammo -= ammo_per_shot
	if Anim != null:
		Anim.stop(true)
		Anim.play("ability_1")
	await get_tree().create_timer(ability_charge_delay).timeout
	if not reloading:
		can_fire = true
		
func reload():
	reloading = true
	can_fire = false
	await get_tree().create_timer(cooldown_time).timeout
	if reloading == true:
		var ammo_to_add = (1)
		ammo += ammo_to_add
	if ammo > 0:
		can_fire = true
	reloading = false
