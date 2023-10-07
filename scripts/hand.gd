extends XRController3D


var color_ : Color
var grab_ : bool = false
var is_right_hand :bool

const projectile_ : Resource = preload("res://scenes/projectile.tscn")

@onready var main_ : Node3D = get_parent().get_parent().get_parent()
@onready var player_ : Node3D = get_parent().get_parent()

func _ready():
#TEST initial color
	color_ = Color.from_hsv(0, 1.0, 1.0, 1.0)
	$gun.get_surface_override_material(0).set_albedo(color_)
	get_parent().get_parent().set_color(color_)
	
#TEST space shoot
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") != false:
		shoot()
	
#INPUTS
func _on_button_pressed(name):
	match name:
		"trigger_click":
			shoot()
			
		"grip_click":
			grab_ = true
			player_.check_grab()
		
		"by_button":
			if !is_right_hand:
				get_tree().reload_current_scene()

func _on_button_released(name):
	match name:
		"grip_click":
				grab_ = false
				player_.check_grab()
				
func _on_input_vector_2_changed(name, value):
#	print(value)
	match name:
		"primary":
#			if  value.x < abs(0.1) && value.y < abs(0.1):
#				return
			var joy_vector = Vector2(value.x, value.y)
			# if joystick dont have any output
			if joy_vector.length_squared() == 0:
				var angle_degrees = 0
			else:
				# calculate the angle
				var angle_radians = atan2(joy_vector.y, -joy_vector.x)
				var angle_degrees = rad_to_deg(angle_radians)-90
#				print("1 Směr joysticku ve stupních: ", rad_to_deg(angle_radians))
#				print("1 Směr joysticku radianech: ", angle_radians)
#
				if angle_degrees < 0:
					angle_degrees += 360
			
#				angle_radians -= PI/2
				
				var mapped_value = (angle_degrees / 360.0)
				
#				print("2 Směr joysticku ve stupních: ", rad_to_deg(angle_radians))
#				print("2 Směr joysticku radianech: ", angle_radians)

#				print("--------------")
#				print(angle_degrees)
#				print(mapped_value)
				
#tohle přesunout do setteru
				color_ = Color.from_hsv(mapped_value, 1.0, 1.0, 1.0)
				$gun.get_surface_override_material(0).set_albedo(color_)
#				get_parent().get_parent().set_color(color_)

#SHOOT from a gun
func shoot() -> void:
	var projectile : Node = projectile_.instantiate()
	
	var angler = get_rotation().y
	angler += deg_to_rad(90)
	var shoot_direction = Vector3(cos(angler), get_rotation().x, sin(angler) * -1)
	projectile.init(shoot_direction, get_rotation(), color_)
	projectile.set_position(get_position()+get_parent().get_parent().get_position())
#	projectile.set_rotation_degrees(get_rotation_degrees())
	main_.add_child(projectile)
