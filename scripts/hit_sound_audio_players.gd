extends Node3D

var dmg_dealt_
var hp_left_
var enemyMelee_ : bool = false

#IMMEDIATELY PLAYS THE SOUND
func _ready():
	if enemyMelee_:
		play_melee_sound()
	else:
		play_hit_sound()

#SETS STRENGTH AND POSITION OF THE AudioStreamPlayers3D
func init(dmg_dealt, pos, hp_left, enemyMelee = false):
	dmg_dealt_ = dmg_dealt
	position = pos
	hp_left_ = hp_left
	enemyMelee_ = enemyMelee

#RANDOMLY SELECTS SOUNDS ON HIT AND PLAYS THEM
#- AFTER PLAYING KILLS ITSELF
func play_hit_sound():
	var hit_sounds_array : Array = [preload("res://audio/hit_sounds/hit_sound_F7_wav.tres"), preload("res://audio/hit_sounds/hit_sound_G7_wav.tres"), preload("res://audio/hit_sounds/hit_sound_H7_wav.tres")]
	
	var strength
	if dmg_dealt_ >= 100:
		strength = 3
	elif dmg_dealt_ >= 20:
		strength = 2
	else:
		strength = 1
	
	var pitch_scale = 2.0 - hp_left_
	
	$audioPlayer1.pitch_scale = pitch_scale
	$audioPlayer2.pitch_scale = pitch_scale
	$audioPlayer3.pitch_scale = pitch_scale
	
	match strength:
		1:
			$audioPlayer1.stream = hit_sounds_array[randi_range(0,2)]
			$audioPlayer1.play()
		2:
			$audioPlayer1.stream = hit_sounds_array[randi_range(0,2)]
			$audioPlayer1.play()
			#await get_tree().create_timer(0.03).timeout
			#$audioPlayer2.stream = hit_sounds_array[randi_range(0,2)]
			#$audioPlayer2.play()
		3:
			$audioPlayer1.stream = hit_sounds_array[randi_range(0,2)]
			$audioPlayer1.play()
			#await get_tree().create_timer(0.03).timeout
			#$audioPlayer2.stream = hit_sounds_array[randi_range(0,2)]
			#$audioPlayer2.play()
			#await get_tree().create_timer(0.03).timeout
			#$audioPlayer3.stream = hit_sounds_array[randi_range(0,2)]
			#$audioPlayer3.play()
	await get_tree().create_timer(1.0).timeout
	queue_free()
	
func play_melee_sound():
	$audioPlayer1.stream = preload("res://audio/raccoon_sounds/RawrRawr_mp3.tres")
	$audioPlayer1.play()
	await get_tree().create_timer(1.0).timeout
	queue_free()
