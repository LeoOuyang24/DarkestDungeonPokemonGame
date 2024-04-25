class_name Player extends Creature



var moving = 0;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
#func _init():
	#super._init(Player,"dialga",100,"Player");
	#setAttacks([Tackle.new(),HyperBeam.new(),NastyPlot.new()])
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if moving == 1:
		position += Vector2(10,0);
		if position.x > 600:
			moving = 2;
	elif moving == 2:
		position -= Vector2(10,0);
		if (position.x <= 0):
			position.x = 0;
			moving = 0; 
	
	pass


func attack():
	moving = 1;
	pass # Replace with function body.
