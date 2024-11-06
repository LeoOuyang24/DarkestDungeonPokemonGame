extends ColorRect

@onready var Message = $Label
@onready var Spoils = %Spoils
@onready var DNACounter = %"DNACounter"
@onready var EndButton = $Button


func setBattleResult(rewards:Rewards):
	Message.set_text("Survived")
	Message.set("theme_override_colors/font_color",Color.RED)
	if rewards:
		var tween = DNACounter.create_tween()
		var dna := rewards.getDNA()
		tween.tween_method(func(value:int):
			DNACounter.set_text(str(value))
			, 1, dna, dna*0.01)
			#DNACounter.set_text(str(rewards.getDNA()))
		
