extends RigidBody3D

var direction_ : Vector3
var color_ : Color

func _ready() -> void:
	#initial force
	apply_central_force(direction_*666*2)
	decrease_light()

#initial direction
func init(direction, rotation, color) -> void:
	direction_ = direction
	set_rotation(rotation)
	color_ = color
	$MeshInstance3D.get_surface_override_material(0).set_albedo(color)
	$OmniLight3D.set_color(color)
	$CPUParticles3D.get_mesh().get_material().set_albedo(color)
	

func decrease_light() -> void:
	if $OmniLight3D.light_energy < 0.1:
		$OmniLight3D.queue_free()
		return
	$OmniLight3D.light_energy -= 0.1
	await get_tree().create_timer(0.1).timeout
	decrease_light()




#contact with enemy
func _on_body_entered(body : Node) -> void:
	if body is CharacterBody3D:
		if body.who() == "enemy":
#			print("-------------")
#			print(body.color_.h)
#			print(color_.h)
#			print(color_.h - body.color_.h)
			if (abs(color_.h - body.color_.h) < 0.10) or (abs((color_.h+1) - body.color_.h)  < 0.10):
				body.queue_free()
				self.queue_free()
			

