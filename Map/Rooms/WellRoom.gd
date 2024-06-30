extends Node2D

@onready var MessageBox = $InputMenu/Label
@onready var Choices = [$InputMenu/Drink,$InputMenu/DeepDrink,$InputMenu/Study]
@onready var ButtonsMenu = $InputMenu/ButtonsMenu
#seconds to wait before start rendering text
static var delay = 3

#characters to show per second
static var CharPS = 10
#millisecond at which we swapped to this scene
var startTime = 0

signal room_finished()

#DFA
var sequencer:Sequencer = Sequencer.new()

#index of the button that was pressed, -1 if none
var choiceMade = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(len(Choices)):
		Choices[i].pressed.connect(func():
			choiceMade = i
			)

	MessageBox.set_visible_characters(0)
	
	sequencer.insert([
		DFAUnit.new(func(delta,runtime,menu): #delay for "delay" seconds before showing text
			return DFAUnit.RETURN_VALS.DONE if runtime >= delay*1000 else DFAUnit.RETURN_VALS.NOT_DONE
			),
		DFAUnit.new(func(delta,runtime,menu):
			if Input.is_action_just_pressed("click") or runtime >= len(menu.MessageBox.text)/menu.CharPS*1000:
				menu.MessageBox.set_visible_characters(-1)
				return DFAUnit.RETURN_VALS.DONE
			else:
				menu.MessageBox.set_visible_characters((runtime)/(1000/CharPS))
			return DFAUnit.RETURN_VALS.NOT_DONE
			),
		DFAUnit.new(func (delta,runtime,menu):
			for i in menu.Choices:
				var tween = create_tween()
				tween.tween_property(i,"position",Vector2(i.get_position().x,menu.ButtonsMenu.get_position().y + 10),0.5)
			return DFAUnit.RETURN_VALS.DONE),
		DFAUnit.new(func (delta,runtime,menu):
			return DFAUnit.RETURN_VALS.DONE if menu.choiceMade != -1 else DFAUnit.RETURN_VALS.NOT_DONE
			),
		DFAUnit.new(func (d,r,m):
			var player = Game.PlayerState.getPlayer()
			match m.choiceMade:
				0:
					player.setHealth(player.getHealth() + 0.25*player.getMaxHealth())
					var team = Game.PlayerState.getTeam()
					for i in team:
						i.setHealth(i.getHealth() + 0.25*i.getMaxHealth())
				1:
					player.setHealth(player.getHealth() + 0.5*player.getMaxHealth())
				2:
					Game.GameState.setDNA(Game.GameState.getDNA() + 10)
					pass
					
			room_finished.emit()
			return DFAUnit.RETURN_VALS.DONE
		
					
			)
			
		
	])
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sequencer.run(delta,self)
