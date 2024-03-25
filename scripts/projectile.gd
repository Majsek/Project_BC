extends RigidBody3D

var direction_ : Vector3
var color_ : Color

@onready var main_ : Node3D = $"/root/world"

const HIT_PARTICLE = preload("res://scenes/hit_particle.tscn")

func _ready() -> void:
	#initial force
	#apply_central_force(direction_*666*2)
	apply_central_impulse(direction_*20)
	decrease_light()

#INIT
#- SETS DIRECTION AND ROTATION OF THE PROJECTILE
#- SETS COLOR OF: MESH, LIGHT, PARTICLES
func init(direction, color) -> void:
	direction_ = direction
	color_ = color
	$MeshInstance3D.get_surface_override_material(0).set_albedo(color)
	$OmniLight3D.set_color(color)
	$CPUParticles3D.get_mesh().get_material().set_albedo(color)
	
#DECREASES LIGHT OF THE PROJECTILE
func decrease_light() -> void:
	if $OmniLight3D.light_energy < 0.1:
		$OmniLight3D.queue_free()
		await get_tree().create_timer(0.2).timeout
		$MeshInstance3D.queue_free()
		$CollisionShape3D.queue_free()
		await get_tree().create_timer(0.9).timeout
		self.queue_free()
		return
	$OmniLight3D.light_energy -= 0.1
	await get_tree().create_timer(0.1).timeout
	decrease_light()

#SIGNALS CONTACT WITH ENEMY OR CONTROL_CUBE 
func _on_body_entered(body : Node) -> void:
	if body is CharacterBody3D or body is StaticBody3D:
		if body.who() == "enemy" or body.who() == "control_cube":
			body.hit_by_projectile(color_, position)
			self.queue_free()
			

