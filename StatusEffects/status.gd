class_name StatusEffect extends Object

signal stacks_changed(amount)

var icon:Texture2D = null
var tooltip:String = ""
var name:StringName = ""
var stacks:int = 0;

func _init(name_:StringName,icon_:Texture2D,tooltip_:String) -> void:
	self.name = name_
	self.icon = icon_;
	self.tooltip = tooltip_

#called when added to a creature
func onAdd(creature:Creature):
	pass
	
#what to do at end of turn
#by default, remove one stack
func newTurn() -> void:
	addStacks(-1);
	
func addStacks(amount:int) -> void:
	setStacks(getStacks() + amount)	
	
func setStacks(hardSet:int) -> void:
	var oldAmount = stacks
	stacks = hardSet;
	stacks_changed.emit(hardSet - oldAmount)
	
func getStacks() -> int:
	return stacks

