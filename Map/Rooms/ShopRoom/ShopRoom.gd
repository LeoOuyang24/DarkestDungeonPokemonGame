extends EventRoom

@onready var ScanButtonScene := preload("res://Map/Rooms/ShopRoom/ScanButton.tscn")

@onready var DNAItems := %DNA;
@onready var ShopWindow := %Shop;


const maxItems:int = 5;
# Called when the node enters the scene tree for the first time.
func _ready():
	var placeholder := ["Beholder","Chomper","Silent","Dreemer","Siren"]
	for i in range(maxItems):
		var button := ScanButtonScene.instantiate()
		button.setCreature(placeholder[i]);
		DNAItems.add_child(button)
	onSelect()
	pass # Replace with function body.

func onSelect():
	var tween = await getIntro("You see a man.")
	tween.tween_property(ShopWindow,"position",Vector2(ShopWindow.position.x,400),1);
	tween.play()
	await tween.finished;
	Menu.setMessage("He cobbles together some goods for you")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



