extends StaticBody3D

@onready var main_ : Node = get_parent()
@onready var player_ : Node = main_.player_

@export var initial_lives_ : int = 100
@export var lives_ : int
const HIT_PARTICLE = preload("res://scenes/hit_particle.tscn")

@export var class_ : StringName
var initial_color_ : Color
var color_ : Color:
	set(value):
		if value.s < 0.4:
			value.s = 0.4
		#print(value.s)
		color_ = value
		$MeshInstance3D.get_surface_override_material(0).set_albedo(color_)

func _ready():
	initial_color_ = Color.from_hsv(randf_range(0,1), 1.0, 1.0, 1.0)
	#initial_color_ = Color.from_hsv(0, 1.0, 1.0, 1.0)
	color_ = initial_color_
	lives_ = initial_lives_

#func spawnAnim():
	#%AnimationPlayer.play("enemy_spawn")
	#pass
func who() -> String:
	return "shotable"
	
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
	
	match class_:
		"start_cube":
			main_.start_game()
			self.queue_free()
