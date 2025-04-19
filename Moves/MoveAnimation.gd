class_name MoveAnimations extends Object

#abstract class for storing move animations

#standard attack animation, user moves towards target and an animation plays
static func genericAttackAnimation(user:Creature,enemies:Array,UI:BattleUI,move:Move,scale:float = 1):

	if enemies.size() > 0:
		var slot = UI.getCreatureSlot(user)

		var tween = slot.getTween()
		#move user forward
		tween.tween_property(slot,"global_position",Vector2(slot.global_position.x + 100*(1 if user.getIsFriendly() else -1),slot.global_position.y),0.25*BattleUI.battleSpeed).set_trans(Tween.TRANS_EXPO)
		await tween.finished
		var spriteFrames:SpriteFrames = SpriteLoader.getSprite("spritesheets/moves/" + move.getMoveName())
		if spriteFrames:
			for enemy in enemies:
				var enemyslot = UI.getCreatureSlot(enemy)
				if enemyslot:
					AnimeEffect.createEffectOnControl(spriteFrames,enemyslot,scale,!user.getIsFriendly(),BattleUI.battleSpeed);

		tween = slot.getTween()
		#reset user position
		tween.tween_property(slot,"global_position",Vector2(slot.global_position.x,slot.global_position.y),0.25*BattleUI.battleSpeed).set_trans(Tween.TRANS_EXPO)
		for i in enemies:
			var enemy := UI.getCreatureSlot(i)
			if enemy.getCreature():
				enemy.setAnimation("hurt")
		await tween.finished

		#UI.resetAllSlotPos()
		for i in enemies:
			var enemy := UI.getCreatureSlot(i)
			if enemy.getCreature():
				enemy.setAnimation("default")
