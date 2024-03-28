extends MeshInstance3D

const projectile_ : Resource = preload("res://scenes/projectile.tscn")
@onready var hand_ : XRController3D = get_parent()

var type_ = "shotgun"

#SHOOT FROM A GUN
func shoot() -> void:
	var angle = hand_.get_rotation().y
	angle += deg_to_rad(90)
	var shoot_direction = Vector3(cos(angle), hand_.get_rotation().x, sin(angle) * -1)
	var projectile1 : Node = projectile_.instantiate()
	
	match type_:
		"pistol":
			projectile1.init(shoot_direction, hand_.color_)
			projectile1.position = Vector3(-0.002, 0.038, -0.084)
			projectile1.top_level = true
			add_child(projectile1)
		"shotgun":
			var projectile2 : Node = projectile_.instantiate()
			var projectile3 : Node = projectile_.instantiate()
			
			projectile1.init(shoot_direction, hand_.color_)
			projectile2.init(shoot_direction.rotated(Vector3(0,1,0), -0.1), hand_.color_)
			projectile3.init(shoot_direction.rotated(Vector3(0,1,0), 0.1), hand_.color_)

			projectile2.position.z -= 0.2

			projectile3.position.z += 0.2
			
			projectile1.top_level = true
			projectile2.top_level = true
			projectile3.top_level = true
			
			add_child(projectile1)
			add_child(projectile2)
			add_child(projectile3)
		"charge_gun":
			add_child(projectile1)

	
	#print("ddddddddddddddddddddddddddddddd")
	#print(get_rotation().x)
	#print(rad_to_deg(get_rotation().x))
	
	#projectile.set_position(get_position()+get_parent().get_parent().get_position())
	
#	projectile.set_rotation_degrees(get_rotation_degrees())
	#main_.add_child(projectile)
	
