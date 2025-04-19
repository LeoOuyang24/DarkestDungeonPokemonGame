extends Control

var isTutorial := false #true if tutorial is on

func _ready():
	material.set_shader_parameter("screenWidth", DisplayServer.screen_get_size().x)
	material.set_shader_parameter("screenHeight",DisplayServer.screen_get_size().y)

func turnOnOff(b:bool):
	isTutorial = b
	
func setOutline(rect:Vector4) -> void:
	material.set_shader_parameter("rect",rect)
	
#set the color around the outline, by default just sets it to clear
func setColor(color:Vector4 = Vector4(0,0,0,0)) -> void:
	material.set_shader_parameter("color",color)
	
#slowly focus on one rect in "time" milliseconds
func focusOn(rect:Vector4,time:int) -> void:
	setColor()
	setOutline(rect)
	var tw := create_tween()
	tw.tween_method(setColor,Vector4(0,0,0,0),Vector4(0,0,0,0.8),time/1000.0)
	await tw.finished
	
#creates the first tutorial battle
func createTutorialBattle(battle:Battlefield) -> void:
	if battle:
		battle.reset()
		var player := GameState.PlayerState.getPlayer()
		
		var scan = player.moves.find_custom(func (m):
			return (m.move is Scan))
		if scan != -1:
			player.moves[scan].setCooldown(1)
			
		battle.addCreature(player,0)
		battle.addCreature(CreatureLoader.loadJSON("chomper"),battle.relPosToAbs(0,false))

#the actual UI components of the tutorial battle
func runBattleTutorial(ui:BattleUI) -> void:
	if ui:
		var player := GameState.PlayerState.getPlayer()
		ui.setCurrentCreature(player)
		
		var scan = ui.Summary.Moves.get_children().find_custom(func (b):
			return b.getMove() is Scan
			)
			
		if scan != -1:
			await ui.Summary.Moves.sort_children
			var rect:Rect2 = ui.Summary.Moves.get_children()[scan].get_global_rect()
			await focusOn(Vector4(rect.position.x,rect.position.y,rect.size.x,rect.size.y),1000)
		
#master run the tutorial function
#kick starts tutorial
func run(g:Game):
	await GameState.battle_started
	self.visible = true
	createTutorialBattle(g.curScene.BattleSim)
	await runBattleTutorial(g.curScene.UI)
	pass
	
