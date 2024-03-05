extends Node3D

#TODO možná hodit do detect_pull
var right_initial_grab_pos_ : Vector3
var left_initial_grab_pos_ : Vector3

var player_initial_pos_ : Vector3
var pulling_ : bool = false
var grabbing_ : bool = false

@onready var main_ : Node3D = get_parent()
@onready var right_hand_ : XRController3D = $XROrigin3D/right_hand
@onready var left_hand_ : XRController3D = $XROrigin3D/left_hand


func _ready():
	main_.setPlayer(self)

func _physics_process(delta):
	if grabbing_:
		detect_pull()
	
func check_grab() -> void:
	print("------------------")
	print("check")
	
	#if right_hand_.grabbing_ and left_hand_.grabbing_:
	if right_hand_.grabbing_:
		print("grabuju")
		grabbing_ = true
	else:
		print("negrabuju")
		grabbing_ = false
		pulling_ = false
		
func detect_pull():
	if !pulling_:
		pulling_ = true
		player_initial_pos_ = self.position
		right_initial_grab_pos_ = right_hand_.position

	#if (right_hand_.position.distance_to(right_initial_grab_pos_) < 0.3):
	self.position = Vector3(
		player_initial_pos_.x+(right_initial_grab_pos_.x-right_hand_.position.x)*10, 
		0,
		player_initial_pos_.z+(right_initial_grab_pos_.z-right_hand_.position.z)*10)
		#if player_initial_pos_.distance_to(self.position) > 8:
			#grabbing_ = false
			#pulling_ = false
	#else:
		#grabbing_ = false
		#pulling_ = false
		
#old movement with both hands
#func detect_pull():
	#var angle : float
	#if !pulling_:
		#pulling_ = true
		#right_initial_grab_pos_ = right_hand_.position
		#left_initial_grab_pos_ = left_hand_.position
		#player_initial_pos_ = self.position
#
		#angle = $XROrigin3D/XRCamera3D.rotation.y
#
	#if (right_hand_.position.distance_to(right_initial_grab_pos_) < 0.3) and (left_hand_.position.distance_to(left_initial_grab_pos_) < 0.3):
		#var phase_direction : Vector3 = Vector3(-1,0,0)
		#angle = $XROrigin3D/XRCamera3D.rotation.y
		#var speed = 0.01 + right_hand_.position.distance_to(right_initial_grab_pos_)+left_hand_.position.distance_to(left_initial_grab_pos_)*3
		#self.translate(Vector3(
			#phase_direction.z*speed, 
			#0,
			#phase_direction.x*speed).rotated(Vector3(0,1,0),angle))
		#if player_initial_pos_.distance_to(self.position) > 8:
			#grabbing_ = false
			#pulling_ = false
	#else:
		#grabbing_ = false
		#pulling_ = false
