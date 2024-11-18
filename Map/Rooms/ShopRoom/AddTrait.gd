extends AnimatedButton


@onready var SyringeColor := %Color

func _ready():
	pass
	
func setColor(color:Color) -> void:
	SyringeColor.setColor(color)
	
func setTrait(t:Trait) -> void:
	t.onAddUI(self);
	
	
func _process(delta) -> void:
	onHover()
