class_name Bosses extends Object

#sets up certain fights

static func boss1(battle:BattleManager) -> void:
	var boss := CreatureLoader.loadJSON("boss1")
	
	battle.createBattle([boss,CreatureLoader.loadJSON("minion1"),CreatureLoader.loadJSON("minion1")])
