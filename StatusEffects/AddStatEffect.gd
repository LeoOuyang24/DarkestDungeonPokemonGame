class_name AddStatEffect extends StatusEffect

#increases/decreases a stat additively. 
#this effect can be applied multiple times, each with different stacks.

static var health_up:Texture2D = preload("res://sprites/icons/heart_up_icon.png");
static var attack_up:Texture2D = preload("res://sprites/icons/attack_up_icon.png");
static var speed_up:Texture2D = preload("res://sprites/icons/speed_up_icon.png");

var stat:CreatureStats.STATS = CreatureStats.STATS.HEALTH;
#var amount:int = 0;

func _init(stat:CreatureStats.STATS):
	##self.amount = amount

	self.stat = stat
	
	var texture:Texture2D = null;
	var name = ""
	
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
	
	super(name,texture,"")

#whether or not this is a debuff is based on whether the status lowers or increases attack
func getIsDebuff():
	return getStacks() < 0

func onAdd(creature:Creature) -> void:
	super(creature)
	var statObj = creature.stats.getStatObj(stat)
	statObj.modStat(getStacks(),true,self)
	stacks_changed.connect(func(amount:int):
		statObj.modStat(getStacks(),true,self)
		)

func onRemove() -> void:
	creature.stats.getStatObj(stat).removeSource(self);

func newTurn() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
