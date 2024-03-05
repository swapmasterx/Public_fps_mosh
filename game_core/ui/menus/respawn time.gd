extends Label

var team1respawnTime

func _ready():
	team1respawnTime = get_tree().create_timer(DeathHandler.team1RespawnValue)
func _process(_delta):
	set_text("Respawning in:"+str("%3.1f" % team1respawnTime.time_left))
