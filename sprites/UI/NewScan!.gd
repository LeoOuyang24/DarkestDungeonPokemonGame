extends ColorRect

@onready var CreatureName:Label = %"Creature Name"
@onready var Sprite:Anime = %Anime

func _ready():
	GameState.PlayerState.added_scan.connect(addScanUI)
			
func addScanUI(creatureName:String):
	if setCreature(creatureName):
		var tween = create_tween()
		tween.tween_property(self,"position",Vector2(self.position.x,0),1);
		tween.tween_property(self,"position",Vector2(self.position.x,-self.get_size().y),1).set_delay(2);

func setCreature(creatureName:StringName) -> bool:

	var creature:Creature = CreatureLoader.loadJSON(creatureName)
	if creature:
		CreatureName.set_text(creature.getName())
		Sprite.setSprite(creature.getSprite())
		return true
	return false
	
