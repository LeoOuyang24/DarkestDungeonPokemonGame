extends Control

@onready var Message = %Label
@onready var Spoils = %Spoils
@onready var DNACounter = %"DNACounter"
@onready var EndButton = %Button

var movebutton := preload("res://Battle/UI/MoveButton.tscn")

func setBattleResult(rewards:Rewards):
	Message.set_text("Survived")
	Message.set("theme_override_colors/font_color",Color.RED)
	if rewards:
		var tween = DNACounter.create_tween()
		var dna := rewards.getDNA()
		DNACounter.set_text(str(dna))
		for i in rewards.moves:
			if i:
				var butt:MoveButton = movebutton.instantiate()
				butt.setMove(i)
				%Rewards.add_child(butt)
			#DNACounter.set_text(str(rewards.getDNA()))
		
