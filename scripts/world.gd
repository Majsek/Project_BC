extends Node3D

@onready var player_

var enemies_ : Array

var shop_cubes_ : Array = [
	"lives_shop_cube",
	"projectile_strength_shop_cube",
	]

#SCORE
var enemies_killed_all_time_ : int = 0
var enemies_killed_last_round_ : int = 0:
	set(value):
		enemies_killed_last_round_ = value
		xp_ += 1
		

var xp_ : int = 0:
	set(value):
		xp_ = value
		print(xp_)
		if xp_ >= 10:
			level_up()
			
var level_ : int = 1
		
var dmg_done_all_time_ : int = 0
var dmg_done_last_round_ : int = 0:
	set(value):
		dmg_done_last_round_ = value
		update_stats_label()
var money_ : int = 1000

#ALLOWED SPAWN EDGES
var edge_1_allowed_ = true
var edge_2_allowed_ = false
var edge_3_allowed_ = false
var edge_4_allowed_ = false

var difficulty_multiplier_ : float = 0.5

var interface_ : XRInterface
var enemy_ : Resource = preload("res://scenes/enemy.tscn")
var running_ : bool = false

var shop_cube_ : Resource = preload("res://scenes/control_cube.tscn")

const SAVE_PATH = "res://godot_save_config_file.ini"

func level_up():
	level_ += 1
	stop_enemies()
	
	var shop1 = shop_cubes_.pick_random()
	var shop2 = shop_cubes_.pick_random()
	while shop1 == shop2:
		shop2 = shop_cubes_.pick_random()
	
#SHOP CUBE 1
	var shop_cube1 = shop_cube_.instantiate()
	shop_cube1.name = shop1
	shop_cube1.position = Vector3(-1.5, 1.0, -1.5)
	shop_cube1.get_node("MeshInstance3D").rotation_degrees.z = -90.0
	add_child(shop_cube1)
	
#SHOP CUBE 2
	var shop_cube2 = shop_cube_.instantiate()
	shop_cube2.name = shop2
	shop_cube2.position = Vector3(1.5, 1.0, -1.5)
	shop_cube2.get_node("MeshInstance3D").rotation_degrees.z = -90.0
	add_child(shop_cube2)
	

#RESUME GAME
func start_game() -> void:
	xp_ = 0 
	
	get_tree().call_group("control_cubes", "queue_free")
	
	running_ = true
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
	
	money_ += dmg_done_last_round_
	save_game()
	get_tree().reload_current_scene()
	
#STOP ENEMIES FROM MOVING
func stop_enemies() -> void:
	running_ = false
	for e in enemies_:
		if e != null:
			e.follow_player_ = false
	
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
	await get_tree().create_timer(0.1).timeout
	difficulty_multiplier_ += 0.02
	spawnEnemy()

func save_game():
	var config := ConfigFile.new()

	config.set_value("stats", "money", money_)
	config.set_value("stats", "enemies_killed", enemies_killed_all_time_)
	config.set_value("stats", "dmg_done", dmg_done_all_time_)

	print(config.save(SAVE_PATH))

func load_game():
	var config := ConfigFile.new()
	config.load(SAVE_PATH)

	if config.get_value("stats", "money") == null:
		return
	money_ = config.get_value("stats", "money")
	enemies_killed_all_time_ = config.get_value("stats", "enemies_killed")
	dmg_done_all_time_ = config.get_value("stats", "dmg_done")
	update_stats_label()
	
func update_stats_label():
	%stats.text = (
		"Money: " + str(money_) + "\n" +
		"Enemies killed: " + str(enemies_killed_last_round_) + "\n" +
		"Damage done: " + str(dmg_done_last_round_))

