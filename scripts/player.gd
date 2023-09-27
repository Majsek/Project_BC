extends Node3D

@onready var main_ : Node = get_parent()
var color_ : Color

func _ready():
	main_.setPlayer(self)

func set_color(color:Color) -> void:
	color_ = color
	$XROrigin3D/right_hand/gun.get_surface_override_material(0).set_albedo(color_)
	
func get_color() -> Color:
	return color_
