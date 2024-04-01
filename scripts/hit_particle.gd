extends GPUParticles3D

@onready var main_ : Node = $"/root/world"
var hit_sound_audio_players_ : Resource = preload("res://scenes/hit_sound_audio_players.tscn")
var hp_left_
var enemyMelee_ : bool = false

func _ready():
	emitting = true
	var hit_sound_audio_players = hit_sound_audio_players_.instantiate()
	hit_sound_audio_players.init(amount, position, hp_left_, enemyMelee_)
	main_.add_child(hit_sound_audio_players)

func init(dmg_dealt, color, pos, hp_left = 1.0, enemyMelee = false) -> void:
	amount = dmg_dealt
	position = pos
	hp_left_ = hp_left
	set_rotation(rotation)
	get_draw_pass_mesh(0).get_material().set_albedo(color)
	enemyMelee_ = enemyMelee
