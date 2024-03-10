extends GPUParticles3D

func _ready():
	emitting = true

func init(dmg_dealt, color, pos) -> void:
	amount = dmg_dealt
	position = pos
	set_rotation(rotation)
	get_draw_pass_mesh(0).get_material().set_albedo(color)
	#print(amount)
