class_name Grow extends Move


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init():
	super("Grow",0,1)
	icon = load("res://sprites/icons/moves/upicon.png")
	summary = "Double user's attack"

	
func getPostMoveMessage(user:Creature, targets:Array,battlefield:Battlefield) -> String:
	return user.getName() + "'s attack doubled!"
	
func runAnimation(user,targets,UI,battlefield:Battlefield):
	var slot = UI.getCreatureSlot(user)
	var tween = slot.getTween()
	#UI.setBattleSprite(SpriteLoader.getSprite("effects/upArrow"),slot.get_global_position())
	#UI.setBattleSprite(SpriteLoader.getSprite("effects/upArrow"),slot.get_global_position())
	#tween.tween_property(UI.BattleSprite,"modulate",Color(0,0,0,-1),1)
	#tween.tween_callback(func():
		#UI.BattleSprite.modulate = Color.WHITE;
		#UI.stopBattleSprite();
		#)
		
	#tween.tween_method(slot.setSize,1*slot.Sprite.size,1.5*slot.Sprite.size,0.5)
	#tween.tween_method(slot.setSize,1.5*slot.Sprite.size,1*slot.Sprite.size,0.5)
	tween.tween_property(slot,"size",1.5*slot.size,0.5)
	#scaling up the slot moves it downwards (because the top doesn't move)
	#as a simple hack, if we move the slot's position, we can compensate 
	tween.parallel().tween_property(slot,"position",slot.position - Vector2(slot.size.x*.25,slot.size.y*.5),0.5)
	tween.tween_property(slot,"size",slot.size,0.5)
	tween.parallel().tween_property(slot,"position",slot.position,0.5)
	#slot.Sprite.scale = Vector2(2,2);

	await tween.finished
	
func move(user,targets, battlefield):
	#user.stats.getStatObj(CreatureStats.STATS.ATTACK).addStat(user.stats.getCurStat(CreatureStats.STATS.ATTACK))
	user.statuses.addStatus(AddStatEffect.new(CreatureStats.STATS.ATTACK),user.stats.getCurStat(CreatureStats.STATS.ATTACK))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
