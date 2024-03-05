extends Label

@export var ammo = WeaponStats
@export var reload = WeaponSlot
@export var inf_ammo_buff = CharacterBody3D

func _process(_delta):
	if ammo != null:
		if reload.reloading == true:
			set_text("reloading")
		elif reload.reloading == false:
			set_text(str(ammo.ammo)+"/"+str(ammo.max_ammo))
		if ammo.ammo_per_shot == 0:
			set_text("")
		if inf_ammo_buff.infinite_ammo == true:
			set_text("")
