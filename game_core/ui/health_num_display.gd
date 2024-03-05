extends RichTextLabel

@export var compo = HealthComponent

func _process(_delta):
	if compo.health > 0:
		set_text("[center]"+str(roundf(compo.health))+"/"+str(compo.maxHP)+"[/center]")
	else:
		set_text("")
	
