extends RoomBase

@onready var ScanButtonScene := preload("res://Map/Rooms/ShopRoom/ScanButton.tscn")

@onready var DNAItems := %DNA;
@onready var ShopWindow := %Shop;
@onready var Menu := %InputMenu;

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
	var tween = ShopWindow.create_tween()
	tween.tween_interval(1)
	tween.tween_property(Menu,"modulate",Color.WHITE,1);
	await tween.finished;
	tween.stop()
	await Menu.setMessage("You see a man");
	tween.tween_property(ShopWindow,"position",Vector2(ShopWindow.position.x,400),1);
	tween.play()
	await tween.finished;
	Menu.setMessage("He cobbles together some goods for you")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	room_finished.emit()
	pass # Replace with function body.
