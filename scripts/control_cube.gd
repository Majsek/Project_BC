extends StaticBody3D

@onready var main_ : Node = $"/root/world"
@onready var player_ : Node = main_.player_

@export var initial_lives_ : int
@export var lives_ : int
const HIT_PARTICLE = preload("res://scenes/hit_particle.tscn")

@export var label_text_ : String:
	set(value):
		label_text_ = value
		$Label3D.text = label_text_
@export var description_text_ : String
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
	add_to_group("control_cubes")
	reset_color()
	reset_mesh()
	
	if label_text_ == "":
		$Label3D.text = name
	else:
		$Label3D.text = label_text_
		$Label3D/description.text = description_text_
		
	match name:
		"edge_2_allowed_cube":
			$MeshInstance3D.scale.x *= -1.0
		"edge_3_allowed_cube":
			$MeshInstance3D.rotation.z = deg_to_rad(90.0)
	
	match name:
		"start_cube":
			initial_lives_ = 100
		_:
			initial_lives_ = 50

	lives_ = initial_lives_

func reset_mesh():
	match name:
		"shotgun":
			$MeshInstance3D.mesh = preload("res://objects/guns/shotgun1.obj")
			reset_color(Color.from_hsv(0.5, 0.0, 1.0, 1.0))
			label_text_ = "Shotgun"
			description_text_ = "-shoots 3x bulets"
		"charge_gun":
			$MeshInstance3D.mesh = preload("res://objects/guns/charge_gun1.obj")
			reset_color(Color.from_hsv(0.5, 0.0, 1.0, 1.0))
			label_text_ = "Charge gun"
			description_text_ = "-hold trigger to load, release to fire"
		"frost_shop_cube":
			$MeshInstance3D.mesh = preload("res://objects/cubes/frost_cube.obj")
			reset_color(Color.from_hsv(0.52, 1.0, 1.0, 1.0))
			label_text_ = "Frostbite"
			description_text_ = "-drastically slows enemy movement"
		"lives_shop_cube":
			$MeshInstance3D.mesh = preload("res://objects/cubes/plus_hp_cube.obj")
			reset_color(Color.from_hsv(0.33, 1.0, 1.0, 1.0))
			label_text_ = "HP Booster"
			description_text_ = "-increases player's maximum health"
		"projectile_strength_shop_cube":
			$MeshInstance3D.mesh = preload("res://objects/cubes/projectile_strength_cube.obj")
			reset_color(Color.from_hsv(0.15, 1.0, 1.0, 1.0))
			label_text_ = "Velocity Upgrade"
			description_text_ = "-increases bullet speed"
		"rapid_fire_cube":
			$MeshInstance3D.mesh = preload("res://objects/cubes/rapid_fire_cube.obj")
			reset_color(Color.from_hsv(0.916, 1.0, 1.0, 1.0))
			label_text_ = "Rapid Fire"
			description_text_ = "-rapidly autofire for a limited duration"
			
		"edge_2_allowed_cube":
			if main_.edge_2_allowed_:
				$MeshInstance3D.mesh = preload("res://objects/cubes/edge_in_cube.obj")
				reset_color(Color.from_hsv(0.0, 1.0, 1.0, 1.0))
				label_text_ = "Right edge spawn ON"
			else:
				$MeshInstance3D.mesh = preload("res://objects/cubes/edge_out_cube.obj")
				reset_color(Color.from_hsv(0.33, 1.0, 1.0, 0.2))
				label_text_ = "Right edge spawn OFF"
		"edge_3_allowed_cube":
			if main_.edge_3_allowed_:
				$MeshInstance3D.mesh = preload("res://objects/cubes/edge_in_cube.obj")
				reset_color(Color.from_hsv(0.0, 1.0, 1.0, 1.0))
				label_text_ = "Back edge spawn ON"
			else:
				$MeshInstance3D.mesh = preload("res://objects/cubes/edge_out_cube.obj")
				reset_color(Color.from_hsv(0.33, 1.0, 1.0, 0.2))
				label_text_ = "Back edge spawn OFF"
		"edge_4_allowed_cube":
			if main_.edge_4_allowed_:
				$MeshInstance3D.mesh = preload("res://objects/cubes/edge_in_cube.obj")
				reset_color(Color.from_hsv(0.0, 1.0, 1.0, 1.0))
				label_text_ = "Left edge spawn ON"
			else:
				$MeshInstance3D.mesh = preload("res://objects/cubes/edge_out_cube.obj")
				reset_color(Color.from_hsv(0.33, 1.0, 1.0, 0.2))
				label_text_ = "Left edge spawn OFF"
				
		"exit_cube":
			$MeshInstance3D.mesh = preload("res://objects/cubes/exit_cube.obj")
			reset_color(Color.from_hsv(0.0, 1.0, 1.0, 0.2))

func reset_color(initial_color : Color = Color.from_hsv(randf_range(0,1), 1.0, 1.0, 1.0)):
	initial_color_ = initial_color
	color_ = initial_color
	
func who() -> String:
	return "control_cube"

func hit_by_projectile(projectile_color :Color, projectile_pos :Vector3, gun : MeshInstance3D) -> void:
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
		destroy(dmg, gun)
	else:
		var hit_particle : Node = HIT_PARTICLE.instantiate()
		hit_particle.init(dmg, initial_color_, projectile_pos)
		main_.add_child(hit_particle)
		
func destroy(dmg, gun : MeshInstance3D) -> void:
	var hit_particle : Node = HIT_PARTICLE.instantiate()
	hit_particle.init(dmg, initial_color_, position)
	main_.add_child(hit_particle)
	
#LOGIC => what each cube does
	match name:
		"start_cube":
			main_.start_game()
			
		"exit_cube":
			get_tree().quit()
			
		"shotgun":
			gun.type_ = "shotgun"
			main_.shop_cubes_.erase("shotgun")
			main_.start_game()
			
		"charge_gun":
			gun.type_ = "charge_gun"
			main_.shop_cubes_.erase("charge_gun")
			main_.start_game()
			
		"frost_shop_cube":
			main_.start_game()
			for e in main_.enemies_:
				if e != null:
					e.speed_ = 0.1
			await get_tree().create_timer(8).timeout
			for e in main_.enemies_:
				if e != null:
					e.speed_ = 1.0
					
		"lives_shop_cube":
			player_.max_lives_ += 1
			main_.start_game()
			
		"projectile_strength_shop_cube":
			player_.projectile_impulse_strength_ += 1
			main_.start_game()
			
		"rapid_fire_cube":
			main_.start_game()
			gun.rapid_fire()
		_:
			match name:
				"edge_2_allowed_cube":
					main_.edge_2_allowed_ = !main_.edge_2_allowed_
				"edge_3_allowed_cube":
					main_.edge_3_allowed_ = !main_.edge_3_allowed_
				"edge_4_allowed_cube":
					main_.edge_4_allowed_ = !main_.edge_4_allowed_
			lives_ = initial_lives_
			reset_color()
			reset_mesh()
			
