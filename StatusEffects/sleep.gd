class_name Sleep extends StatusEffect



func _init():
	super("Sleep",load("res://sprites/statuses/sleep.png"),"Creature is unable to act until status ends or after taking damage.")

func onAdd(creature:Creature) -> void:
	super(creature)
	if creature:
		creature.stats.stat_changed.connect(func(stat:CreatureStats.STATS,amount:int):
			if stat == CreatureStats.STATS.HEALTH && amount < 0:
				setStacks(0);
			)
		creature.addActive(1)
	
func onRemove() -> void:
	if self.creature:
		creature.addActive(-1)


var anime := preload("res://sprites/effects/animations/sleep_status_anime.tres")

func onAddUI(control:Control) -> void:
	var effect = AnimeEffect.createEffect(anime,!creature.getIsFriendly())
	control.add_child(effect)
	effect.position = Vector2(control.size.x,-control.size.y/2)

	
