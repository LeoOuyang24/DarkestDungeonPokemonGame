class_name AddStatEffect extends StatusEffect

#increases/decreases a stat additively. 

static var health_up:Texture2D = preload("res://sprites/icons/heart_up_icon.png");
static var attack_up:Texture2D = preload("res://sprites/icons/attack_up_icon.png");
static var speed_up:Texture2D = preload("res://sprites/icons/speed_up_icon.png");

var stat:CreatureStats.STATS = CreatureStats.STATS.HEALTH;

var turns:int = -1; #turns this effect lasts. If negative, lasts forever

func _init(stat:CreatureStats.STATS,turns:int=-1,effectName:String = ""):
	##self.amount = amount

	self.stat = stat
	self.turns = turns;
	
	var texture:Texture2D = null;
	var name = ""
	if effectName == "":
		match stat:
			CreatureStats.STATS.HEALTH:
				texture = health_up
				name = "Health"
			CreatureStats.STATS.ATTACK:
				texture = attack_up
				name = "Attack"
			CreatureStats.STATS.SPEED:
				texture = speed_up
				name = "Speed"
	else:
		name = effectName
	super(name,texture,"")

func getTooltip() -> String:
	return "Raises " + name + " by " + str(getStacks());

#whether or not this is a debuff is based on whether the status lowers or increases attack
func getIsDebuff():
	return getStacks() < 0

func onAdd(creature:Creature) -> void:
	super(creature)
	var statObj = creature.stats.getStatObj(stat)
	statObj.modStat(getStacks(),true,self)
	stacks_changed.connect(func(amount:int):
		statObj.modStat(getStacks(),true,self) #update stats based on new stacks
		)

func onRemove() -> void:
	creature.stats.getStatObj(stat).removeSource(self);

func newTurn() -> void:
	if turns > 0:
		turns -= 1;
	if turns == 0:
		remove_this.emit()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
