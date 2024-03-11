extends Node3D

#TODO možná hodit do detect_pull
var right_initial_grab_pos_ : Vector3
var left_initial_grab_pos_ : Vector3

var lives_ : int:
	set(value):
		lives_ = value
		#%WorldEnvironment.environment.fog_density = 0.07 - float(lives_) * 0.02
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
		
		print("po")
		print(%WorldEnvironment.environment.volumetric_fog_density)
		
		%AnimationPlayer.play("fog_density")
		
		print(lives_)
		
		if lives_ <= 0:
			main_.end_game()

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
	body.die(999)
	lives_ -= 1
