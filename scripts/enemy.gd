extends CharacterBody3D

@onready var main_ : Node = $"/root/world"
@onready var player_ : Node = main_.player_

@export var initial_lives_ : int
@export var lives_ : int
const HIT_PARTICLE = preload("res://scenes/hit_particle.tscn")

@export var follow_player_ : bool = false:
#not optimal, but necessary
	set(value):
		if main_.running_:
			follow_player_ = value
		else:
			follow_player_ = false
			
var initial_color_ : Color
var color_ : Color:
	set(value):
		if value.s < 0.4:
			value.s = 0.4
		color_ = value
		$MeshInstance3D.get_surface_override_material(0).set_albedo(color_)

var speed_ = 2.0

var death_dmg_ : int

func init(difficulty_multiplier):
	initial_lives_ = randi_range(90*difficulty_multiplier,100*difficulty_multiplier)
	speed_ *= difficulty_multiplier

func _ready():
	initial_color_ = Color.from_hsv(randf_range(0,1), 1.0, 1.0, 1.0)
	color_ = initial_color_
	lives_ = initial_lives_
	self.scale *= lives_/80.0
	spawnAnim()
	
func _physics_process(delta):
	#TEST:
	if Input.is_action_just_pressed("ui_text_delete"):
		die(200)
	followPlayer()

#PLAYS SPAWN ANIM
func spawnAnim():
	%AnimationPlayer.play("enemy_spawn")
	pass
	
func followPlayer() -> void:
	var follow_direction : Vector3 = get_global_position().direction_to(player_.get_global_position())
	var angle : float = rad_to_deg(Vector3(1, 0, 0).angle_to(Vector3(follow_direction.x, 0, follow_direction.z)))
	if follow_direction.z > 0 :
		angle = 360 - angle
	self.set_rotation_degrees(Vector3(0,angle+90,0))
	
	if !follow_player_:
		return
	follow_direction.y = 0
#MOVEMENT SPEED
	set_velocity(follow_direction * lives_/initial_lives_ * speed_)
	move_and_slide()
		
func who() -> String:
	return "enemy"
	
#WHEN PROJECTILE HITS THIS ENEMY
func hit_by_projectile(projectile_color :Color, projectile_pos :Vector3, gun : MeshInstance3D) -> void:
	var delta_color1 = abs(projectile_color.h - color_.h)
	var delta_color2 = abs((projectile_color.h+1) - color_.h)
	var dmg :int
	
	if (delta_color1 < 0.1) or (delta_color2  < 0.1):
		dmg = 200
		player_.lives_ += 1 
	elif (delta_color1 < 0.2) or (delta_color2  < 0.2):
		dmg = 100 
	elif (delta_color1 < 0.10) or (delta_color2  < 0.10):
		dmg = 80
	elif (delta_color1 < 0.30) or (delta_color2  < 0.30):
		dmg = 20
	elif (delta_color1 < 0.50) or (delta_color2  < 0.50):
		dmg = 3
	else:
		dmg = 1
		
	lives_ -= dmg
	if lives_ <= 0:
		die(dmg)
	else:
		color_ = Color.from_hsv(color_.h,lives_/100.0,color_.v,color_.a)
		var hit_particle : Node = HIT_PARTICLE.instantiate()
		hit_particle.init(dmg, initial_color_, projectile_pos, float(lives_)/float(initial_lives_))
		main_.add_child(hit_particle)
		main_.dmg_done_last_round_ += dmg

#PLAYS DEATH ANIMATION AND DIES
func die(dmg, enemyMelee = false) -> void:
	follow_player_ = false
	death_dmg_ = dmg
	main_.enemies_killed_last_round_ += 1
	main_.dmg_done_last_round_ += dmg
	%AnimationPlayer.play("death")
	spawn_death_particles(enemyMelee)
	
#SPAWNS DEATH PARTICLES
func spawn_death_particles(enemyMelee = false):
	var hit_particle : Node = HIT_PARTICLE.instantiate()
	hit_particle.init(death_dmg_, initial_color_, position, 0.0, enemyMelee)
	main_.add_child(hit_particle)
