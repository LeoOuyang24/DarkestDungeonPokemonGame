extends AnimatedButton

@onready var label := %RichTextLabel

var creature:String = ""
		
func _ready():
	GameState.PlayerState.added_scan.connect(addedScan)
	pass
	#label.add_image(load("res://sprites/icons/dna_icon.png"),10,10,Color.WHITE,5,Rect2(0,0,0,0),null,false,"",true);
	#label.add_text("10");

func addedScan(creatureName:StringName) -> void:
	if creature == creatureName:
		set_disabled(true)
		material.set_shader_parameter("disabled", 1.0)
		
		
func setCreature(creature:StringName):
	var loaded := CreatureLoader.loadJSON(creature);
	if loaded:
		setSprite(loaded.getSprite())
		set_texture_disabled(sprite.getFrameAtIndex(0));
		self.creature = creature
		self.disabled = creature in GameState.PlayerState.getScans();
		#set_custom_minimum_size(loaded.getSprite().get_frame_texture("default",0).get_size());
	else:
		push_error("COULDNT LOAD TEXTURE FOR SCAN BUTTON: " + creature)

	
func _pressed():
	GameState.PlayerState.addScan(creature);

	

