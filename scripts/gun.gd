extends MeshInstance3D

const projectile_ : Resource = preload("res://scenes/projectile.tscn")
@onready var hand_ : XRController3D = get_parent()

var type_ = "pistol":
	set(value):
		type_ = value
		match type_:
			"pistol":
				self.mesh = preload("res://objects/guns/pistol1.1.obj")
			"shotgun":
				self.mesh = preload("res://objects/guns/shotgun1.obj")
			"charge_gun":
				self.mesh = preload("res://objects/guns/charge_gun1.obj")
var bullets_ : int = 0
var trigger_clicking_ : bool = false
var shooting_ : bool = false

#CALCULATES AND RETURNS SHOOTING DIRECTION
func calculate_shoot_direction() -> Vector3:
	var angle = hand_.get_rotation().y
	angle += deg_to_rad(90)
	var shoot_direction = Vector3(cos(angle), hand_.get_rotation().x, sin(angle) * -1)
	return shoot_direction

#SHOOT FROM A GUN
func shoot() -> void:
	var shoot_direction = calculate_shoot_direction()
	var projectile1 : Node = projectile_.instantiate()
	
	match type_:
		"pistol":
			projectile1.init(shoot_direction, hand_.color_, self)
			projectile1.position = Vector3(-0.002, 0.038, -0.084)
			projectile1.top_level = true
			add_child(projectile1)
			play_gun_anim()
		"shotgun":
			var projectile2 : Node = projectile_.instantiate()
			var projectile3 : Node = projectile_.instantiate()
			#INIT PROJECTILES AND ROTATE DIRECTION FOR SPREAD
			projectile1.init(shoot_direction, hand_.color_, self)
			projectile2.init(shoot_direction.rotated(Vector3(0,1,0), -0.1), hand_.color_, self)
			projectile3.init(shoot_direction.rotated(Vector3(0,1,0), 0.1), hand_.color_, self)
			#OFFSET POSITION
			projectile2.position.z -= 0.2
			projectile3.position.z += 0.2
			#SET TOP LEVEL
			projectile1.top_level = true
			projectile2.top_level = true
			projectile3.top_level = true
			
			add_child(projectile1)
			add_child(projectile2)
			add_child(projectile3)
			play_gun_anim()
		"charge_gun":
			load_bullets()
			if !hand_.trigger_clicking_:
				for b in bullets_:
					shooting_ = true
					shoot_direction = calculate_shoot_direction()
					projectile1 = projectile_.instantiate()
					projectile1.init(shoot_direction, hand_.color_, self)
					projectile1.position = Vector3(-0.002, 0.038, -0.084)
					projectile1.top_level = true
					play_gun_anim()
					add_child(projectile1)
					await get_tree().create_timer(0.05).timeout
				bullets_ = 0
				shooting_ = false

func play_gun_anim():
	$gun_animation_player.play("shoot")

func load_bullets():
	if shooting_:
		return
	if hand_.trigger_clicking_:
		await get_tree().create_timer(0.2).timeout
		hand_.trigger_haptic_pulse("load_bullet", 1.0, 1.0, 0.3, 0.3 )
		bullets_ += 1
		print(bullets_)
		load_bullets()
	elif !hand_.trigger_clicking_:
		return
		
#RAPID FIRE ATTACK
func rapid_fire() -> void:
	for i in 30:
		await get_tree().create_timer(0.08).timeout
		shoot()
		
	#print("ddddddddddddddddddddddddddddddd")
	#print(get_rotation().x)
	#print(rad_to_deg(get_rotation().x))
	
	#projectile.set_position(get_position()+get_parent().get_parent().get_position())
	
#	projectile.set_rotation_degrees(get_rotation_degrees())
	#main_.add_child(projectile)
	
