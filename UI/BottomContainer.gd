class_name BottomContainer extends Container

#a container that tries to align objects with its bottom most axis
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _get_minimum_size() -> Vector2:
	return size

func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		# Must re-sort the children
		var x := 0
		for c in get_children():
			var dimen:Vector2 = c.custom_minimum_size;
			fit_child_in_rect(c, Rect2(Vector2(x,size.y - dimen.y), dimen))
			x += dimen.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
