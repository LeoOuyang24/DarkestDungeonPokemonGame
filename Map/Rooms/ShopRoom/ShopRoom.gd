extends EventRoom

@onready var ScanButtonScene := preload("res://Map/Rooms/ShopRoom/ScanItem.tscn")
@onready var TraitButtonScene := preload("res://Map/Rooms/ShopRoom/AddTrait.tscn")
@onready var ShopItemScene := preload("res://Map/Rooms/ShopRoom/ShopItem.tscn")

@onready var DNAItems := %DNA;
@onready var ShopWindow := %Shop;
@onready var TraitItems := %AddTraits


const maxItems:int = 5;
# Called when the node enters the scene tree for the first time.
func _ready():
	var placeholder := ["Beholder","Chomper","Silent","Dreemer","Siren"]
	for i in range(maxItems):
		var button := ScanButtonScene.instantiate()
		var scanShop := ShopItemScene.instantiate();
		DNAItems.add_child(scanShop)
		scanShop.setButton(button)
		button.setCreature(placeholder[i]);
				
		var shopItem := ShopItemScene.instantiate();
		var traitButton := TraitButtonScene.instantiate()
		traitButton.setTrait(Spectral.new() if i%2 == 0 else Small.new())
		shopItem.setButton(traitButton)
		TraitItems.add_child(shopItem)



	onSelect()
	pass # Replace with function body.

func onSelect():
	await playIntro("You see \"a man\".")
	Menu.pushMessage("\"Another one for the slaughter?\"")
	Menu.pushMessage("\"Perhaps we can be of use to one another.\"")
	await Menu.messages_empty
	var tween = create_tween();
	tween.tween_property(ShopWindow,"position",Vector2(ShopWindow.position.x,400),1);
	tween.play()
	await tween.finished;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



