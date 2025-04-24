class_name DebugState extends Control

#debug stuff

@onready var Controls := %Controls
@onready var DefaultControls := %DefaultControls

#map of Key to function
var controls := {}
var defaultControls := {}

#controls that are always valid
var defaults:Array[RoomDebug] = [
	RoomDebug.new(KEY_EQUAL,"increase DNA by 10",GameState.increaseDNA.bind(10)),
	RoomDebug.new(KEY_MINUS,"decrease DNA by 10",GameState.increaseDNA.bind(-10))
]


static var isDebug := false #true if we are debugging
static var num := 0

static func isDebugging() -> bool:
	return isDebug

func _ready():
	#setDebugControls(mapDebug(GameMap.new()))
	setDebugControls(defaults,true)
	set_modulate(Color(1,1,1,0))

func resetControls(v:VBoxContainer):
	for i in v.get_children():
		v.remove_child(i)
		i.queue_free()

#add a room's debug controls
#"default" is true if we are adding default controls
func setDebugControls(roomControls:Array[RoomDebug],default:bool = false) -> void:
	var v:VBoxContainer = DefaultControls if default else Controls
	var dict:Dictionary = defaultControls if default else controls
	
	resetControls(v)
	dict.clear()
	for control in roomControls:
		var label := RichTextLabel.new()
		label.fit_content = true
		label.bbcode_enabled = true
		label.set_text("[b][color=red]" + OS.get_keycode_string(control.key) + "[/color][/b] " +\
		"[color=black]" + control.message + "[/color]" )
		v.add_child(label)
		
		dict[control.key] = control.callable

func swapToRoom(r:RoomBase):
	if r is GameMap:
		setDebugControls(mapDebug(r))
	elif r is BattleManager:
		setDebugControls(battleDebug(r))
	else:
		setDebugControls([])
		

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_BACKSPACE and event.ctrl_pressed:
			isDebug = !isDebug
			set_modulate(Color(1,1,1,int(isDebug)))
		elif isDebugging():
			if controls.get(event.keycode):
				controls[event.keycode].call()
			elif defaultControls.get(event.keycode):
				defaultControls[event.keycode].call()
	

#------------------ Room specific debug stuff ------------------------

#A single keystroke for the debug of a room
class RoomDebug:
	var key:Key = KEY_0
	var message:String = "describe what this does"
	var callable:Callable = func():
		pass
	
	func _init(key_:Key,message_:String,callable_:Callable):
		self.key = key_
		self.message = message_
		self.callable = callable_
	
#debugging map
func mapDebug(map:GameMap) -> Array[RoomDebug]:
	if map:
		return [
			RoomDebug.new(KEY_R,"reload the map",map.reset),
			RoomDebug.new(KEY_A,"toggle room accessibility",map.forEachRoom.bind(func(r:Room):
				r.changeState(Room.ROOM_STATE.ACCESSIBLE)
				))
		]
	return []

var searcher = preload("res://DebugSearcher.tscn")



#long ass function that I decided to put separate from battleDebug
#for organization
func rightClickDebugSearch(battle:BattleManager,slot:Control) -> void:
	if isDebugging():
		#add a search bar
		var searchbar := searcher.instantiate()
		slot.add_child(searchbar)
		var butt:Button = searchbar.find_child("Button")
		var text:TextEdit = searchbar.find_child("TextEdit")
		if butt and text:
			#wait for the search button to be pressed
			await butt.pressed
			#attempt to load the creature
			if slot is CreatureSlot:
				var creature := CreatureLoader.loadJSON(text.get_text())
				if creature:
					#add it, removing the old creature in the process
					#the old creature is NOT DEAD, so if player is removed
					#the game does not end
					var index := battle.BattleSim.getCreatureIndex(slot.getCreature())
					battle.BattleSim.removeCreature(slot.getCreature())
					battle.BattleSim.addCreature(creature,index)
			elif slot is MoveButton:
				var move := CreatureLoader.loadMove(text.get_text())
				if move:
					slot.setMove(move)
		slot.remove_child(searchbar)
		searchbar.queue_free()

#but basically makes right clicking creature slots change creatures
func battleDebugSignals(battle:BattleManager) -> void:
	for slot in battle.UI.creatureSlots:
		if slot:
			slot.right_clicked.connect(rightClickDebugSearch.bind(battle,slot))
	for move in battle.UI.Summary.Moves.Moves:
		if move:
			move.right_clicked.connect(rightClickDebugSearch.bind(battle,move))

#debugging battleManager
func battleDebug(battle:BattleManager) -> Array[RoomDebug]:
	if battle and battle.UI:
		battleDebugSignals(battle)
				#slot.add_child(label))
		return [
			RoomDebug.new(KEY_BACKSLASH,"win the battle"\
				,battle.changeState.bind(BattleManager.BATTLE_STATES.WE_WON)),
			RoomDebug.new(KEY_BACKSPACE,"lose the battle"\
			#kill the player, using the debug state as the source
				,GameState.PlayerState.getPlayer().\
				stats.getStatObj(CreatureStats.STATS.HEALTH).\
				modStat.bind(0,false,self))
		]
	return []
		
