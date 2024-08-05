class_name Sleep extends StatusEffect



func _init():
	super("Sleep",load("res://sprites/statuses/sleep.png"),"")

func onAdd(creature:Creature) -> void:
	creature.health_changed.connect(func(amount,_new):
		if amount < 0:
			
		)
