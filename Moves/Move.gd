class_name Move extends Object
# A Move is something a Creature can do. Like Tackle in Pokemon!

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
var moveName = "move"

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

#based on the friendliness of the target and user, determine if the target is valid
static func isTargetValid(targetingCriteria:TARGETING_CRITERIA, areWeFriendly:bool, isTargetFriendly:bool):
	if targetingCriteria == TARGETING_CRITERIA.ALLIES_AND_ENEMIES:
		return true
	if areWeFriendly == isTargetFriendly:
		return targetingCriteria == TARGETING_CRITERIA.ONLY_ALLIES
	return targetingCriteria == TARGETING_CRITERIA.ONLY_ENEMIES

func getMoveName():
	return moveName

#the actual move
#user is the guy doing the move
#enemies is a (potentially empty) list of target indicies
#battlefield is a Battlefield instance that simulates the battle
func move(user:Creature, targets:Array, battlefield):
	pass;

#return a button that represents this Move
func getButton(pos):
	var button = Button.new();
	button.position = pos;
	button.text = getMoveName();
	button.size = Vector2(100,85)

	button.set("theme_override_colors/font_color",Color(1,1,1,1))

	#button.pressed.connect(self._)
	#button.add_color_override("font_color", Color("#5bd170"))

	return button;
	
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
	

	
	
	
