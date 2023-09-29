extends Node3D

var color_ : Color
var right_initial_grab : Vector3
var left_initial_grab : Vector3
var player_initial_pos : Vector3
var pull_ : bool = false
var grab_ : bool = false

@onready var main_ : Node3D = get_parent()
@onready var right_hand_ : XRController3D = $XROrigin3D/right_hand
@onready var left_hand_ : XRController3D = $XROrigin3D/left_hand


func _ready():
	main_.setPlayer(self)

func _physics_process(delta):
	if grab_:
		detect_pull()

func set_color(color:Color) -> void:
	color_ = color
	$XROrigin3D/right_hand/gun.get_surface_override_material(0).set_albedo(color_)
	
func get_color() -> Color:
	return color_
	
func check_grab() -> void:
	print("------------------")
	print("check")
	
	if right_hand_.grab_ and left_hand_.grab_:
		print("grabuju")
		grab_ = true
	else:
		print("negrabuju")
		grab_ = false
		
func detect_pull():
		if !pull_:
			pull_ = true
			right_initial_grab = right_hand_.position
			left_initial_grab = left_hand_.position
			player_initial_pos = self.position

		if (right_hand_.position.distance_to(right_initial_grab) < 0.3) and (left_hand_.position.distance_to(left_initial_grab) < 0.3):
#			self.translate(Vector3(player_initial_pos.x+right_hand_.position.distance_to(right_initial_grab), player_initial_pos.y, player_initial_pos.z))
			var angel = $XROrigin3D/XRCamera3D.rotation
			var move_direction : Vector3 = Vector3(-1,0,0)
			self.translate(Vector3(
				move_direction.z*right_hand_.position.distance_to(right_initial_grab)*2, 
				0,
				move_direction.x*right_hand_.position.distance_to(right_initial_grab)*2).rotated(Vector3(0,1,0),angel.y))
			if player_initial_pos.distance_to(self.position) > 5:
				grab_ = false
				pull_ = false
		
		else:
			grab_ = false
			pull_ = false
