class_name SingleEffectUI extends TextureRect

#name of the status effect
var statusName = ""
@onready var label:Label = $Label

func setStatusEffect(status:StatusEffect) -> void:
	if status:
		statusName = status.name
		texture = status.icon
		label.set_text(str(status.getStacks()))
		
