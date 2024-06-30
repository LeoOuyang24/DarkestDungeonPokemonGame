extends Node2D

@onready var Message = $ColorRect/Label
@onready var Spoils = $ColorRect/RewardsRect
@onready var DNACounter = Spoils.get_node("DNACounter")
@onready var EndButton = $ColorRect/Button
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setBattleResult(won:bool, rewards:Rewards):
	if won:
		Message.set_text("Survived")
		Message.set("theme_override_colors/font_color",Color.RED)
		if rewards:
			DNACounter.set_text(str(rewards.getDNA()))
		
	else:
		Message.set_text("Expended")
		Message.set("theme_override_colors/font_color",Color.BLACK)
		
