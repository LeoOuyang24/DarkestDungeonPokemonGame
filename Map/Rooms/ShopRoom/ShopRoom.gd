extends EventRoom

@onready var ScanButtonScene := preload("res://Map/Rooms/ShopRoom/ScanItem.tscn")
@onready var TraitButtonScene := preload("res://Map/Rooms/ShopRoom/AddTrait.tscn")
@onready var ShopItemScene := preload("res://Map/Rooms/ShopRoom/ShopItemButton.tscn")

@onready var ApplyItem := %ApplyItem
@onready var DNAItems := %DNA;
@onready var ShopWindow := %Shop;
@onready var TraitItems := %AddTraits
@onready var MoveItems := %AddMoves

var item:ShopItem = null

const maxItems:int = 5;
# Called when the node enters the scene tree for the first time.
func _ready():
	var placeholder := ["Beholder","Chomper","Silent","Dreemer","Siren"]
	var placeholderTraits := [Spectral.new(),Small.new(),Big.new(),Regenerative.new(),Unwavering.new()]
	for i in range(maxItems):
		var scan := ShopItemScene.instantiate()
		var scanButt := ScanButtonScene.instantiate()
		DNAItems.add_child(scan);
		scan.setItem(scanButt,5)
		
		scanButt.setCreature(placeholder[i])
		
		var traitItem := ShopItemScene.instantiate()
		var traitButton := TraitButtonScene.instantiate()
		TraitItems.add_child(traitItem)
		traitItem.setItem(traitButton,15)
		traitButton.setTrait(placeholderTraits[i])
		traitButton.need_apply_item.connect(applyItem.bind(traitButton))
		
		var addMove := ShopItemScene.instantiate()
		var moveButton = load("res://Map/Rooms/ShopRoom/InjectMove.tscn").instantiate()
		MoveItems.add_child(addMove)
		addMove.setItem(moveButton,10)
		moveButton.move = PassTurn.new()
		moveButton.need_apply_item.connect(applyItem.bind(moveButton))
		

	onSelect()
	pass # Replace with function body.

#open the apply item menu
func applyItem( needCreature:bool,item:ShopItem) -> void:
	self.item = item
	ApplyItem.needCreature = needCreature
	ApplyItem.set_visible(true);
		
	ApplyItem.setDirections(item.getDescription())

func onSelect():
	await playIntro("You see \"a man\".")
	Menu.pushMessage("\"Another one for the slaughter?\"")
	Menu.pushMessage("\"Perhaps we can be of use to one another.\"")
	await Menu.messages_empty
	var tween = create_tween();
	tween.tween_property(ShopWindow,"position",Vector2(ShopWindow.position.x,Menu.position.y - ShopWindow.size.y),1);
	tween.play()
	await tween.finished;

#when a creature has been selected from the team
func _on_apply_item_selected(c:Creature,m:int):
	if self.item and c:
		self.item.applyItem(c,m)
		await get_tree().create_timer(1).timeout
		ApplyItem.finish()
