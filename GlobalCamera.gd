class_name GlobalCamera extends Camera2D

var rng = RandomNumberGenerator.new()
var shakeStrength := 30.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func shakePerFrame(time:float):
	set_offset(Vector2(rng.randf_range(-shakeStrength,shakeStrength),rng.randf_range(-shakeStrength,shakeStrength)));

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_S:
			shake()

func shake():
	var tween := create_tween()
	tween.tween_method(shakePerFrame,0,1,.1)
	tween.tween_callback(func():
		offset = Vector2(0,0)
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
