class_name ShopItemButton extends VBoxContainer

#represents a complete item in the shop, including all UI elements

@onready var priceTag := %PriceTag

var button:ShopItemButton = null

func setItem(node:ShopItem,cost:int) -> void:
	if node:
		add_child(node)
		move_child(node,0)
		node.size_flags_vertical = SIZE_SHRINK_END
		node.size_flags_horizontal = SIZE_SHRINK_CENTER
	
		node.add_child(OnHoverHightlight.new());
		
		priceTag.setCost(cost)
