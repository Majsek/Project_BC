extends Node3D

#TODO možná hodit do detect_pull
var right_initial_grab_pos_ : Vector3
var left_initial_grab_pos_ : Vector3

var lives_ : int:
	set(value):
		lives_ = value
		if lives_ > 3:
			lives_ = 3
		if lives_ <= 0:
			death_anim()
		else:
			decrease_lives_anim()
var player_initial_pos_ : Vector3
var pulling_ : bool = false
var grabbing_ : bool = false
var first_grabbing_hand_ : XRController3D

@onready var main_ : Node3D = get_parent()
@onready var right_hand_ : XRController3D = $XROrigin3D/right_hand
@onready var left_hand_ : XRController3D = $XROrigin3D/left_hand

var anim_player_ : AnimationPlayer

func _ready():
	main_.player_ = self
	lives_ = 3

func _physics_process(delta):
	if grabbing_:
		detect_pull()
#TEST:
	if Input.is_action_just_pressed("ui_up"):
		lives_ +=1
	if Input.is_action_just_pressed("ui_down"):
		lives_ -=1

## animates environment:fog_density
func decrease_lives_anim() -> void:
	var animation = %AnimationPlayer.get_animation("fog_density")
	
	print("před")
	print(%WorldEnvironment.environment.volumetric_fog_density)
	
	var track_index1 = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index1, "%WorldEnvironment:environment:fog_density")
	animation.track_insert_key(0, 0.0, %WorldEnvironment.environment.fog_density)
	#animation.track_insert_key(0, 0.5, 0.07 - float(lives_) * 0.02)
	animation.track_insert_key(0, 0.5, 0.025 - float(lives_) * 0.005)
	
	#var track_index2 = animation.add_track(Animation.TYPE_VALUE)
	#animation.track_set_path(track_index2, "%WorldEnvironment:environment:volumetric_fog_density")
	#animation.track_insert_key(0, 0.0, %WorldEnvironment.environment.volumetric_fog_density)
	#animation.track_insert_key(0, 0.5, 0.07 - float(lives_) * 0.02)
	
	%WorldEnvironment.environment.volumetric_fog_density = 0.025 - float(lives_) * 0.005
	
	%AnimationPlayer.play("fog_density")
	
func death_anim() -> void:
	right_hand_.visible = false
	left_hand_.visible = false
	
#NOTE: ono to asi neumí bejt interpolovaný a animovaný vůbec, jen po kouscích si to můžu vlastně jakoby animovat sám, musím to nějak vyladit, jestli vůbec chci mít emission, nebo nn
	var animation = %AnimationPlayer.get_animation("volumetric_fog_density")
#TODO je to nějaký sus, asi by to chtělo předělat přímo na timery a nepoužívat animace vůbec v tomhle případě
	var track_index1 = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index1, "%WorldEnvironment:environment:fog_density")
	animation.track_insert_key(0, 0.0, 0.025)
	animation.track_insert_key(0, 0.1, 0.03)
	animation.track_insert_key(0, 0.2, 0.04)
	animation.track_insert_key(0, 0.3, 0.05)
	animation.track_insert_key(0, 0.4, 0.06)
	animation.track_insert_key(0, 0.5, 0.07)
	animation.track_insert_key(0, 0.6, 0.08)
	animation.track_insert_key(0, 0.7, 0.09)
	animation.track_insert_key(0, 0.8, 0.10)
	animation.track_insert_key(0, 0.9, 0.11)
	animation.track_insert_key(0, 1.0, 0.12)
	animation.track_insert_key(0, 1.1, 0.13)
	animation.track_insert_key(0, 1.2, 0.14)
	animation.track_insert_key(0, 1.3, 0.15)
	animation.track_insert_key(0, 1.4, 0.16)
	animation.track_insert_key(0, 1.5, 0.17)
	animation.track_insert_key(0, 1.6, 0.18)
	animation.track_insert_key(0, 1.7, 0.19)
	animation.track_insert_key(0, 1.8, 0.20)
	animation.track_insert_key(0, 1.9, 0.21)
	animation.track_insert_key(0, 2.0, 0.22)
	animation.track_insert_key(0, 2.1, 0.23)
	animation.track_insert_key(0, 2.2, 0.24)
	animation.track_insert_key(0, 2.3, 0.25)
	animation.track_insert_key(0, 2.4, 0.26)
	animation.track_insert_key(0, 2.5, 0.27)
	animation.track_insert_key(0, 2.6, 0.28)
	animation.track_insert_key(0, 2.7, 0.29)
	animation.track_insert_key(0, 2.8, 0.30)
	animation.track_insert_key(0, 2.9, 0.31)
	animation.track_insert_key(0, 3.0, 0.32)
	animation.track_insert_key(0, 3.1, 0.33)
	animation.track_insert_key(0, 3.2, 0.34)
	animation.track_insert_key(0, 3.3, 0.35)
	animation.track_insert_key(0, 3.4, 0.36)
	animation.track_insert_key(0, 3.5, 0.37)
	animation.track_insert_key(0, 3.6, 0.38)
	animation.track_insert_key(0, 3.7, 0.39)
	animation.track_insert_key(0, 3.8, 0.40)
	animation.track_insert_key(0, 3.9, 0.41)
	animation.track_insert_key(0, 4.0, 0.42)
	
	%AnimationPlayer.play("volumetric_fog_density")
	
	%WorldEnvironment.environment.fog_density = 0.2
	#print(%WorldEnvironment.environment.fog_density)
	
	#%WorldEnvironment.environment.volumetric_fog_density = 0.025 - float(lives_) * 0.005
	#await get_tree().create_timer(4).timeout
	main_.end_game()

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
		
		
#TODO: refactoring => nějaký ify a řádky jsou zbytečný
func detect_pull():
	if !pulling_:
		pulling_ = true
		player_initial_pos_ = self.position
		
		right_initial_grab_pos_ = right_hand_.position
		left_initial_grab_pos_ = left_hand_.position

	#if (right_hand_.position.distance_to(right_initial_grab_pos_) < 0.3):
	if first_grabbing_hand_ == right_hand_:
		#TODO: tenhle if je možná zbytečnej
		if right_hand_.grabbing_:
			self.position = Vector3(
				player_initial_pos_.x+(right_initial_grab_pos_.x-right_hand_.position.x)*10, 
				0,
				player_initial_pos_.z+(right_initial_grab_pos_.z-right_hand_.position.z)*10)
	
	if first_grabbing_hand_ == left_hand_:
		#TODO: tenhle if je možná zbytečnej
		if left_hand_.grabbing_:
			self.position = Vector3(
				player_initial_pos_.x+(left_initial_grab_pos_.x-left_hand_.position.x)*10, 
				0,
				player_initial_pos_.z+(left_initial_grab_pos_.z-left_hand_.position.z)*10)


func _on_body_entered(body):
	if body.is_start_cube_:
		return
	body.die(999)
	lives_ -= 1
