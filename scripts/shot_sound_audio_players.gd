extends Node3D

var shot_sounds_array : Array = [
	preload("res://audio/shot_sounds/shot_sound_F5_wav.tres"),
	preload("res://audio/shot_sounds/shot_sound_G5_wav.tres"),
	preload("res://audio/shot_sounds/shot_sound_H5_wav.tres")
	]
var counter_ = 0:
	set(value):
		counter_ = value
		if counter_ >= 3:
			counter_ = 0
			
func play_shot_sound():
	match randi_range(0,2):
		0:
			$audioPlayer1.stream = shot_sounds_array[randi_range(0,2)]
			$audioPlayer1.play()
		1:
			$audioPlayer2.stream = shot_sounds_array[randi_range(0,2)]
			$audioPlayer2.play()
		2:
			$audioPlayer3.stream = shot_sounds_array[randi_range(0,2)]
			$audioPlayer3.play()
