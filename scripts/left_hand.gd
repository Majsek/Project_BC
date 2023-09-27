extends XRController3D

@onready var main_ : Node = get_parent().get_parent().get_parent()
var color_ : Color

func _ready():
#jen na test
	color_ = Color.from_hsv(0, 1.0, 1.0, 1.0)
	$gun.get_surface_override_material(0).set_albedo(color_)
	get_parent().get_parent().set_color(color_)

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

				print("--------------")
				print(angle_degrees)
				print(mapped_value)
				
#tohle přesunout do setteru
				color_ = Color.from_hsv(mapped_value, 1.0, 1.0, 1.0)
				$gun.get_surface_override_material(0).set_albedo(color_)
				get_parent().get_parent().set_color(color_)

func _on_button_pressed(name):
#	print(name)
	match name:
		"by_button":
			get_tree().quit()
