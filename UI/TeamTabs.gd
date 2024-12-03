extends TabBar

@onready var Summary = $".."

## Called when the node enters the scene tree for the first time.
#func _ready():
	#var team = GameState.PlayerState.getTeam()
	#var i := 0
	#for creature:Creature in team:
		#if creature:
			#add_child(Panel.new())
			#set_tab_title(i,"")
			#
			#var sprite = creature.getSprite().get_frame_texture("default",0);
			#
			#set_tab_icon(i,sprite)
			#get_tab_bar().set_tab_icon_max_width(i,100)
			#i+=1
	#pass # Replace with function body.

# Called when the node enters the scene tree for the first time.
func _ready():
	var team = GameState.PlayerState.getTeam()
	var i := 0
	for creature:Creature in team:
		if creature:
			
			var sprite = creature.getSprite().get_frame_texture("default",0);
			add_tab("",sprite)
			set_tab_icon_max_width(i,100)
			i+=1
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func _on_tab_clicked(tab):
	Summary.setCreature(GameState.PlayerState.getTeam()[tab])
	#$TextureRect.set_texture(get_tab_icon(tab));
	pass # Replace with function body.
