extends Resource

class_name WeaponStats

@export var name:String = ""
@export_category("Slot Location Statuses")
#@export var input: String
@export_enum ("Passive", "Primary","AltFire","Ability1","Ability2","Primary Cancleable") var weapon_slot: int = 1
@export var is_primary = true
@export var can_manually_reload = true
@export var fire_animation_call: String
@export var reload_animation_call: String
@export var breach_reload_animation_call: String

@export_category("Components")
@export_enum ("Null", "Buff", "Hitscan", "Projectile", "Shotgun") var Type2 = 1
@export var breach_load = false
@export var breach_load_count: int = 1
@export var buff_handler_1 : Buff
@export var buff_applyer : Buff
@export_range(0.0,25.0) var spread_random = 0

@export_category("Weapon Properties")
@export var projectileToLoad: PackedScene
@export var projectileSpeed: int = 80
@export var rangeValue : int = 2000
@export var recoil_enabled = false
@export var damage : float = 0
@export var damage_maxFalloff : float = 0
@export var blast_damage : float = 0
@export var headshot_multiplier : float = 1
@export var max_ammo : int = 0
@export var ammo : int = 0
@export var ammo_per_shot : int = 1
@export var projectiles_per_shot : int = 1
@export_range(0,9) var firing_type : int = 1
@export var reload_speed : float = 0
@export var firing_speed : float = 0
@export var min_firing_speed : float = 0
@export var max_firing_speed : float = 0
@export var RPM_speed_ramp : float = 0
@export var ability_duration : float = 0.05
@export var damage_falloff_start : int = 0
@export var damage_falloff_end : int = 0
@export var AoE_falloff_start : float = 1
@export var AoE_falloff_end : float = 1.75
@export_range(1,100) var AoE_falloff_reduction : float = 50

@export_category("On condition triggers")
@export var body_hit_effect : Buff
@export var crit_hit_effect : Buff
@export var firing_effect : Buff
@export var on_heal_effect : Buff

@export_category("Melee Properties")
@export var uses_melee_box = false
@export var melee_box_duration: float = 0.3

@export_category("Locks out other inputs when this weapon is in use")
@export var Passive_lockout_check : bool = false
@export var Primary_lockout_check : bool = false
@export var AltFire_lockout_check : bool = false
@export var Ability1_lockout_check : bool = false
@export var Ability2_lockout_check : bool = false

@export_category("Burstfire Data")
@export var burstfire_delay : float = 0
@export var burstfire_lockout : float = 0
@export var burstfire_shot_count : int = 0

@export_category("Recoil Values")
@export var vertical_angle : float = 5.0
@export var horizontal_angle : float = 0.05
@export var min_recoil_amount : float = 1.0
@export var max_recoil_amount : float = 2.0
@export var recoil_recovery_speed : float = 5.0

var headshot_multiplier_bonus : float = 0.0
var damage_multiplier : float = 0.0
var attack_speed_multiplier : float = 0.0
var infinite_ammo = false
var can_fire = true
var reloading = false

func recoil():
	var recoil_amount = randf_range(min_recoil_amount, max_recoil_amount)
	vertical_angle += recoil_amount
	horizontal_angle += randf_range(-recoil_amount, recoil_amount)



