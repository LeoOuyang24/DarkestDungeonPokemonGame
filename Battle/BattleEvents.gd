class_name BattleEvents extends Object

#class handles "battle Events"
#creature-creature interactions should be done through this class rather than directly through Battlefield
#that way any thing that triggers along with certain events (storing attacks in battle history, for example)
#will trigger properly.

#doing it this way ensures that all information (attacker and defender, for example) are tracked
#the in-creature signals are more focused on creature-specific things

#this class could probably be merged with Battlefield but man battlefield is already so long

var battle:Battlefield = null


#signals for when a creature attacked another
signal attacked(attacker:Creature,target:Creature,damage:Damage,move:Move) 

func attack(attacker:Creature,target:Creature,damage:int,move:Move) -> int:
	if target and attacker:
		attacked.emit(attacker,target,Damage.new(damage,Damage.DAMAGE_TYPES.PHYSICAL),move)
		return Creature.dealDamage(attacker,target,damage)
	return 0	
	
		
#when a stat changes, source can be anything (move, status effect, etc)
signal changedStat(creature:Creature,statType:CreatureStats.STATS,amount:float,add:bool,source:Variant)
func changeStat(creature:Creature,statType:CreatureStats.STATS,amount:float,add:bool,source:Variant) -> void:
	if creature:
		creature.stats.getStatObj(statType).modStat(amount,add,source)
		
#unlike attacking, the source of healing could be from a move or a status effect or anything else
signal healed(healer:Creature,receiver:Creature,amount:int,source:Variant)

func heal(healer:Creature,target:Creature,amount:int,source:Variant):
	if healer and target:
		target.addHealth(amount)
	healed.emit(healer,target,amount,source)
		
#signal and function for when a creature swaps position with another 
signal swapped(swapper:Creature,swappee:Creature, source:Variant)
func swap(swapper:Creature,swappee:Creature, source:Variant):
	if battle:
		battle.swapCreatures(swapper,swappee)
		swapped.emit(swapper,swappee,source)
	
signal appliedStatus(applier:Creature,target:Creature,effect:StatusEffect,stacks:int)
func applyStatus(applier:Creature,target:Creature,effect:StatusEffect,stacks:int):
	target.statuses.addStatus(effect,stacks)
	appliedStatus.emit(applier,target,effect,stacks)
	
signal removedStatus(remover:Creature,target:Creature,effect:StringName)
func removeStatus(remover:Creature,target:Creature,effect:StringName):
	var status = target.statuses.getStatus(effect)
	if status:
		target.statuses.removeStatus(status);
		removedStatus.emit(remover,target,effect)
	
