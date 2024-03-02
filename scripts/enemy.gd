extends CharacterBody3D

var lives_ : int = 100
const HIT_PARTICLE = preload("res://scenes/hit_particle.tscn")

@export var follow_player_ : bool = true
@export var is_start_cube_ : bool = false
var initial_color_ : Color
var color_ : Color:
	set(value):
		if value.s < 0.4:
			value.s = 0.4
		print(value.s)
		color_ = value
		$MeshInstance3D.get_surface_override_material(0).set_albedo(color_)

const SPEED = 10.0

@onready var main_ : Node = get_parent()
@onready var player_ : Node = main_.getPlayer()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	initial_color_ = Color.from_hsv(randf_range(0,1), 1.0, 1.0, 1.0)
	color_ = initial_color_
#	$MeshInstance3D.get_mesh().get_material().set_albedo(color_)
#	$MeshInstance3D.get_surface_override_material(0).set_albedo(color_)
	
func _physics_process(delta):
	# Add the gravity.
#	if not is_on_floor():
#		velocity.y -= gravity * delta
#
	if follow_player_ == true:
		followPlayer()
	
func followPlayer() -> void:
	var follow_direction : Vector3 = get_global_position().direction_to(player_.get_global_position())
	var angle : float = rad_to_deg(Vector3(1, 0, 0).angle_to(Vector3(follow_direction.x, 0, follow_direction.z)))
	if follow_direction.z > 0 :
		angle = 360 - angle
	self.set_rotation_degrees(Vector3(0,angle+90,0))
	
#	print(follow_direction)
	follow_direction.y = 0
	set_velocity(follow_direction)
	if follow_direction != Vector3(0,0,0):
		move_and_slide()
		
func who() -> String:
	return "enemy"
	
func hit_by_projectile(projectile_color : Color) -> Array:
	var delta_color1 = abs(projectile_color.h - color_.h)
	var delta_color2 = abs((projectile_color.h+1) - color_.h)
	
	var dmg : int
	
	if (delta_color1 < 0.10) or (delta_color2  < 0.10):
		dmg = 150
		print("perfect")
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
		
	return [dmg,initial_color_]

func die(dmg) -> void:
	follow_player_ = false
	if dmg >= 100:
		var hit_particle : Node = HIT_PARTICLE.instantiate()
		hit_particle.init(dmg, initial_color_, position)
		main_.add_child(hit_particle)
	if is_start_cube_:
		main_.running_ = true
	self.queue_free()
