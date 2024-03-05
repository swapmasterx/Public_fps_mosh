extends TextureProgressBar

@export var player: HealthComponent

func _ready():
	player.healthChanged.connect(update)
	update()

func update():
	value = player.health * 100 / player.maxHP
