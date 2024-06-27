extends ColorRect

@onready var AnimPlayer := $AnimationPlayer

signal transition_finished()

#play the animation,
#"true" if you want to play it backwards
func play(backwards:bool = false):
	if backwards:
		AnimPlayer.play_backwards("fade")
	else:
		AnimPlayer.play("fade")
	await AnimPlayer.animation_finished
	transition_finished.emit()
	pass # Replace with function body.

func _ready():

	#play()
	pass
	#play()
	
