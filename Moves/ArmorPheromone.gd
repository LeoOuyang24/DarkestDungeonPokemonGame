class_name ArmorPheronmone extends Move

	
func _init():
	super("Armor Pheromone",0,10)
	summary="Give your entire party +2 armor"

	
func move(user, targets, battlefield):
	#var arr = battlefield.getEnemies(user.getIsFriendly()) 
	#var count = 0
	var allies = battlefield.getAllies(user.getIsFriendly())
	for ally in allies:
		if ally:
			ally.statuses.addStatus(AddArmorEffect.new(),2);
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
