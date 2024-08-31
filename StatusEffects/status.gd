class_name StatusEffect extends Object

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
	

