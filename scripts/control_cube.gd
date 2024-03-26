extends StaticBody3D

@onready var main_ : Node = $"/root/world"
@onready var player_ : Node = main_.player_

@export var initial_lives_ : int
@export var lives_ : int
const HIT_PARTICLE = preload("res://scenes/hit_particle.tscn")

@export var label_text_ : String
var initial_color_ : Color
var color_ : Color:
	set(value):
		if value.s < 0.4:
			value.s = 0.4
		#print(value.s)
		color_ = value
		$MeshInstance3D.get_surface_override_material(0).set_albedo(color_)
		$Label3D.outline_modulate = color_

func _ready():
	reset_mesh()
	reset_color()
	
	if label_text_ == "":
		$Label3D.text = name
	else:
		$Label3D.text = label_text_
		
	match name:
		"edge_2_allowed_cube":
			$MeshInstance3D.scale.x *= -1.0
		"edge_3_allowed_cube":
			$MeshInstance3D.rotation.z = deg_to_rad(90.0)
	
	match name:
		"start_cube":
			initial_lives_ = 100
		_:
			initial_lives_ = 1

	lives_ = initial_lives_

func reset_mesh():
	match name:
		"edge_2_allowed_cube":
			if main_.edge_2_allowed_:
				$MeshInstance3D.mesh = preload("res://objects/cubes/edge_in_cube.obj")
			else:
				$MeshInstance3D.mesh = preload("res://objects/cubes/edge_out_cube.obj")
		"edge_3_allowed_cube":
			if main_.edge_3_allowed_:
				$MeshInstance3D.mesh = preload("res://objects/cubes/edge_in_cube.obj")
			else:
				$MeshInstance3D.mesh = preload("res://objects/cubes/edge_out_cube.obj")
		"edge_4_allowed_cube":
			if main_.edge_4_allowed_:
				$MeshInstance3D.mesh = preload("res://objects/cubes/edge_in_cube.obj")
			else:
				$MeshInstance3D.mesh = preload("res://objects/cubes/edge_out_cube.obj")

func reset_color():
	initial_color_ = Color.from_hsv(randf_range(0,1), 1.0, 1.0, 1.0)
	color_ = initial_color_
	
func who() -> String:
	return "control_cube"

func hit_by_projectile(projectile_color :Color, projectile_pos :Vector3) -> void:
	var delta_color1 = abs(projectile_color.h - color_.h)
	var delta_color2 = abs((projectile_color.h+1) - color_.h)
	var dmg :int
	
	if (delta_color1 < 0.2) or (delta_color2  < 0.2):
		dmg = 200
		#print("perfect")
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
		destroy(dmg)
	else:
		var hit_particle : Node = HIT_PARTICLE.instantiate()
		hit_particle.init(dmg, initial_color_, projectile_pos)
		main_.add_child(hit_particle)
func destroy(dmg) -> void:
	var hit_particle : Node = HIT_PARTICLE.instantiate()
	hit_particle.init(dmg, initial_color_, position)
	main_.add_child(hit_particle)
	
	match name:
		"start_cube":
			main_.start_game()
			self.queue_free()
			
		"lives_shop_cube":
			player_.max_lives_ += 1
		"projectile_strength_cube":
			player_.projectile_impulse_strength_ += 1
		_:
			match name:
				"edge_2_allowed_cube":
					main_.edge_2_allowed_ = !main_.edge_2_allowed_
				"edge_3_allowed_cube":
					main_.edge_3_allowed_ = !main_.edge_3_allowed_
				"edge_4_allowed_cube":
					main_.edge_4_allowed_ = !main_.edge_4_allowed_
			lives_ += 100
			reset_color()
			reset_mesh()
			
