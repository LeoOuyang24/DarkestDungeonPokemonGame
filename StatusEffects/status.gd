class_name StatusEffect extends Resource

#emitted when it's time to remove this
signal remove_this()
signal stacks_changed(amount)

var icon:Texture2D = null
var tooltip:String = ""
var name:StringName = ""
var stacks:int = 0;
var creature:Creature = null

#non debuff status effects are buffs
var isDebuff:bool = true;

func _init(name_:StringName,icon_:Texture2D,tooltip_:String, isDebuff_:bool = true) -> void:
	self.name = name_
	self.icon = icon_;
	self.tooltip = tooltip_
	isDebuff = isDebuff_

func getTooltip() -> String:
	return tooltip;

#called when added to a creature
func onAdd(creature:Creature):
	self.creature = creature
	pass
	
#called when removed
func onRemove():
	pass
	
func getIsDebuff() -> bool:
	return isDebuff;
	
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
	if getStacks() <= 0:
		remove_this.emit();
	
func getStacks() -> int:
	return stacks

#function that runs on a creatureslot when a creature with this trait is added
#used to render visual effects for a trait
func onAddUI(slot:Control) -> void:
	pass

#function to call when a creature is removed
func onRemoveUI(slot:Control) -> void:
	pass
