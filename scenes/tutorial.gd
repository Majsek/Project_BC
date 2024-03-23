extends Label3D

var tutorial_ : int = 0:
	set(value):
		tutorial_ = value
		redraw()

func _ready():
	redraw()

func redraw():
	print("Tut")
	print(tutorial_)
	match tutorial_:
		0:
			self.visible = true
			text = "use joysticks to select colors"
			$Sprite3D.texture = preload("res://vr_prompts/Oculus/Oculus_Left_Stick.png")
			$Sprite3D2.texture = preload("res://vr_prompts/Oculus/Oculus_Right_Stick.png")
		1:
			text = "use triggers to shoot"
			$Sprite3D.texture = preload("res://vr_prompts/Oculus/Oculus_LT.png")
			$Sprite3D2.texture = preload("res://vr_prompts/Oculus/Oculus_RT.png")
		2:
			text = "use grab to move"
			$Sprite3D.texture = preload("res://vr_prompts/Oculus/Oculus_Left_Grab.png")
			$Sprite3D2.texture = preload("res://vr_prompts/Oculus/Oculus_Right_Grab.png")
		_:
			self.visible = false
