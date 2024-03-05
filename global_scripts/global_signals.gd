extends Node

#Used to lock inputs while in an overlay menu like the pause menu,-
#-character select or an external interactable menu.
signal menu_on
signal menu_off

#Checks if a player is inside a spawn room to allow character switching
signal entered_spawn
signal left_spawn

#Handles when objective points change hands. 
signal point_caputured_by_team_1
signal point_caputured_by_team_2

#Handles player death states and switching characters or teams
signal player_died
signal changed_team
signal changed_character_in_spawn
signal changed_character_while_dead
