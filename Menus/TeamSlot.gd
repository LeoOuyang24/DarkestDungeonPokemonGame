class_name TeamSlot extends AnimatedButton

#a simplified CreatureSlot that shows a creature

var creature:Creature = null

func _ready():
	var material = ShaderMaterial.new()
	material.shader = load("res://Battle/UI/CreatureSlot.gdshader")
	material.set_local_to_scene(true)
	set_material(material)

func setCreature(c:Creature) -> void:
	if creature:
		creature.traits.onRemoveUI(self)
	creature = c;
	if c:
		setSprite(c.getSprite())
		creature.traits.onAddUI(self)
		creature.traits.status_added.connect(func(status):
			creature.traits.onAddUI(self)
			)
	
func getCreature() -> Creature:
	return creature
