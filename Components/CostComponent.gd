class_name CostComponent extends Node

#represents things with a cost

@export var cost:int = 0;
var onPurchase:Callable = func():
	pass

func _init(cost_:int = 0, onPurchase_:Callable = func():
	pass
	) -> void:
	cost = cost_
	onPurchase = onPurchase_;


func _ready():
	var parent = get_parent() as Control
	if parent:
		parent.pressed.connect(onClick)
		
func onClick():
	if GameState.getDNA() >= cost:
			onPurchase.call();
