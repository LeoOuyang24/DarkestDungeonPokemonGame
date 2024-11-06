class_name MoveAnimations extends Object

#abstract class for storing move animations

#standard attack animation, user moves towards target and an animation plays
static func genericAttackAnimation(user:Creature,enemies:Array,UI:BattleUI,move:Move,spriteFrames:SpriteFrames = SpriteLoader.getSprite("spritesheets/moves/" + move.getMoveName())):
	if enemies.size() > 0:
		var slot = UI.getCreatureSlot(user)
		var enemyslot = UI.getCreatureSlot(enemies[0])
		
		var tween = slot.getTween()
		tween.tween_property(slot,"global_position",Vector2(slot.global_position.x + 50*(1 if user.getIsFriendly() else -1),slot.global_position.y),0.25).set_trans(Tween.TRANS_EXPO)
		await tween.finished
		if spriteFrames:
			UI.setBattleSprite(spriteFrames,enemyslot.global_position)
			await UI.BattleSprite.looping
		tween = slot.getTween()
		tween.tween_property(slot,"global_position",Vector2(slot.global_position.x,slot.global_position.y),0.25).set_trans(Tween.TRANS_EXPO)
		for i in enemies:
			UI.getCreatureSlot(i).setAnimation("hurt")
		await tween.finished

		#UI.resetAllSlotPos()
		for i in enemies:
			UI.getCreatureSlot(i).setAnimation("default")
