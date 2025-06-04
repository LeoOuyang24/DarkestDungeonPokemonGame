extends EventRoom

@onready var MessageBox = $InputMenu/Label
@onready var Choices = [%Drink,%DrinkDeeply,%Study]
@onready var Drink = %Drink;
@onready var DrinkDeeply = %DrinkDeeply
@onready var Study = %Study
@onready var ButtonsMenu = $ButtonsMenu
#seconds to wait before start rendering text
static var delay = 3

func _ready():
	onSelect()
	
	Drink.pressed.connect(done.bind(_on_drink_pressed))
	DrinkDeeply.pressed.connect(done.bind(_on_deep_drink_pressed))
	Study.pressed.connect(done.bind(_on_study_pressed))

func onSelect():
	await playIntro("You approach a foul smelling corpse. A suspicious liquid oozes out.")
	var tween = create_tween()
	tween.tween_property(ButtonsMenu,"global_position",Vector2(ButtonsMenu.get_global_position().x,Menu.global_position.y - ButtonsMenu.size.y),0.5)
	tween.play()
	await tween.finished


func _on_drink_pressed():
	var player = GameState.PlayerState.getPlayer()
	player.stats.getStatObj(CreatureStats.STATS.HEALTH).modStat(player.stats.getCurStat(CreatureStats.STATS.HEALTH) + 0.25*player.stats.getBaseStat(CreatureStats.STATS.HEALTH))
	var team = GameState.PlayerState.getTeam()
	for i in team:
		if i:
			i.stats.getStatObj(CreatureStats.STATS.HEALTH).modStat(i.stats.getCurStat(CreatureStats.STATS.HEALTH) + 0.25*i.stats.getBaseStat(CreatureStats.STATS.HEALTH))
	
	$Sparkles.visible = true
	Menu.setMessage("You and your abominations feel rejuvenated.")
	
func _on_deep_drink_pressed():
	var player = GameState.PlayerState.getPlayer()
	player.stats.getStatObj(CreatureStats.STATS.HEALTH).modStat(player.stats.getCurStat(CreatureStats.STATS.HEALTH) + 0.5*player.stats.getBaseStat(CreatureStats.STATS.HEALTH))
	$Sparkles.visible = true
	$Sparkles.get_node("AnimationPlayer").play("default")
	Menu.setMessage("Drinking deeply, you feel refreshed")

func _on_study_pressed():
	GameState.setDNA(GameState.getDNA() + 10)
	Menu.setMessage("The creature's flesh provides some interesting insights.")

#what to do when room is finished
func done(callable:Callable):
	callable.call() 
	for choice in Choices:
		choice.set_disabled(true)
	var tween = create_tween()
	tween.tween_property(ButtonsMenu,"modulate",Color(0,0,0,0),0.5);
