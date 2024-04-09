extends XRController3D


var color_ : Color:
	set(value):
		color_ = value
		$gun.get_surface_override_material(0).set_albedo(color_)
		$gun/hue_ring/node_to_be_rotated/hue_pointer.get_surface_override_material(0).set_albedo(color_)

var grabbing_ : bool = false
var is_right_hand_ : bool
var trigger_clicking_ : bool = false

@onready var main_ : Node3D = $"/root/world"
@onready var player_ : Node3D

func _ready():
	init()
#TEST initial color
	color_ = Color.from_hsv(0, 1.0, 1.0, 1.0)
	
func init() -> void:
#(init functions are in left_hand.gd and right_hand.gd)
	pass

func _process(_delta: float) -> void:
	#TEST space shoot
	if Input.is_action_just_pressed("ui_accept") != false:
		if is_right_hand_:
			trigger_clicking_ = true
			$gun.shoot()
			
	if Input.is_action_just_released("ui_accept") != false:
		if is_right_hand_:
			trigger_clicking_ = false
			if $gun.type_ == "charge_gun":
				$gun.shoot()
	
		
	#TEST rapid fire
	if Input.is_action_just_pressed("ui_left") != false:
		if is_right_hand_:
			$gun.rapid_fire()
			
	#TEST rapid fire
	if Input.is_action_just_pressed("ui_right") != false:
		if is_right_hand_:
			main_.xp_ += 1
	#TEST R restart
	if Input.is_action_just_pressed("restart") != false:
#TODO: jedna restart funkce ve world.gd
		get_tree().reload_current_scene()
		
#BUTTON INPUTS
func _on_button_pressed(name) -> void:
	if !self.visible:
		return
	match name:
		"trigger_click":
			trigger_clicking_ = true
			if player_.tutorial_.tutorial_ == 0 || player_.tutorial_.tutorial_ == 2:
				return
			$gun.shoot()
			if player_.tutorial_.tutorial_ == 1:
				player_.tutorial_.tutorial_ = 2
			
		"grip_click":
			grabbing_ = true
			if player_.tutorial_.tutorial_ == 0 || player_.tutorial_.tutorial_ == 1:
				return
			player_.check_grab()
			if player_.tutorial_.tutorial_ == 2:
				player_.tutorial_.tutorial_ = 3
		
		"by_button":
			if !is_right_hand_:
				#get_tree().reload_current_scene()
				pass
			else:
				#$gun.rapid_fire()
				pass

func _on_button_released(name) -> void:
	match name:
		"trigger_click":
			trigger_clicking_ = false
			if $gun.type_ == "charge_gun":
				$gun.shoot()

func _on_input_float_changed(name, value):
	match name:
		"grip":
			if value < 0.3:
				grabbing_ = false
				player_.check_grab()

#COLOR SELECTION
func _on_input_vector_2_changed(name, value) -> void:
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
				$gun/hue_ring/node_to_be_rotated.rotation_degrees.y = -angle_degrees
				color_ = Color.from_hsv(mapped_value, 1.0, 1.0, 1.0)
				
				if player_.tutorial_.tutorial_ == 0:
						player_.tutorial_.tutorial_ = 1

##SHOOT FROM A GUN
#func shoot() -> void:
	#var projectile : Node = projectile_.instantiate()
	#
	#var angle = get_rotation().y
	#angle += deg_to_rad(90)
	#var shoot_direction = Vector3(cos(angle), get_rotation().x, sin(angle) * -1)
	##print("ddddddddddddddddddddddddddddddd")
	##print(get_rotation().x)
	##print(rad_to_deg(get_rotation().x))
	#projectile.init(shoot_direction, color_)
	#
	##projectile.set_position(get_position()+get_parent().get_parent().get_position())
	#projectile.position = Vector3(-0.002, 0.038, -0.084)
	#projectile.top_level = true
	#
##	projectile.set_rotation_degrees(get_rotation_degrees())
	##main_.add_child(projectile)
	#add_child(projectile)
