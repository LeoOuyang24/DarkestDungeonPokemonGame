class_name Creature extends Object
#A Creature is any entity with up to 4 attacks


const maxMoves = 4;
var moves = []

var baseMaxHealth = 1;
var baseDefense = 1; #by default, we set defense to 1, so we avoid divide by 0 errors in the dealDamage function
var baseAttack = 1;



#REFACTOR: Need a getter/setter. Probalby shoudl make a Stat class unifying the base state, current stat, and the stage boosts
var attackStages = 0; #increased stat boost stages
var defenseStages = 0; 


var spriteFrame:SpriteFrames = null;

var creatureName = "Creature"

var health:int = 0;

var level = 1;
static var levelAmount = .04; #the amount our stats increase by per level

# "a" deals damage to "b", based on attack and defense stats. "damage" is the base damage
static func dealDamage(a,b, damage):
	if a && b:
		b.takeDamage((a.getAttack()/b.getDefense())*damage); 

static func create( sprite_path:String, maxHealth_:int, name_:String):
	var creature = Creature.new();
	creature.spriteFrame = SpriteLoader.getSprite(sprite_path)
	creature.creatureName = name_;
	creature.baseMaxHealth = maxHealth_;
	creature.health = maxHealth_;
	return creature;	

func _ready():
	setHealth(getMaxHealth())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func getName():
	return creatureName;

#calculate how much defense we have
func getDefense():
	return (1 + level*levelAmount)*baseDefense;

#calculate how much attack we have
func getAttack():
	return (1 + level*levelAmount + attackStages*1.5)*baseAttack;

var speed = 10;
func getSpeed():
	return speed;

#setter for health
func setHealth(health_):
	health = health_
	
func getMaxHealth():
	return (1+ (level-1)*levelAmount)*baseMaxHealth;

func getHealth():
	return health;

func isAlive():
	return getHealth() > 0

func setMoves(attacks_):
	moves = attacks_.slice(0,min(maxMoves,len(attacks_)),1,true); #deep copy the first 4 attacks, or fewer if fewer were provided
#used for dealing damage. Do not use as setter for modifying health. 
func takeDamage(damage):
	damage = max(damage,0); #ensure damage is not negative
	setHealth(max(health - damage,0)) 
		
	
#use the move
func useMove(move,targets):
	move.move(self,targets)
	
func getMove(index):
	return moves[index];
func getRandomMove():
	return moves[randi()%moves.size()]
			
#given a creature, its allies, and its targets,
#run the AI for the creature
#return the move it would use
static func AI(user,allies, targets) -> MoveRecord:
	if len(user.moves) > 0 and len(targets) > 0:
		return MoveRecord.new(user,[targets[0]],user.getRandomMove())
	return null
		#user.attacks[randi()%len(user.attacks)].move(user,[targets[0]])
		
