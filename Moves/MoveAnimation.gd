class_name MoveAnimations extends Object

#abstract class for storing move animations

static func genericAttackAnimation(user:Creature,enemies:Array,UI:BattleUI,move:Move,spriteFrames:SpriteFrames = SpriteLoader.getSprite("spritesheets/moves/" + move.getMoveName())):
	if enemies.size() > 0:
		var slot = UI.getCreatureSlot(user)
		var enemyslot = UI.getCreatureSlot(enemies[0])
		
		var tween = slot.getTween()
		tween.tween_property(slot,"global_position",enemyslot.global_position,0.25)
		tween.tween_callback(func():
			UI.setBattleSprite(spriteFrames,enemyslot.get_global_rect().get_center())
			)
		for i in enemies:
			UI.getCreatureSlot(i).setAnimation("hurt")
		await tween.finished
		await UI.BattleSprite.looping
		UI.stopBattleSprite()
		UI.resetAllSlotPos()
		for i in enemies:
			UI.getCreatureSlot(i).setAnimation("default")
