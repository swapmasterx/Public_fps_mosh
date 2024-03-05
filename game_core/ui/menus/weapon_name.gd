extends Label

@export var gunname = WeaponStats
@export var reload = WeaponSlot

func _process(_delta):
	if gunname != null:
		set_text(str(gunname.name))
		if reload.reloading == true:
			set_text("reloading")

