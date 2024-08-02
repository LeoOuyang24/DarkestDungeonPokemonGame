class_name Move extends Object
# A Move is something a Creature can do. Like Tackle in Pokemon!

#emitted when the move is used
signal move_used()
#emitted when the cooldown changes
signal cooldown_changed(amount:int, newCD:int)

class MoveRecord extends Object:
	#represents the info associated with the use of a move

	var move:Move = null #the move
	var user:Creature = null #user of the move
	var targets:Array = [] #indicies of creatures that are the target

	func _init( user:Creature, move:Move, targets:Array):
		self.move = move;
		self.user = user;
		self.targets = targets;

#the name of the move
var moveName:StringName = "move"

#summary of what the move does
var summary:String = ""

#number of turns to wait between usage
var baseCooldown:int = 1

#current cooldown, number of turns left to wait
var cooldown:int = 0

#number of targets
#not necessarily the number of targets that actually get hit but the number of targets
#that the player has to manually choose
var manualTargets:int = 0;

#true if this move affects other creatures besides the user
#useful for calculating if a move's lack of targets is due to it not needing targets
#or because there are no valid targets
var requiresTargets:bool = true;

#what can we target? Only allies? Only enemies?
#this only applies to manually targeting
enum TARGETING_CRITERIA
{
	ONLY_ALLIES,
	ONLY_ENEMIES,
	ALLIES_AND_ENEMIES
}

var targetingCriteria:TARGETING_CRITERIA = TARGETING_CRITERIA.ONLY_ENEMIES

func _init(moveName:String,manualTargets:int = 0,baseCooldown:int = 1):
	self.moveName = moveName
	self.manualTargets = manualTargets
	self.baseCooldown = baseCooldown

#based on the friendliness of the target and user, determine if the target is valid
static func isTargetValid(targetingCriteria:TARGETING_CRITERIA, areWeFriendly:bool, isTargetFriendly:bool):
	if targetingCriteria == TARGETING_CRITERIA.ALLIES_AND_ENEMIES:
		return true
	if areWeFriendly == isTargetFriendly:
		return targetingCriteria == TARGETING_CRITERIA.ONLY_ALLIES
	return targetingCriteria == TARGETING_CRITERIA.ONLY_ENEMIES

func getMoveName():
	return moveName

#returns whether this move is usable
func isUsable() -> bool:
	return cooldown <= 1

#get amount of cooldown left to wait
func getRemainingCD() -> int: 
	return cooldown

func setCooldown(amount:int) -> void:
	var old = cooldown
	cooldown = max(0,amount)
	cooldown_changed.emit(amount - old,cooldown)

#decrement the cooldown
func decRemainingCD(amount:int = 1) -> void:
	setCooldown(cooldown - amount)

#do a move
#anything that needs to be done that is universal to all moves (ie, setting the cooldown) is done here
func doMove(user:Creature, targets:Array, battlefield):
	move(user,targets,battlefield)
	
	setCooldown(baseCooldown)
	move_used.emit()
	
#the actual move
#user is the guy doing the move
#enemies is a (potentially empty) list of target indicies
#battlefield is a Battlefield instance that simulates the battle
func move(user:Creature, targets:Array, battlefield:Battlefield) -> void:
	pass
	
func getNumOfTargets():
	return manualTargets
	
func getTargetingCriteria():
	return targetingCriteria
	
#some moves always hit the same targets. (ie, always hitting the front 2 targets)
#this returns the an array of the indicies creatures we always want to hit
#passing in the indicies gives us a bit of flexiblity. We can hit the front two targets OR
#we can hit the front two POSITIONS, sometimes potentially hitting only 1 or 0 targets
#it also means with moves that manually target, we can potentially miss if a creature moves out of the targeted position
func getPreselectedTargets(user:Creature, battle:Battlefield):	
	var preselected = [];
	return preselected;
	
func runAnimation(user:Creature, targets:Array,battleUI:BattleUI,battlefield:Battlefield) -> void:
	pass
	
func getPostMessage(user:Creature, targets:Array) -> String:
	return ""
	

	
	
	
