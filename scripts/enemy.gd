extends CharacterBody3D

var lives_ : int = 100

var follow_player_ : bool = true
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
	color_ = Color.from_hsv(randf_range(0,1), 1.0, 1.0, 1.0)
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
	
func hit_by_projectile(projectile_color : Color) -> void:
	var delta_color1 = abs(projectile_color.h - color_.h)
	var delta_color2 = abs((projectile_color.h+1) - color_.h)
	
	if (delta_color1 < 0.10) or (delta_color2  < 0.10):
		self.queue_free()
		print("perfect")
	elif (delta_color1 < 0.30) or (delta_color2  < 0.30):
		lives_ -= 20
		if lives_ <= 0:
			self.queue_free()
		color_ = Color.from_hsv(color_.h,lives_/100.0,color_.v,color_.a)
	elif (delta_color1 < 0.50) or (delta_color2  < 0.50):
		lives_ -= 5
		if lives_ <= 0:
			self.queue_free()
		color_ = Color.from_hsv(color_.h,lives_/100.0,color_.v,color_.a)
	else:
		lives_ -= 1
		if lives_ <= 0:
			self.queue_free()
		color_ = Color.from_hsv(color_.h,lives_/100.0,color_.v,color_.a)
		
	print(lives_)
