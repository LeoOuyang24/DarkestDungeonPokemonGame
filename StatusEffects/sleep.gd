class_name Sleep extends StatusEffect



func _init():
	super("Sleep",load("res://sprites/statuses/sleep.png"),"")

func onAdd(creature:Creature) -> void:
	creature.stats.stat_changed.connect(func(stat:CreatureStats.STATS,amount:int):
		if stat == CreatureStats.STATS.HEALTH && amount < 0:
			setStacks(0);
		)
