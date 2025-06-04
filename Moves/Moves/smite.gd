class_name Smite extends GenericAttack

# Called when the node enters the scene tree for the first time.
func _init():
	super("Smite",0,1,"Deal .35x damage to 3 random targets")

func getMult():
	return 0.35
	
func getPreselectedTargets(user:Creature,battle:Battlefield) -> Array[int]:
	var possible := battle.getEnemies(user.getIsFriendly(),false,true);
	var targets:Array[int] = []
	for i in range(3):
		targets.push_back(possible[randi()%possible.size()])
	return targets	
	
func fullMove(record:Move.MoveRecord,battle:BattleManager):
	if battle and battle.BattleSim and record and record.user:
		record.targets = getPreselectedTargets(record.user,battle.BattleSim)
		for i in record.targets:
			await record.move.runAnimation(record.user,[i],battle.UI,battle.BattleSim)
			record.move.move(record.user,[i],battle.BattleSim)	
	
	
	
	
