extends TextureButton

signal big_boost(stat:CreatureStats.STATS)

@export var stat:CreatureStats.STATS = CreatureStats.STATS.HEALTH
@export var statBar:StatBar = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(onHover)
	mouse_exited.connect(offHover)

func onHover() -> void:
	if statBar:
		statBar.setBonus(Stat.BIG_BOOST_AMOUNT,Color.BLUE)

func offHover() -> void:
	if statBar:
		statBar.setBonus(0)

func _pressed() -> void:
	big_boost.emit(stat)
		
