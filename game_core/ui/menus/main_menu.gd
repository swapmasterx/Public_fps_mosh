extends Node

const PORT = 7777


@onready var buttons_v_box = $"Main Menu/MarginContainer/VBoxContainer/Buttons_vBox"
@onready var get_player_slider = $"Main Menu/MarginContainer/VBoxContainer/Buttons_vBox/GridContainer/player count"


func _ready() -> void:
	focus_button()
	multiplayer.server_relay = false
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_pressed.call_deferred()


func _on_host_pressed():
	# Start as server.
	var peer = ENetMultiplayerPeer.new()
	var max_clients = get_player_slider.value
	peer.create_server(PORT, max_clients)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server. Port is undefined or something else went wrong.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()

func _on_join_pressed():
	# Start as client.
	var txt : String = $"Main Menu/MarginContainer/VBoxContainer/Buttons_vBox/LineEdit".text
	if txt == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(txt, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()

func _on_options_pressed() -> void:
	pass

func _on_exit_game_pressed() -> void:
	get_tree().quit()

func focus_button() -> void:
	if buttons_v_box:
		var button: Button = buttons_v_box.get_child(0)
		if button is Button:
			button.grab_focus()
			
func start_game():
	# Hide the UI and unpause to start the game.
	$"Main Menu".hide()
	if multiplayer.is_server():
		change_level.call_deferred(load("res://_levels/dev_worlds/test_world_2_no_untrue.tscn"))

func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = %Level
	for childern in level.get_children():
		level.remove_child(childern)
		childern.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())
	
func _input(event):
	if not multiplayer.is_server():
		return
	#restart level. This is a debug/server side action
	if event.is_action("dev_restart_level") and Input.is_action_just_pressed("dev_restart_level"):
		change_level.call_deferred(load("res://_levels/dev_worlds/test_world_2_no_untrue.tscn"))

