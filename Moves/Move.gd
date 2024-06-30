class_name Move extends Object
# A Move is something a Creature can do. Like Tackle in Pokemon!

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
func move(user, enemies, battlefield):
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
#this returns the an array of the creatures we always want to hit
func getPreselectedTargets(user:Creature, battle:Battlefield):	
	var preselected = [];
	return preselected;
#creates a sequence that does the actual move
func doMoveSequence(user,move,targets):
	return [SequenceUnit.createSequenceUnit(func (d,b,u) : #do the move
		move.move(user,targets,b)
		return SequenceUnit.RETURN_VALS.DONE
	)]
#constructs a whole Sequence (list of SequenceUnits) that describe a move
func createMoveSequence(user, move,targetIndicies):
	var sequence = []
	
	var targets = targetIndicies

	sequence.push_back(SequenceUnit.createSequenceUnit(func (d,b,u):
		targets = targetIndicies
		var preselect = move.getPreselectedTargets(user,b)

		targets.append_array(preselect) #add preselected targets, converting all relative indices to absolute indices
		return SequenceUnit.RETURN_VALS.DONE
		))
	
	sequence.push_back( SequenceUnit.createTextUnit(user.getName() + " used " + move.getMoveName() + "!")); #say whos doing the  move


	sequence.push_back(SequenceUnit.createSequenceUnit(func (d,b,u):
		if (manualTargets == 0 && targets.size() == 0 && requiresTargets) || (manualTargets > 0 && targets.size() > 0 && !targets.reduce(func (accum, index):
			var target = b.getCreature(index);
			return accum || (target && target.isAlive())
			,false)):
				return SequenceUnit.RETURN_VALS.TERMINATE
		return SequenceUnit.RETURN_VALS.DONE	
		))

	sequence.append_array(moveAnimationSequence(user,move,targets))
	
	sequence.append_array(doMoveSequence(user,move,targets))
	
	sequence.append_array(postMoveSequence(user,move,targets))

	return sequence;

#sequence that renders an animation
#usually this is just the animation of the move but it could be other things, like moving the user forward as part of the tackle animation
func moveAnimationSequence(user, move, targets):
	return basicMoveAnimationSequence(user,move,targets)
#sequence to call after a move has done
#this is usually used to print things like "Its super effective!"
func postMoveSequence(user, move, targets):
	return [];
	
#overlap is tru if you want the creatures to overlap
static func moveTowards(index, targetIndex, ui:BattleUI, overlap:bool = false):
	var slot = ui.getCreatureSlot(index)
	if slot:
		var startPos = ui.getCreatureGlobalPos(index)
		var targetPos = ui.getCreatureGlobalPos(targetIndex)
		var curPos = slot.get_global_position()
		if (overlap && (curPos - targetPos).length() < 1) || (!overlap && slot.get_global_rect().intersects(ui.getCreatureSlotByIndex(targetIndex).get_global_rect(),true)):
			return SequenceUnit.RETURN_VALS.DONE;
		else:
			slot.global_position += .1*(targetPos - startPos)
			#slot.setTransform(slot.getTransform().translated(.1*(targetPos - startPos)))
	else:
		return SequenceUnit.RETURN_VALS.DONE
	return SequenceUnit.RETURN_VALS.NOT_DONE
	
#animation that moves the user forward up to the first target
func basicMoveAnimationSequence( user, move, targets, spriteFrame = SpriteLoader.getSprite("spritesheets/moves/" + move.getMoveName())):
	var sequence = []
	sequence.append(SequenceUnit.createSequenceUnit(func (d,b,u):
			return Move.moveTowards(b.getCreatureIndex(user),targets[0],u)))

	sequence.append(SequenceUnit.createSequenceUnit(func (d,b,u):
		u.setBattleSprite(spriteFrame,u.getCreatureSlot(targets[0]).get_global_rect().get_center())
		if !b.isCreatureFriendly(user):
			u.BattleSprite.flip_h = true
		for i in targets:
			var target = u.getCreatureSlotByIndex(i);
			#target.Sprite.changeAnimation("hurt"); 
			target.Sprite.play("hurt")
		return SequenceUnit.RETURN_VALS.DONE
		))

	sequence.append(SequenceUnit.createSequenceUnit(func (d,b,u):
		if u.BattleSprite.getFramesProgress() == 1:
			#u.resetCreatureSlotPos(user)
			u.stopBattleSprite()
			u.BattleSprite.flip_h = false
			for i in targets:
				var target = u.getCreatureSlot(i);
				#target.Sprite.changeAnimation("default"); 
				target.Sprite.play("default")
			return SequenceUnit.RETURN_VALS.DONE

		return SequenceUnit.RETURN_VALS.NOT_DONE;	
		))
	return sequence
	
#visual effect for when stats change
static func createBoostStatsSequence(creatures:Array, goingUp:bool):
	var sequence = []
	var closure = [false] #not super sure how else to do this.
	#I need the tween to end the sequence. So we store a flag in an array which 
	#(can't use primitives because they are not captured by reference in lambdas)
	#and then set it when the tweens are finished.
	
	sequence.push_back(SequenceUnit.createSequenceUnit(func(d,b,u):
		for creature in creatures:
			var slot = u.getCreatureSlot(creature)
			u.setBattleSprite(SpriteLoader.getSprite("effects/upArrow" if goingUp else "effects/downArrow"),slot.get_global_position())
			var tween = slot.getTween()
			tween.tween_property(u.BattleSprite,"modulate",Color(0,0,0,-1),1)
			tween.tween_callback(func():
				u.BattleSprite.modulate = Color.WHITE;
				u.stopBattleSprite();
				closure[0] = true
				)	
		return SequenceUnit.RETURN_VALS.DONE
		))
	sequence.push_back(SequenceUnit.createSequenceUnit(func(d,b,u):
		return SequenceUnit.RETURN_VALS.DONE if closure[0] else SequenceUnit.RETURN_VALS.NOT_DONE
		))
	return sequence
	
static func createSwapPosSequence(arr:Array):
	
	pass
	
	
