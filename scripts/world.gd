extends Node3D

@onready var player_

#SCORE
var enemies_killed_ : int = 0
var dmg_done_ : int = 0


var interface_ : XRInterface
var enemy_ : Resource = preload("res://scenes/enemy.tscn")
var running_ : bool = false

func start_game() -> void:
	running_ = true
	%enemy.follow_player_ = true
	%enemy.visible = true
	await get_tree().create_timer(1).timeout
	spawnEnemy()
	
func end_game() -> void:
	print("Enemies killed:")
	print(enemies_killed_)
	print("Damage done:")
	print(dmg_done_)
	
	get_tree().reload_current_scene()
	
	
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
