class_name SingleEffectUI extends TextureRect

#name of the status effect
var status:StatusEffect = null
@onready var label:Label = %Label
var popup := load("res://UI/OnHoverUI.tscn");

#func _ready():
	#setStatusEffect(Sleep.new())

func setStatusEffect(status:StatusEffect) -> void:
	if status:
		self.status = status;
		texture = status.icon
		if !label: #sometimes we aren't ready yet, so label is null. Don't ask me, I don't get why either
			await ready
		label.set_text(str(status.getStacks()))

	
func _make_custom_tooltip(for_text):
	if self.status:
		var tooltip:Control = popup.instantiate()
		tooltip.setName(status.name,Color.RED)
		tooltip.setMessage(status.getTooltip())
		tooltip.setIcon(status.icon);
		return tooltip;
	return null
