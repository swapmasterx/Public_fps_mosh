extends Label

@export var ammo = WeaponStats
@export var reload = WeaponSlot

func _process(_delta):
	if ammo != null:
		if ammo.ammo_per_shot == 0:
			set_text("")
		else:
			set_text(str(ammo.ammo))

