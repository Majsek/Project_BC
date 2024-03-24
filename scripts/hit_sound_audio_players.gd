extends Node3D

var dmg_dealt_

#IMMEDIATELY PLAYS THE SOUND
func _ready():
	play_hit_sound()

#SETS STRENGTH AND POSITION OF THE AudioStreamPlayers3D
func init(dmg_dealt, pos):
	dmg_dealt_ = dmg_dealt
	position = pos

#RANDOMLY SELECTS SOUNDS ON HIT AND PLAYS THEM (number of sounds depends on dmg_deal_)
#- AFTER PLAYING KILLS ITSELF
func play_hit_sound():
	var hit_sounds_array : Array = [preload("res://audio/hit_sound_F7_wav.tres"), preload("res://audio/hit_sound_G7_wav.tres"), preload("res://audio/hit_sound_H7_wav.tres")]
	
	var strength
	if dmg_dealt_ >= 100:
		strength = 3
	elif dmg_dealt_ >= 20:
		strength = 2
	else:
		strength = 1
	
	match strength:
		1:
			$audioPlayer1.stream = hit_sounds_array[randi_range(0,2)]
			$audioPlayer1.play()
		2:
			$audioPlayer1.stream = hit_sounds_array[randi_range(0,2)]
			$audioPlayer1.play()
			await get_tree().create_timer(0.02).timeout
			$audioPlayer2.stream = hit_sounds_array[randi_range(0,2)]
			$audioPlayer2.play()
		3:
			$audioPlayer1.stream = hit_sounds_array[randi_range(0,2)]
			$audioPlayer1.play()
			await get_tree().create_timer(0.02).timeout
			$audioPlayer2.stream = hit_sounds_array[randi_range(0,2)]
			$audioPlayer2.play()
			await get_tree().create_timer(0.02).timeout
			$audioPlayer3.stream = hit_sounds_array[randi_range(0,2)]
			$audioPlayer3.play()
	await get_tree().create_timer(1.0).timeout
	queue_free()
