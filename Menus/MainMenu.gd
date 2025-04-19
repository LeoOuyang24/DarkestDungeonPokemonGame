extends Control

var GameScene := preload("res://Game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
#
func _on_button_pressed():
	self.visible = false
	get_tree().change_scene_to_packed(GameScene)


func _on_tutorial_toggled(toggled_on: bool) -> void:
	GameState.isTutorial = toggled_on
	pass # Replace with function body.
