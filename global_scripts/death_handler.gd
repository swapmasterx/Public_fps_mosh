extends Node3D

var team1RespawnValue
var team2RespawnValue
@onready var SPECTATOR = preload("res://character and weapons/classes/Spectator(death_state)/spectator.tscn")

func die(get_player_pos, get_player_head, team):
	var team1respawnTime = get_tree().create_timer(team1RespawnValue)
	var team2respawnTime = get_tree().create_timer(team2RespawnValue)
	var previousCharacter = Game.get_gamemode().player_character_scene
	Game.get_gamemode().player_character_scene = SPECTATOR
	Game.get_gamemode().get_player_character().global_position = get_player_pos
	Game.get_gamemode().get_player_character().HEAD.global_rotation = get_player_head
	GlobalSignals.player_died.emit()
	if team == 0:
		pass
	if team == 1:
		print("team1 member waiting to respawn")
		await (team1respawnTime.timeout)
		print("team1 member respawned")
		Game.get_gamemode().player_character_scene = previousCharacter
	if team == 2:
		print("team2 member waiting to respawn")
		await (team2respawnTime.timeout)
		print("team2 member respawned")
		Game.get_gamemode().player_character_scene = previousCharacter

