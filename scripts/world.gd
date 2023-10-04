extends Node3D

var interface_ : XRInterface
var player_ : Node3D
var enemy_ : Resource = preload("res://scenes/enemy.tscn")
var running_ : bool = true

func _ready():
	interface_ = XRServer.find_interface("OpenXR")
	if interface_ and interface_.is_initialized():
		get_viewport().use_xr = true

	#tady to pak spustit přes grab
	await get_tree().create_timer(1).timeout
	spawnEnemy()

func setPlayer(player:Node3D) -> void:
	player_ = player
	
func getPlayer() -> Node3D:
	return player_

func spawnEnemy() -> void:
	if running_ == false:
		return
	var enemy = enemy_.instantiate()
	while true:
		var enemy_position = Vector3(randf_range(-20,20), -0.35,randf_range(-20,20))
		if enemy_position.distance_to(player_.get_position()) > 5:
			enemy.set_position(enemy_position)
			break
	add_child(enemy)
	await get_tree().create_timer(1).timeout
	spawnEnemy()
