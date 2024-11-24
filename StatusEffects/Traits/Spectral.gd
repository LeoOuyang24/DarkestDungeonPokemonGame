class_name Spectral extends Trait

#once per battle, this trait blocks the first instance of damage

var spectral := true #true if the effect is active

# Called when the node enters the scene tree for the first time.
func _init():
	name = "Spectral"

func inBattle(battle:Battlefield) -> void:
	spectral = true;
	creature.stats.addDamageMod(0,false,self);	

func onAddUI(slot:Control) -> void:
	#add the creatureslot to the trigger to remove the shader effect
	if creature:
		creature.stats.getStatObj(CreatureStats.STATS.HEALTH).stat_changed.connect(trigger.bind(slot))
	slot.get_material().set_shader_parameter("isSpectral", spectral)
	
func trigger(amount:int, newVal:int,slot:CreatureSlot) -> void:
	if spectral:
		creature.stats.damageMods.removeSource(self)
		spectral = false;
		slot.get_material().set_shader_parameter("isSpectral", spectral)
		
		
	
func onRemoveUI(slot:Control) -> void:
	slot.get_material().set_shader_parameter("isSpectral", false)
	
