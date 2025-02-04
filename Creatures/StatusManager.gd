class_name StatusManager extends Object

signal status_added(status:StatusEffect)
signal status_removed(status:StatusEffect)

var creature:Creature
#maps status names (StringName) to status objects
var statuses:Dictionary = {}

func _init(creature:Creature) -> void:
	self.creature = creature

func addStatus(status:StatusEffect,stacks:int = 1) -> void:
	if statuses.has(status.name):
		#if this status effect is already in our creature, just add stacks
		statuses[status.name].addStacks(stacks)
	else:
		#otherwise, add this status effect
		statuses[status.name] = status
		status.setStacks(stacks)
		status.onAdd(creature);
		#remove the status effect when it reaches 0 stacks
		status.remove_this.connect(removeStatus.bind(status))
		status_added.emit(statuses[status.name])

func removeStatus(status:StatusEffect) -> void:
	status.onRemove();
	statuses.erase(status.name)
	status_removed.emit(status)

func clear() -> void:
	for key in statuses:
		removeStatus(statuses[key])

func getStatus(statusName:StringName) -> StatusEffect:
	if statuses.has(statusName):
		return statuses[statusName]
	return null
	
#return all statuses
func getAllStatuses() -> Dictionary:
	return statuses
	
	
func newTurn() -> void:
	for name in statuses:
		statuses[name].newTurn()
