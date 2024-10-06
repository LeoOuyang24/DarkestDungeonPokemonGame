class_name Lure extends Move


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init():
	moveName = "Lure"
	summary = "Bring the rearmost enemy to the front, pushing all other enemies back by one spot."

#our targets are all non-null enemies
func getPreselectedTargets(user:Creature, battle:Battlefield):	
	var allEnemies = battle.getEnemies(user.getIsFriendly());
	var targets = []
	for i in range(allEnemies.size()):
		if allEnemies[i]:
			targets.push_back(battle.relPosToAbs(i,!user.getIsFriendly()))
	return targets
		
		
#the way lure works requires us to process our targets in a very specific way.
#this function makes it so that when we do the processing first in "runAnimation" and then in "move"
#the code is DRY. We could bypass this by simply baking the move funtionality into the "runAnimation"
#but for now I want to keep move animations and the acutal move function contained in their own functions
func processTargets(enemies:Array, battlefield:Battlefield,lambda:Callable) -> void:
	var backMost = enemies[-1] #index of the rear-most enemy
	var frontMost = enemies[0] #index of the front-most enemy

	var loop = func (i): #basically converts an creature slot index to an index within the range of "frontMost" - "backMost"
				return (i - frontMost)%(backMost - frontMost + 1) + frontMost
	var curIndex = backMost

	while battlefield.getCreature(curIndex):#loop until an enemy moves into an empty space
		var nextIndex = loop.call(curIndex+1)
		lambda.call(curIndex,nextIndex)

		if nextIndex == backMost: #this occurs if we have gone through all creatures and none of them were null
			break
		else:
			curIndex = nextIndex	
	
#visually swap the creatures around
func runAnimation(user:Creature,enemies:Array,UI:BattleUI,battlefield:Battlefield):
	#tracks the last tween made so we can await it
	#by making it an object/hash table, the variable can be modified by the function we pass into "processTargets"
	var lastTween = {} 
	var time = 0.25
	processTargets(enemies,battlefield,func(curIndex,nextIndex):

		var slot = UI.getCreatureSlot(curIndex)
		var nextSlot = UI.getCreatureSlot(nextIndex)
		#var tween = slot.getTween().tween_property(slot,"global_position",nextSlot.global_position,time)
		var tween = slot.getTween().tween_method(func(val):
			slot.global_position.x = val;
			,slot.global_position.x,nextSlot.global_position.x + nextSlot.size.x/2 - slot.size.x/2,time)
		lastTween.tween = tween
		)
	await lastTween.tween.finished
	#await GameState.get_tree().create_timer(100).timeout
	
#actually swap the creatures around
func move(user:Creature,enemies:Array,battle:Battlefield):
	var reserve:Dictionary = {}
	reserve.reserve = battle.getCreature(enemies[-1])
	processTargets(enemies,battle,func(curIndex,nextIndex):
		if reserve.reserve:
			var temp:Creature = battle.getCreature(nextIndex)
			battle.moveCreature(reserve.reserve,nextIndex)
			reserve.reserve = temp

		)

	#this is only true if there is a gap somewhere between the enemies (a null slot between the backmost and frontmost enemies)
	if enemies.size() < enemies[-1] - enemies[0] + 1: 
		battle.moveCreature(null,enemies[-1])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
