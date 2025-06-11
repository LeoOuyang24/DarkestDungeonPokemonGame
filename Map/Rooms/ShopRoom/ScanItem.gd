extends ShopItem

@onready var creatureSprite := %Anime

var creature:String = ""
		
func _ready():
	GameState.PlayerState.added_scan.connect(addedScan)
	pass

func addedScan(creatureName:StringName) -> void:
	if creature == creatureName:
		modulate = Color.GRAY
		
		creatureSprite.pause(true);
				
func setCreature(creature:StringName):
	var loaded := CreatureLoader.loadJSON(creature);
	if loaded:
		creatureSprite.setSprite(loaded.getSprite())
		#creatureSprite.set_texture_disabled(creatureSprite.getFrameAtIndex(0));
		self.creature = creature
		#set_custom_minimum_size(loaded.getSprite().get_frame_texture("default",0).get_size());
	else:
		push_error("COULDNT LOAD TEXTURE FOR SCAN BUTTON: " + creature)

func onPurchase(_c,_m):
	GameState.PlayerState.addScan(creature);
	pass

func _process(delta):
	super(delta)
	self.set_disabled(disabled or creature in GameState.PlayerState.getScans());

	
