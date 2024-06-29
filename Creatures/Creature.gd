class_name Creature extends Object
#A Creature is any entity with up to 4 attacks

#signal for when health changes
#emits the amount it changed by as well as the new value
signal health_changed(amount, newHealth)

signal leveled_up()
signal big_boosted(amountLeft) #signal for when we big boost a stat, with the amount of boosts left emitted as well
signal stat_changed(stat:STATS,amount) #signal for when a stat changes with the type of stat and the amount it changed by

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

var pendingBigBoosts:int = 0

#moves that we earn through leveling up. 
#Unlike pendingBigBoosts, this is filled in at _ready and only gets smaller as we level up
var levelUpMoves:Array=[]

static var MAX_LEVEL = 100
const LEVELS_PER_BIG_BOOST:int = 3 #number of levels we have to level before getting a bigboost
const LEVELS_PER_NEW_MOVE:int = 5 #number of levels we have to level before getting a new move
const MAX_LEVELUP_MOVES:int = 10 #max number of moves we can learn via level up
var maxLevelUpMoves:int = 0 #non static version of the above constant, used for testing purposes when a creature doesn't have MAX_LEVEL_UP_MOVES yet
var level = 1;

enum STATS
{
	HEALTH = 0,
	ATTACK,
	SPEED
}

# "a" deals damage to "b", based on attack and defense stats. "damage" is the base damage
static func dealDamage(a,b, damage):
	if a && b:
		b.takeDamage(damage); 

static var count = 0;

func _init( sprite_path:String, maxHealth_:int,baseAttack_:int,baseSpeed_:int, name_:String, levels:int = 1, moves_:Array = [], pendingMoves_:Array = []) -> void:
	spriteFrame = SpriteLoader.getSprite(sprite_path)
	creatureName = name_;
	
	level = levels
	
	health = Stat.new(maxHealth_);
	attack = Stat.new(baseAttack_);
	speed = Stat.new(baseSpeed_);
	
	health.stat_changed.connect(func (amount,_newVal):
		stat_changed.emit(STATS.HEALTH,amount)
		)
		
	attack.stat_changed.connect(func (amount,_newVal):
		stat_changed.emit(STATS.ATTACK,amount)
		)
		
	speed.stat_changed.connect(func (amount,_newVal):
		stat_changed.emit(STATS.SPEED,amount)
		)
	
	health.resetStat(level)
	attack.resetStat(level)
	speed.resetStat(level)
	
	setMoves(moves_)
	levelUpMoves = pendingMoves_
	maxLevelUpMoves = levelUpMoves.size()

func _ready():
	setHealth(getMaxHealth())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func getLevel() -> int:
	return level

#return the amount a stat increases per level
func getPerLevelAmount(stat:STATS):
	return Stat.PER_LEVEL_AMOUNT

func levelUp() -> void:
	level += 1
	if (level%LEVELS_PER_BIG_BOOST == 0):
		pendingBigBoosts += 1
	health.addBaseStat(getPerLevelAmount(STATS.HEALTH))
	attack.addBaseStat(getPerLevelAmount(STATS.ATTACK))
	speed.addBaseStat(getPerLevelAmount(STATS.SPEED))
	
	leveled_up.emit()

func isPlayerCreature():
	return isPlayer

func getSprite() -> SpriteFrames:
	return spriteFrame

func getIsFriendly():
	return isFriendly || isPlayerCreature()

func getName():
	return creatureName;

func getPendingBigBoosts() -> int:
	return pendingBigBoosts

func getNextLevelUpMove() -> Move: #return the move at the front of pendingMoves, null if we are too low level
	if levelUpMoves.size() > 0:
		var index = min(0,int(getLevel()/(LEVELS_PER_NEW_MOVE) - (maxLevelUpMoves - levelUpMoves.size())) - 1)
		if index == 0:
			return levelUpMoves[index]
	return null
	
#remove the next move to be learned (becuase you learned it or rejected)
func popNextLevelUpMove() -> void:
	levelUpMoves.pop_front()
	
func getStatTracker(stat:STATS) -> Stat:
	match (stat):
		STATS.HEALTH:
			return health
		STATS.ATTACK:
			return attack
		STATS.SPEED:
			return speed
		_:
			push_error("getStatTracker: stat didn't match any stat! " + str(stat))
	return null
	
func getBaseStat(stat:STATS) -> int:
	var tracker = getStatTracker(stat)
	if tracker:
		return tracker.getBaseStat()
	return -1

#change the cur stat 
func setStat(stat:STATS,amount:int) -> void:
	var statTracker:Stat = getStatTracker(stat)
	if statTracker:
		statTracker.changeStat(amount)

func bigBoostStat(stat:STATS) -> void:
	#this function will apply a big boost to the given stat. Note that it does NOT check if a big boost
	#is actually available. That way you can also use as a setter function of sorts
	var tracker:Stat = getStatTracker(stat)
	if tracker:
		pendingBigBoosts = max(pendingBigBoosts - 1, 0)
		tracker.addBigBoost(1)
		big_boosted.emit(getPendingBigBoosts())

func getBaseAttack() -> int:
	return attack.getBaseStat();
	
#get how much attack we currently have
#you should probably never call this (or getSpeed()) outside of battle since attack and speed
#reset to base values outside of battle
func getAttack() -> int:
	return attack.getStat()
	
func getBaseSpeed() -> int:
	return speed.getBaseStat();

func getSpeed() -> int:
	return speed.getStat();

func getMaxHealth() -> int:
	return health.getBaseStat();

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
		
