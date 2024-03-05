extends Node3D
class_name HealthComponent

signal healthChanged
signal damaged

@export var is_player : bool = true
@export var maxHP := 2000
@export var buff_grab : CharacterBody3D

var health : float
var damaged_heal_reduction : float = 0.0
@onready var currentHP: int = maxHP
@onready var player_pos = $"../"
@onready var self_healrate = $out_of_combat_regen_timer
@onready var time_till_out_of_combat = $time_till_out_of_combat

var get_player_pos
var damage_taken_mult : float = 1

func _ready():
	health = maxHP
	healthChanged.emit()

#makes sure health doesnt go negative or above max hp
func hp_cap():
	health = max (health, 0)
	health = min (health, maxHP)


func take_damage(damage):
	#Checks if damage is positive, thus reducing hp.
	if damage >= 0:
		health -= (damage*buff_grab.damage_taken_multi)
		healthChanged.emit()
		damaged.emit()
		hp_cap()
	#Checks if damage is negitive, thus healing hp and not triggering the damaged signal.
	if damage < 0:
		health -= (damage*(buff_grab.healing_received_multi-damaged_heal_reduction))
		healthChanged.emit()
		hp_cap()
	if health <= maxHP:
		print("Damage taken: " + str(damage))
		print("New health: " + str(health))
	death_state()
	if buff_grab:
		while buff_grab.dot_damage != 0:
			health -= (buff_grab.dot_damage*damage_taken_mult)
			healthChanged.emit()
			damaged.emit()
			hp_cap()
			if health <= maxHP:
				print("Damage taken: " + str(buff_grab.dot_damage))
				print("New health: " + str(health))
			death_state()
			await get_tree().create_timer(0.25).timeout

func death_state():
	if health <= 0:
		get_player_pos = player_pos.global_position
		var get_player_head = player_pos.HEAD.global_rotation
		if is_player == true:
			DeathHandler.die(get_player_pos, get_player_head, buff_grab.team)
		elif is_player == false:
			get_parent().queue_free()

func _on_damaged():
	time_till_out_of_combat.start()
	print("OOC timer started")
	damaged_heal_reduction = 0.4
	await get_tree().create_timer(1.75).timeout
	damaged_heal_reduction = 0

func _on_time_till_out_of_combat_timeout():
	while health < maxHP and time_till_out_of_combat.time_left == 0:
		self_healrate.start()
		await self_healrate.timeout
		if health < maxHP / 100*50:
			health += (0.0125*maxHP)
		else:
			health += (0.00625*maxHP)
		hp_cap()
		healthChanged.emit()
	if health == maxHP:
		self_healrate.stop()
