class_name Burn extends StatusEffect


func _init():
	super("Burn",load("res://sprites/statuses/burn.png"),"All stacks are consumed at end of turn and creature\
	suffers damage equal to stacks. Doubled if 10 or more stacks.")
		
func newTurn() -> void:
	if GameState.battleUI:
		GameState.battleUI.requestNewTurnEvent(newTurnUI)		
		
#what to actually do on new turn
#this is run with the ui stuff
func applyBurn():
	if creature and GameState.getBattle():
		GameState.getBattle().events.changeStat(creature,\
		CreatureStats.STATS.HEALTH,getStacks()*(-2 if getStacks() >= 10 else -1),true,self)

	
func newTurnUI():
	if GameState.battleUI:
		applyBurn()
		await showStatusEffectFade(self,GameState.battleUI.getCreatureSlot(creature))		
		setStacks(0)
		
		pass
