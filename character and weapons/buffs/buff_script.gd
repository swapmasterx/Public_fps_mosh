class_name Buff

extends Resource

@export var name:String = "buff_name_here"
@export_category("Weapon Effects")
@export var duration : float = 0
@export var headshot_multiplier_bonus : float = 0
@export var damage_multiplier : float = 0
@export var attack_speed_multiplier : float = 0
@export var infinite_ammo : bool

@export var quickreload : int = 0
@export_category("Health Effects")
@export var self_damage : float = 0
@export var damage_taken_mult : float = 0
@export var healing_received_multi : float = 0
#@export var dot_duration : float = 0
@export var dot_damage : float = 0
#@export var dot_damage_rate : float = 0
@export_category("Character Effects")
@export var move_speed_mult : float = 0
@export var jump_hight_mult : float = 0
@export var grounded_dash_active = false
@export var directional_dash_active = false
@export var leap_active = false
@export var omni_dash_active = false
@export var dash_time : float = 0
@export var dash_speed : float = 0

