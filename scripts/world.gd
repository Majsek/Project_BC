extends Node3D

@onready var player_

var interface_ : XRInterface
var enemy_ : Resource = preload("res://scenes/enemy.tscn")
var running_ : bool = false:
	set(value):
		running_ = value
#START TODO: do samostatný start funkce by to bylo lepší
		if value:
			%enemy.follow_player_ = true
			%enemy.visible = true
			await get_tree().create_timer(1).timeout
			spawnEnemy()

func _ready():
	interface_ = XRServer.find_interface("OpenXR")
	if interface_ and interface_.is_initialized():
		get_viewport().use_xr = true

func spawnEnemy() -> void:
	if running_ == false:
		return
	var enemy = enemy_.instantiate()
	while true:
		var enemy_position = Vector3(randf_range(-20,20), -0.35,randf_range(-20,20))
		if enemy_position.distance_to(player_.position) > 5:
			enemy.position = enemy_position
			break
	add_child(enemy)
	await get_tree().create_timer(1).timeout
	spawnEnemy()
