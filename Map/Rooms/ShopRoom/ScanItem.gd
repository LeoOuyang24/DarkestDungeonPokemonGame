extends ShopItem

@onready var creatureSprite := %Anime

var creature:String = ""
		
func _ready():
	GameState.PlayerState.added_scan.connect(addedScan)
	#if (source):
		#setSprite(source)
	pass
	#label.add_image(load("res://sprites/icons/dna_icon.png"),10,10,Color.WHITE,5,Rect2(0,0,0,0),null,false,"",true);
	#label.add_text("10");

func addedScan(creatureName:StringName) -> void:
	if creature == creatureName:
		set_disabled(true)
		modulate = Color.GRAY
		
		creatureSprite.pause(true);
		
		
func setCreature(creature:StringName):
	var loaded := CreatureLoader.loadJSON(creature);
	if loaded:
		creatureSprite.setSprite(loaded.getSprite())
		#creatureSprite.set_texture_disabled(creatureSprite.getFrameAtIndex(0));
		self.creature = creature
		self.disabled = creature in GameState.PlayerState.getScans();
		#set_custom_minimum_size(loaded.getSprite().get_frame_texture("default",0).get_size());
	else:
		push_error("COULDNT LOAD TEXTURE FOR SCAN BUTTON: " + creature)

func onPurchase():
	GameState.PlayerState.addScan(creature);
	super();
	pass
#func _pressed():
	#if GameState.getDNA() >= cost:
		#GameState.setDNA(GameState.getDNA() - cost)
		#GameState.PlayerState.addScan(creature);

	

