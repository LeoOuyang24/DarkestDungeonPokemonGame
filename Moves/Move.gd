class_name Move extends Object
# A Move is something a Creature can do. Like Tackle in Pokemon!

#emitted when the move is used
signal move_used()
#emitted when the cooldown changes
signal cooldown_changed(amount:int, newCD:int)

class MoveRecord extends Object:
	#represents the info associated with the use of a move

	var move:Move= null #the move
	var user:Creature = null #user of the move
	var targets:Array[int] = [] #indicies of creatures that are the target

	func _init( user:Creature = null, move:Move = null, targets:Array[int] = []):
		self.move = move;
		self.user = user;
		self.targets = targets;
		
	func copy() -> MoveRecord:
		return MoveRecord.new(self.user,self.move,self.targets)
		
	func _to_string() -> String:
		return "{ " + str(user) + ", " + str(move)+", "+ str(targets)+ "}"

#the name of the move
var moveName:StringName = "move"

#summary of what the move does
var summary:String = ""

#move icon. By default it is the attack icon
var icon:Texture2D = load("res://sprites/icons/claw_icon.png")

#number of turns to wait between usage
var baseCooldown:int = 0

#number of targets
#not necessarily the number of targets that actually get hit but the number of targets
#that the player has to manually choose
var manualTargets:int = 0;

#move slot we belong to
var slot:MoveSlot = null

#what can we target? Only allies? Only enemies?
#this only applies to manually targeting
enum TARGETING_CRITERIA
{
	OTHER_ALLIES, #allies, not including itself
	ONLY_ALLIES,
	ONLY_ENEMIES,
	ALL_OTHERS, #allies and enemies, but not itself
	ALL
}

var targetingCriteria:TARGETING_CRITERIA = TARGETING_CRITERIA.ONLY_ENEMIES

func _to_string() -> String:
	return getMoveName();

func _init(moveName:String,manualTargets:int = 0,baseCooldown:int = 1):
	self.moveName = moveName
	self.manualTargets = manualTargets
	self.baseCooldown = baseCooldown

#based on the friendliness of the target and user, determine if the target is valid
static func isTargetValid(targetingCriteria:TARGETING_CRITERIA, user:Creature, target:Creature):
	if user and target:
		if targetingCriteria == TARGETING_CRITERIA.ALL:
			return true	
		elif targetingCriteria == TARGETING_CRITERIA.ALL_OTHERS:
			return user != target
		if user.getIsFriendly() == target.getIsFriendly():
			return user != target if targetingCriteria == TARGETING_CRITERIA.OTHER_ALLIES else targetingCriteria == TARGETING_CRITERIA.ONLY_ALLIES
		return targetingCriteria == TARGETING_CRITERIA.ONLY_ENEMIES
	else:
		return false


func getMoveName():
	return moveName


#return an array of things to format the summary string with
func getModifiers(user:Creature) -> Array:
	return []


	move_used.emit()
	
#the actual move
#user is the guy doing the move
#enemies is a (potentially empty) list of target indicies
#battlefield is a Battlefield instance that simulates the battle
#return cooldown
func move(user:Creature, targets:Array, battlefield:Battlefield) -> int:
	return baseCooldown
	
func getNumOfTargets():
	return manualTargets
	
func getTargetingCriteria():
	return targetingCriteria
	
#some moves always hit the same targets. (ie, always hitting the front 2 targets)
#this returns the an array of the indicies creatures we always want to hit
#passing in the indicies gives us a bit of flexiblity. We can hit the front two targets OR
#we can hit the front two POSITIONS, sometimes potentially hitting only 1 or 0 targets
#it also means with moves that manually target, we can potentially miss if a creature moves out of the targeted position

#the reason we do this instead of just calculating the targets in move() is because runAnimation also needs targets.
#this way we abstract it to just one function.
#separating it also makes it so we can improve the AI later to make decisions based on how many creatures a move targets
func getPreselectedTargets(user:Creature, battle:Battlefield) -> Array[int]:	
	return []
	
func runAnimation(user:Creature, targets:Array, UI:BattleUI,battlefield:Battlefield) -> void:
	await MoveAnimations.genericAttackAnimation(user,targets,UI,self)
	

	
	
	
