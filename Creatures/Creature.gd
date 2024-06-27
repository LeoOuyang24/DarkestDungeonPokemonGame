class_name Creature extends Object
#A Creature is any entity with up to 4 attacks

#signal for when health changes
#emits the amount it changed by as well as the new value
signal health_changed(amount, newHealth)

const maxMoves = 4;
var moves = []

var health:Stat = null
var attack:Stat = null
var speed:Stat = null

#is the player character
var isPlayer = false

var isFriendly = false

#whether this creature needs to be rendered slightly higher becuase it flies
var flying:bool = false

var spriteFrame:SpriteFrames = null;

var creatureName = "Creature"


var level = 1;

# "a" deals damage to "b", based on attack and defense stats. "damage" is the base damage
static func dealDamage(a,b, damage):
	if a && b:
		b.takeDamage(damage); 

static var count = 0;

func _init( sprite_path:String, maxHealth_:int,baseAttack_:int,baseSpeed_:int, name_:String, levels:int = 1, moves_:Array = []) -> void:
	spriteFrame = SpriteLoader.getSprite(sprite_path)
	creatureName = name_;
	
	level = levels
	
	health = Stat.new(maxHealth_);
	attack = Stat.new(baseAttack_);
	speed = Stat.new(baseSpeed_);
	
	health.resetStat(level)
	attack.resetStat(level)
	speed.resetStat(level)
	
	setMoves(moves_)

func _ready():
	setHealth(getMaxHealth())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func getLevel() -> int:
	return level

#get the hypothetical stats at a given level
func getStatsAtLevel(level:int = getLevel()) -> Dictionary:
	var stats = {				
			"health":health.getBaseStat(level),
			"attack":attack.getBaseStat(level),
			"speed":speed.getBaseStat(level)}
	return stats
func levelUp() -> void:
	level += 1

func isPlayerCreature():
	return isPlayer

func getIsFriendly():
	return isFriendly || isPlayerCreature()

func getName():
	return creatureName;


func getBaseAttack() -> int:
	return attack.getBaseStat(level);
	
#get how much attack we currently have
#you should probably never call this (or getSpeed()) outside of battle since attack and speed
#reset to base values outside of battle
func getAttack() -> int:
	return attack.getStat()
	
func getBaseSpeed() -> int:
	return speed.getBaseStat(level);

func getSpeed() -> int:
	return speed.getStat();

func getMaxHealth() -> int:
	return health.getBaseStat(level);

func getHealth() -> int:
	return health.getStat();
	
func setHealth(amount:int) -> void:
	health.changeStat(min(amount,getMaxHealth())) #ensure our health never goes above max


func isAlive():
	return getHealth() > 0

func setMoves(attacks_):
	moves = attacks_.slice(0,min(maxMoves,len(attacks_)),1,true); #deep copy the first 4 attacks, or fewer if fewer were provided

#used for dealing damage. Do not use as setter for modifying health. 
func takeDamage(damage):

	damage = max(damage,1); #ensure damage is at least 1
	setHealth(getHealth() - damage)
	health_changed.emit(damage,getHealth())
	
#use the move
func useMove(move,targets):
	move.move(self,targets)
	
func getMove(index):
	if index < 0 || index >= moves.size():
		return null
	return moves[index];
func getRandomMove():
	return moves[randi()%moves.size()]
			
#given a creature, its allies, and its targets,
#run the AI for the creature
#return the move it would use
static func AI(user,allies,enemies) -> MoveRecord:
	if len(user.moves) > 0 and len(enemies) > 0:
		var move = user.getRandomMove()
		var targets = []
		var targetingCriteria = move.getTargetingCriteria()
		for i in move.getNumOfTargets():
			var targetArray = null
			if targetingCriteria == Move.TARGETING_CRITERIA.ONLY_ENEMIES:
				targetArray = enemies
			elif targetingCriteria == Move.TARGETING_CRITERIA.ONLY_ALLIES:
				targetArray = allies
			elif targetingCriteria == Move.TARGETING_CRITERIA.ALLIES_AND_ENEMIES:
				targetArray = allies + enemies
			var chosen = -1
			while (chosen == -1 || targetArray[chosen] == null || targets.find(chosen) != -1) && targets.size()< targetArray.size():
				chosen = randi()%targetArray.size()
			targets.push_back(chosen)
		return MoveRecord.new(user,move,targets)
	return null
		#user.attacks[randi()%len(user.attacks)].move(user,[targets[0]])
		
