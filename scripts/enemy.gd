extends CharacterBody3D

@onready var main_ : Node = $"/root/world"
@onready var player_ : Node = main_.player_

@export var initial_lives_ : int
@export var lives_ : int
const HIT_PARTICLE = preload("res://scenes/hit_particle.tscn")

@export var follow_player_ : bool = false
var initial_color_ : Color
var color_ : Color:
	set(value):
		if value.s < 0.4:
			value.s = 0.4
		#print(value.s)
		color_ = value
		$MeshInstance3D.get_surface_override_material(0).set_albedo(color_)

var speed = 10.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func init(difficulty_multiplier):
	initial_lives_ = randi_range(90*difficulty_multiplier,100*difficulty_multiplier)

func _ready():
	initial_color_ = Color.from_hsv(randf_range(0,1), 1.0, 1.0, 1.0)
	#initial_color_ = Color.from_hsv(0, 1.0, 1.0, 1.0)
	color_ = initial_color_
	lives_ = initial_lives_
	self.scale *= lives_/80.0
#	$MeshInstance3D.get_mesh().get_material().set_albedo(color_)
#	$MeshInstance3D.get_surface_override_material(0).set_albedo(color_)
	#await get_tree().create_timer(1).timeout
	spawnAnim()
	
func _physics_process(delta):
	# Add the gravity.
#	if not is_on_floor():
#		velocity.y -= gravity * delta
	followPlayer()


func spawnAnim():
	follow_player_ = true
	#var animation = %AnimationPlayer.get_animation("enemy_spawn")
	#var track_index1 = animation.add_track(Animation.TYPE_POSITION_3D)
	#animation.track_set_path(track_index1, $".")
	#animation.track_insert_key(0, 0.0, -1.0)
	#animation.track_insert_key(0, 0.6, 0.2)
	#animation.track_insert_key(0, 0.8, 0.0)
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
#	print(follow_direction)
	follow_direction.y = 0
#MOVEMENT SPEED
	set_velocity(follow_direction * lives_/initial_lives_)
	#if follow_direction != Vector3(0,0,0):
		#move_and_slide()
	move_and_slide()
		
func who() -> String:
	return "enemy"
	
func hit_by_projectile(projectile_color :Color, projectile_pos :Vector3) -> void:
	var delta_color1 = abs(projectile_color.h - color_.h)
	var delta_color2 = abs((projectile_color.h+1) - color_.h)
	var dmg :int
	
	if (delta_color1 < 0.2) or (delta_color2  < 0.2):
		dmg = 200
		#print("perfect")
		player_.lives_ += 1  
	elif (delta_color1 < 0.10) or (delta_color2  < 0.10):
		dmg = 150
	elif (delta_color1 < 0.30) or (delta_color2  < 0.30):
		dmg = 20
	elif (delta_color1 < 0.50) or (delta_color2  < 0.50):
		dmg = 3
	else:
		dmg = 1
		
	lives_ -= dmg
	color_ = Color.from_hsv(color_.h,lives_/100.0,color_.v,color_.a)
	if lives_ <= 0:
		die(dmg)
	else:
		var hit_particle : Node = HIT_PARTICLE.instantiate()
		hit_particle.init(dmg, initial_color_, projectile_pos)
		main_.add_child(hit_particle)
		main_.dmg_done_ += dmg

func die(dmg) -> void:
	follow_player_ = false
	var hit_particle : Node = HIT_PARTICLE.instantiate()
	hit_particle.init(dmg, initial_color_, position)
	main_.add_child(hit_particle)
	main_.enemies_killed_ += 1
	main_.dmg_done_ += dmg
	self.queue_free()
