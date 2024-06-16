class_name Lure extends Move


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init():
	moveName = "Lure"

func moveAnimationSequence(user, move, targets):
	pass

func doMoveSequence(user, move, targets):
	var arr = []
	var stuff = {}
	arr.push_back(SequenceUnit.createSequenceUnit(func (d,b,u):
		stuff.enemies = b.getEnemies(user.getIsFriendly())
		for i in range(stuff.enemies.size()-1,-1,-1):
			if stuff.enemies[i]:
				stuff.backMost = i
				break
		for i in range(stuff.enemies.size()):
			if stuff.enemies[i]:
				stuff.frontMost = i
				break
		return SequenceUnit.RETURN_VALS.DONE))
		
	arr.push_back(SequenceUnit.createSequenceUnit(func (d,b,u):
				var curIndex = stuff.backMost
				var loop = func (i): #idk how to explain this lol. It basically lets us loop through all the enemies
					return i%(stuff.backMost - stuff.frontMost + 1) + stuff.frontMost
				var weDone = false
				while stuff.enemies[loop.call(curIndex)]:#loop until an enemy moves into an empty space
					var absIndex = b.relPosToAbs(loop.call(curIndex),!user.getIsFriendly())
					var nextAbs = b.relPosToAbs(loop.call(curIndex+1),!user.getIsFriendly())
					var returnVal = Move.moveTowards(absIndex,nextAbs,u,true)
					if (returnVal == SequenceUnit.RETURN_VALS.DONE): #if done with moving animation
						b.swapCreature(absIndex,b.relPosToAbs(stuff.backMost,!user.getIsFriendly()))
						weDone = true
					curIndex += 1
					if (loop.call(curIndex) == stuff.backMost):
						break
				#print(stuff.backMost," ", loop.call(curIndex + 1))
				if (weDone && stuff.backMost > loop.call(curIndex)): #if done with moving animation
					b.swapCreature(b.relPosToAbs(stuff.backMost,!user.getIsFriendly()),b.relPosToAbs(loop.call(curIndex ),!user.getIsFriendly()))
				return SequenceUnit.RETURN_VALS.DONE if weDone else SequenceUnit.RETURN_VALS.NOT_DONE))			
	return arr
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
