extends EventRoom

@onready var FreeDNA := %Creature
var creature:Creature = null:
	set(val):
		creature = val
		if val:
			FreeDNA.setSprite(val.getSprite())
		else:
			FreeDNA.setSprite(null)
# Called when the node enters the scene tree for the first time.
func _ready():
	var array = ["???","AMORPH","Am0rph","siren","giant","princess"]
	creature = CreatureLoader.getRandCreature(array)
	onSelect()

func onSelect() -> void:
	FreeDNA.disabled = true
	await playIntro("A mysterious creature lurks inside the contraption before you.")
	Menu.pushMessage("Perhaps it can be of use?")
	await Menu.messages_empty
	FreeDNA.disabled = false

func _on_creature_pressed() -> void:
	if creature:
		%Flash.visible = true

		#if creature is already in the team
		if GameState.PlayerState.getScans().reduce(func (accum:bool, name:String):
				return accum || (name == creature.getName())
				,false):
			GameState.increaseDNA(10);
			Menu.pushMessage("You've seen this creature before, but a little extra data can't hurt.")

		else:
			GameState.PlayerState.addScan(creature.getSpeciesName())
			Menu.pushMessage("The creature was added to your database.")
		creature = null
		var tween := create_tween()
		tween.tween_property(%Flash,"color",Color(0,0,0,0),.3)
		await tween.finished
		await Menu.messages_empty

		

	pass # Replace with function body.
