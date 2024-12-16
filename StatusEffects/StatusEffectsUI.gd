class_name StatusEffectsUI extends GridContainer

@export var friendly:bool = true #true if on a friendly creature

var effectUI:PackedScene = preload("res://StatusEffects/SingleEffectUI.tscn")

func _ready():
	grow_horizontal = Control.GROW_DIRECTION_BEGIN if friendly else Control.GROW_DIRECTION_END
	grow_vertical = Control.GROW_DIRECTION_END

func setIsOnEnemy(val:bool) -> void:
	friendly = val
	grow_horizontal = Control.GROW_DIRECTION_BEGIN if friendly else Control.GROW_DIRECTION_END
	
func clear():
	#kill all children (fuck dem kids)
	get_children().map(func(child:Node):
		remove_child(child)
		)

#given some status effects, fully update our ui to reflect it
func update(mgr:StatusManager):
	clear()
	for key in mgr.statuses:
		addStatusEffect(mgr.statuses[key])
	

func addStatusEffect(status:StatusEffect):
	var effect = effectUI.instantiate() as SingleEffectUI
	add_child(effect)
	effect.setStatusEffect(status)
	status.stacks_changed.connect(func(_amount):
		#yeah yeah yeah it would be more efficient to just set the label when the amount of stacks changes
		#but im too lazy to write a new function just for that so.... you're cringe + L + ratio
		effect.setStatusEffect(status)
		)

func removeStatusEffect(status:StatusEffect):
	for child in get_children():
		if child.status and child.status.name == status.name:
			remove_child(child)
			break
