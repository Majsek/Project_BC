extends Node3D

@onready var player_

#SCORE
var enemies_killed_ : int = 0
var dmg_done_ : int = 0

#ALLOWED SPAWN EDGES
var edge_1_allowed_ = true
var edge_2_allowed_ = false
var edge_3_allowed_ = true
var edge_4_allowed_ = false

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
		
		var random_on_edge = randf_range(0,0.25)
		var progress
		
		var edge = randi_range(1,4)
		
		match edge:
			1:
				if edge_1_allowed_:
					progress = 0.0 + random_on_edge
			2:
				if edge_2_allowed_:
					progress = 0.25 + random_on_edge
			3:
				if edge_3_allowed_:
					progress = 0.50 + random_on_edge
			4:
				if edge_4_allowed_:
					progress = 0.75 + random_on_edge
		if progress != null:
			%PathFollow3D.progress_ratio = progress
			enemy.position = %PathFollow3D.position
			break
		
		#if enemy_position.distance_to(player_.position) > 5:
			#enemy.position = enemy_position
			#break
	add_child(enemy)
	await get_tree().create_timer(1).timeout
	spawnEnemy()
