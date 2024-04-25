extends Node3D

var right_initial_grab_pos_ : Vector3
var left_initial_grab_pos_ : Vector3

#LIVES
var max_lives_ : int = 3:
	set(value):
		max_lives_ = value
		lives_ = max_lives_
		
var lives_ : int:
	set(value):
		lives_ = value
		if lives_ > max_lives_:
			lives_ = max_lives_
		elif lives_ <= 0:
			death_anim()
		else:
			decrease_lives_anim()

var player_initial_pos_ : Vector3
var pulling_ : bool = false
var grabbing_ : bool = false
var first_grabbing_hand_ : XRController3D

var projectile_impulse_strength_ : float = 10.0

@onready var main_ : Node3D = $"/root/world"
@onready var right_hand_ : XRController3D = $XROrigin3D/right_hand
@onready var left_hand_ : XRController3D = $XROrigin3D/left_hand
@onready var tutorial_ : Label3D = $XROrigin3D/XRCamera3D/tutorial

func _ready():
	main_.player_ = self
	lives_ = max_lives_
	decrease_lives_anim()
	right_hand_.player_ = self
	left_hand_.player_ = self

func _physics_process(delta):
	if grabbing_:
		detect_pull()
#TEST:
	if Input.is_action_just_pressed("ui_up"):
		lives_ +=1
	if Input.is_action_just_pressed("ui_down"):
		lives_ -=1

#CALCULATES AND ANIMATES ENVIRONMETAL FOG ON lives_ CHANGE
func decrease_lives_anim() -> void:
	var animation = %AnimationPlayer.get_animation("fog_density")
	
	var fog_density_change = float(lives_)/float(max_lives_)
	var fog_density = 0.025 - 0.015 * fog_density_change
	var volumetric_fog_density = 0.1 - 0.09 * fog_density_change
	
	var track_index1 = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index1, "%WorldEnvironment:environment:fog_density")
	animation.track_insert_key(0, 0.0, %WorldEnvironment.environment.fog_density)
	animation.track_insert_key(0, 0.5, fog_density)

	%WorldEnvironment.environment.volumetric_fog_density = volumetric_fog_density
	
	%AnimationPlayer.play("fog_density")
	
#ANIMATES ENVIRONMENTAL FOG ON DEATH
func death_anim() -> void:
	right_hand_.visible = false
	left_hand_.visible = false
	
	right_hand_.grabbing_ = false
	left_hand_.grabbing_ = false
	
	self.collision_layer = 0
	self.collision_mask = 0
	main_.stop_enemies()
	
	for i in range(13):
		%WorldEnvironment.environment.volumetric_fog_density = 0.15 + 0.05 * i
		await get_tree().create_timer(0.1).timeout
	for i in range(3):
		%WorldEnvironment.environment.volumetric_fog_density = 0.8 + 0.1 * i
		await get_tree().create_timer(0.1).timeout
	for i in range(4):
		%WorldEnvironment.environment.volumetric_fog_density = 1.2 + 0.2 * i
		await get_tree().create_timer(0.1).timeout
	for i in range(4):
		%WorldEnvironment.environment.volumetric_fog_density = 2.0 + 0.4 * i
		await get_tree().create_timer(0.1).timeout
	%WorldEnvironment.environment.volumetric_fog_density = 3.8
	await get_tree().create_timer(0.1).timeout
	%WorldEnvironment.environment.volumetric_fog_density = 4.8
	await get_tree().create_timer(0.1).timeout
	%WorldEnvironment.environment.volumetric_fog_density = 6.0
	await get_tree().create_timer(0.1).timeout
	%WorldEnvironment.environment.volumetric_fog_density = 10.0
	await get_tree().create_timer(0.1).timeout
	%WorldEnvironment.environment.volumetric_fog_density = 20.0
	await get_tree().create_timer(2.0).timeout

	main_.end_game()

#CHECKS IF THE HAND IS GRABBING AND PULLING
func check_grab() -> void:
	if right_hand_.grabbing_ or left_hand_.grabbing_:
		grabbing_ = true
		
		if first_grabbing_hand_ == null:
			if right_hand_.grabbing_:
				first_grabbing_hand_ = right_hand_
			elif left_hand_.grabbing_:
				first_grabbing_hand_ = left_hand_
				
		elif !first_grabbing_hand_.grabbing_:
			if first_grabbing_hand_ == right_hand_:
				first_grabbing_hand_ = left_hand_
				pulling_ = false
			else:
				first_grabbing_hand_ = right_hand_
				pulling_ = false
	else:
		grabbing_ = false
		pulling_ = false
		first_grabbing_hand_ = null
		
#DETECT PULLING AND CALCULATES POSITION OF THE PLAYER
func detect_pull():
	if !pulling_:
		pulling_ = true
		player_initial_pos_ = self.position
		
		right_initial_grab_pos_ = right_hand_.position
		left_initial_grab_pos_ = left_hand_.position

	if first_grabbing_hand_ == right_hand_:
		#TODO: maybe useless if
		if right_hand_.grabbing_:
			change_pos(Vector3(
				player_initial_pos_.x+(right_initial_grab_pos_.x-right_hand_.position.x)*10, 
				0,
				player_initial_pos_.z+(right_initial_grab_pos_.z-right_hand_.position.z)*10)
			)
	
	if first_grabbing_hand_ == left_hand_:
		#TODO: maybe useless if
		if left_hand_.grabbing_:
			change_pos(Vector3(
				player_initial_pos_.x+(left_initial_grab_pos_.x-left_hand_.position.x)*10, 
				0,
				player_initial_pos_.z+(left_initial_grab_pos_.z-left_hand_.position.z)*10)
			)

#CHANGES POSITION OF THE PLAYER AND LIMITS IT TO THE PLAYABLE AREA: <+20xz,-20xz>
func change_pos(new_pos):
	##X
	if (new_pos.x > 20):
		new_pos.x = 20
	if (new_pos.x < -20):
		new_pos.x = -20
	##Z
	if (new_pos.z > 20):
		new_pos.z = 20
	if (new_pos.z < -20):
		new_pos.z = -20
	position = new_pos
	print("----------------")
	print("position.y")
	print(position.y)
	print("----------------")
		
func _on_body_entered(body):
	if body.who() == "control_cube" || body.who() == "floor":
		return
	if body.who() == "enemy":
		if !main_.running_:
			return
	body.die(0, true)
	lives_ -= 1


