class_name Move extends Object
# A Move is something a Creature can do. Like Tackle in Pokemon!

#the name of the move
var moveName = "move"

func getMoveName():
	return moveName

#the actual move
#ally is the guy doing the move
#enemies is a list (potentially empty) of targets
func move(ally, enemies):
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
	
#constructs a whole Sequence (list of SequenceUnits) that describe a move
func createMoveSequence(user, targets, move):
	var sequence = []
	sequence.push_back( SequenceUnit.createTextUnit(user.getName() + " used " + move.getMoveName() + "!")); #say whos doing the  move
	sequence.append_array(moveAnimationSequence(user,move,targets))
	
	sequence.push_back(SequenceUnit.createSequenceUnit(func (d,b,u) : #do the move
		user.useMove(move,targets)
		return true
	)); 
	
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
	
#animation that moves the user forward up to the first target
static func basicMoveAnimationSequence( user, move, targets, spriteFrame = SpriteLoader.getSprite("spritesheets/moves/" + move.getMoveName())):
	if targets.size() > 0 && spriteFrame:
		var sequence = []
		sequence.append(SequenceUnit.createSequenceUnit(func (d,b,u):
			var slot = u.getCreatureSlot(user)
			var targetSlot = u.getCreatureSlot(targets[0])
			if slot && targetSlot:
				if slot.get_global_rect().intersects(targetSlot.get_global_rect(),true):
					return true;
				else:
					slot.global_position += .1*(targetSlot.global_position - slot.global_position)
			return false;))
	
		sequence.append(SequenceUnit.createSequenceUnit(func (d,b,u):
			u.setBattleSprite(spriteFrame,u.getCreatureSlot(targets[0]).get_global_position())
			return true
			))

		sequence.append(SequenceUnit.createSequenceUnit(func (d,b,u):
			if u.BattleSprite.getFramesProgress() == 1:
				u.resetCreatureSlot(user)
				u.stopBattleSprite()
				return true
			return false;	
			))
		return sequence
	return []
	
