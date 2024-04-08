extends Node3D

@onready var player_

var enemies_ : Array

var shop_cubes_ : Array = [
	"lives_shop_cube",
	"projectile_strength_shop_cube",
	"frost_shop_cube",
	"rapid_fire_cube",
	"shotgun",
	"charge_gun",
	]

#SCORE
var enemies_killed_all_time_ : int = 0
var enemies_killed_last_round_ : int = 0:
	set(value):
		enemies_killed_last_round_ = value
		xp_ += 1
		

var xp_needed_ : int = 10
var xp_ : int = 0:
	set(value):
		xp_ = value
		print(xp_)
		if xp_ >= xp_needed_:
			level_up()
			
var level_ : int = 1
		
var dmg_done_all_time_ : int = 0
var dmg_done_last_round_ : int = 0:
	set(value):
		dmg_done_last_round_ = value
		update_stats_label()

#ALLOWED SPAWN EDGES
var edge_1_allowed_ = true
var edge_2_allowed_ = true
var edge_3_allowed_ = false
var edge_4_allowed_ = false

var difficulty_multiplier_ : float = 0.5

var interface_ : XRInterface
var enemy_ : Resource = preload("res://scenes/enemy.tscn")
var running_ : bool = false

var shop_ : Resource = preload("res://scenes/shop.tscn")

const SAVE_PATH = "res://godot_save_config_file.ini"

func level_up():
	level_ += 1
	xp_needed_ += level_
	stop_enemies()
	
	var shop1 = shop_cubes_.pick_random()
	var shop2 = shop_cubes_.pick_random()
	while shop1 == shop2:
		shop2 = shop_cubes_.pick_random()
	
#SHOP SCENE
	var shop_scene = shop_.instantiate()
	#it will get freed on start_game()
	shop_scene.add_to_group("control_cubes")
	shop_scene.rotation.y = player_.get_node("XROrigin3D/XRCamera3D").rotation.y
	
#SHOP CUBE 1
	var shop_cube1 = shop_scene.get_node("shop_cube1")
	shop_cube1.name = shop1
	#shop_cube1.get_node("MeshInstance3D").rotation_degrees.z = -90.0
	
#SHOP CUBE 2
	var shop_cube2 = shop_scene.get_node("shop_cube2")
	shop_cube2.name = shop2
	#shop_cube2.get_node("MeshInstance3D").rotation_degrees.z = -90.0
	
	player_.add_child(shop_scene)
	shop_scene.top_level = true
	

#RESUME GAME
func start_game() -> void:
	xp_ = 0 
	
	get_tree().call_group("control_cubes", "queue_free")
	
	
	running_ = true
	for e in enemies_:
		if e != null:
			e.follow_player_ = true
	
	#%enemy.follow_player_ = true 
	#%enemy.visible = true
	await get_tree().create_timer(1).timeout
	spawnEnemy()
	
func end_game() -> void:
#end screen info
	print("Raccoons rescued:")
	print(enemies_killed_last_round_)
	print("Cubes collected:")
	print(dmg_done_last_round_)
	
	enemies_killed_all_time_ += enemies_killed_last_round_
	dmg_done_all_time_ += dmg_done_last_round_
	
	save_game()
	get_tree().reload_current_scene()
	
#STOP ENEMIES FROM MOVING
func stop_enemies() -> void:
	running_ = false
	for e in enemies_:
		if e != null:
			e.follow_player_ = false
			if e.position.distance_to(player_.position) < 2.0:
				e.queue_free()
	
func _ready():
	load_game()
	interface_ = XRServer.find_interface("OpenXR")
	if interface_ and interface_.is_initialized():
		get_viewport().use_xr = true
#TEST
	enemies_.append(%enemy)

func spawnEnemy() -> void:
	if running_ == false:
		return
	var enemy = enemy_.instantiate()
	enemy.init(difficulty_multiplier_)
	
	
	while true:
		var enemy_position
		
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
			enemy.position.y = -4.0
			break
		
		#if enemy_position.distance_to(player_.position) > 5:
			#enemy.position = enemy_position
			#break
	enemies_.append(enemy)
	add_child(enemy)
	await get_tree().create_timer(2.0).timeout
	difficulty_multiplier_ += 0.02
	spawnEnemy()

func save_game():
	var config := ConfigFile.new()

	config.set_value("stats", "enemies_killed", enemies_killed_all_time_)
	config.set_value("stats", "dmg_done", dmg_done_all_time_)
	
	config.set_value("settings", "edge_2_allowed_", edge_2_allowed_)
	config.set_value("settings", "edge_3_allowed_", edge_3_allowed_)
	config.set_value("settings", "edge_4_allowed_", edge_4_allowed_)
	
	print(config.save(SAVE_PATH))

func load_game():
	var config := ConfigFile.new()
	config.load(SAVE_PATH)

	if config.get_value("stats", "enemies_killed") == null:
		return
	enemies_killed_all_time_ = config.get_value("stats", "enemies_killed")
	dmg_done_all_time_ = config.get_value("stats", "dmg_done")
	
	edge_2_allowed_ = config.get_value("settings", "edge_2_allowed_")
	edge_3_allowed_ = config.get_value("settings", "edge_3_allowed_")
	edge_4_allowed_ = config.get_value("settings", "edge_4_allowed_")
	
	update_stats_label()
	
func update_stats_label():
	%stats.text = (
		"Enemies killed all time: " + str(enemies_killed_all_time_) + "\n" +
		"Damage done all time: " + str(dmg_done_all_time_) + "\n" +
		"\n" +
		"Enemies killed last round: " + str(enemies_killed_last_round_) + "\n" +
		"Damage done last round: " + str(dmg_done_last_round_)
		)

