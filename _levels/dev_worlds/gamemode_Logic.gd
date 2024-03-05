extends Node3D

@export var team_1_respawn_base: float = 8
@export var team_2_respawn_base: float = 8
var team_1_respawn
var team_2_respawn
#@onready var team_1_respawn = %team1Respawn
#@onready var team_2_respawn = %team2Respawn

func _ready():
	team_1_respawn = team_1_respawn_base
	team_2_respawn = team_2_respawn_base
	
func _physics_process(_delta):
	DeathHandler.team1RespawnValue = team_1_respawn
	DeathHandler.team2RespawnValue = team_2_respawn


func _on_respawn_interval_1_timeout():
	if team_1_respawn > (team_1_respawn_base/2):
		team_1_respawn -= 1
	elif team_1_respawn <= (team_1_respawn_base/2):
		team_1_respawn = team_1_respawn_base


func _on_respawn_interval_2_timeout():
	if team_2_respawn > (team_2_respawn_base/2):
		team_2_respawn -= 1
	elif team_2_respawn <= (team_2_respawn_base/2):
		team_2_respawn = team_2_respawn_base
