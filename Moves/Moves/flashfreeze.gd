class_name FlashFreeze extends Move

#applies burn, freeze, and shock

# Called when the node enters the scene tree for the first time.
func _init():
	super("Flash Freeze",1,1)
	summary = "Applies 6 stacks of Frost."
	pass # Replace with function body.


func move(user:Creature, enemies:Array, battlefield):
	if len(enemies) > 0: #just to be safe, make sure we are actually targeting something
		var target:Creature = battlefield.getCreature(enemies[0])
		battlefield.events.applyStatus(user,target,Frost.new(),6)

	
func runAnimation(user:Creature, targets:Array, UI:BattleUI,battlefield:Battlefield) -> void:
	await MoveAnimations.genericAttackAnimation(user,targets,UI,self)
