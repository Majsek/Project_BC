extends XRController3D

const projectile_ : Resource = preload("res://scenes/projectile.tscn")
var grab_ : bool = false

@onready var main_ : Node = get_parent().get_parent().get_parent()
@onready var player_ : Node3D = get_parent().get_parent()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") != false:
		shoot()
	
#shoot from a gun
func shoot() -> void:
	var projectile : Node = projectile_.instantiate()
	
	var angler = get_rotation().y
	angler += deg_to_rad(90)
	var shoot_direction = Vector3(cos(angler), get_rotation().x, sin(angler) * -1)
	projectile.init(shoot_direction, get_rotation(), get_parent().get_parent().get_color())
	projectile.set_position(get_position()+get_parent().get_parent().get_position())
#	projectile.set_rotation_degrees(get_rotation_degrees())
	main_.add_child(projectile)

func _on_button_pressed(name):
	match name:
		"trigger_click":
			shoot()
			
		"grip_click":
			grab_ = true
			player_.check_grab()


func _on_button_released(name):
	match name:
		"grip_click":
				grab_ = false
				player_.check_grab()
