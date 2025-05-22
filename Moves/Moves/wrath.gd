class_name Wrath extends GenericAttack

# Called when the node enters the scene tree for the first time.
func _init():
	super("Wrath",0,1,"Deal .5x damage to the highest health enemy. Hits 3 times.")

func getMult():
	return 0.5

func getPreselectedTargets(user:Creature,battle:Battlefield):
	var possible := battle.getEnemies(user.getIsFriendly(),false,true);
	if possible.size() > 0 and possible[0]:
		var target = [possible.reduce(func(big:int,c:int):
				var creature:= battle.getCreature(c)
				return big if  !c or \
				creature.stats.getCurStat(CreatureStats.STATS.HEALTH) < battle.getCreature(big).stats.getCurStat(CreatureStats.STATS.HEALTH)\
				else c
				,possible[0])]	
		return target
	return []
				
	
func fullMove(record:Move.MoveRecord,battle:BattleManager):
	for i in range(3):
		record.targets = []
		await super(record,battle)

	
	
