class_name Shock extends StatusEffect


func _init():
	super("Shock",load("res://sprites/statuses/shock.png"),"All stacks are consumed at end of turn and creature.\
	Half of stacks are dealt to neighbors as damage")
		
func newTurn() -> void:
	if GameState.battleUI:
		GameState.battleUI.requestNewTurnEvent(newTurnUI)		
		
#what to actually do on new turn
#this is run with the ui stuff
func applyShock() -> void:
	if creature and GameState.getBattle():
		var neighIsForHorses = GameState.getBattle().getNeighbors(creature)
		for c:Creature in neighIsForHorses:
			if c:
				c.stats.takeDamage(Damage.new(getStacks()/2,Damage.DAMAGE_TYPES.SHOCK))

	
func newTurnUI():
	if GameState.battleUI:
		applyShock()

		await showStatusEffectFade(self,GameState.battleUI.getCreatureSlot(creature))		
		setStacks(0)
		
		pass
