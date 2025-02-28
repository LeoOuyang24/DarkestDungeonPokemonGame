class_name BansheeHealth extends Stat

#Health STAT object for the Banshee
#whenever this creature takes damage, it instead deals damage to all allies

var owner:Creature = null #owning creature

func _init(owner:Creature) -> void:
	super(1)
	self.owner = owner
	

#do nothing, can not modify base stat!
#doesn't affect modStat either since our HP is always 1, so the amount we change by is always 0
func modBaseStat(amount:float,add:bool = true, source:Variant = self) -> void: 
	return 
	
func modStat(amount:float, add:bool = true, source:Variant = self) -> void:
	if (amount < 0 and add): #only do something if we are losing health. Don't gotta worry about mult effects since we only have 1 hp
		if GameState.getBattle() and owner:
			var allies = GameState.getBattle().getAllies(owner.getIsFriendly(),false)
			for ally:Creature in allies:
				if ally is not Banshee:
					ally.stats.getStatObj(CreatureStats.STATS.HEALTH).modStat(amount,true,self);
