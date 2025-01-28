class_name ShopItemButton extends VBoxContainer

#represents a complete item in the shop, including all UI elements


#adds a ShopItem as child
func setItem(node:ShopItem,cost:int) -> void:
	if node:
		add_child(node)
		move_child(node,0)
		node.size_flags_vertical = SIZE_SHRINK_END
		node.size_flags_horizontal = SIZE_SHRINK_CENTER
	
		node.label = %PriceLabel
		node.cost = cost

		node.add_child(OnHoverHightlight.new());
		
