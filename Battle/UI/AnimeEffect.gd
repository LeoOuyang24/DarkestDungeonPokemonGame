class_name AnimeEffect extends AnimatedSprite2D

#animated effects that die when they end

signal finished #emitted when finished

# Called when the node enters the scene tree for the first time.
func _ready():
	self.animation_looped.connect(_on_animation_looped)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start(str:StringName = "default",speed:float = 1.0) -> void:
	set_visible(true);
	set_speed_scale(speed)
	play(str);


func _on_animation_looped():
	set_visible(false)
	queue_free()
	finished.emit()
	pass # Replace with function body.

#run an animation once, useful for move animations
#scale only affects the width, the height is scaled appropriately
static func createEffect(sprite:SpriteFrames,scale:float = 1, flipped:bool = false, speed:float = 1.0) -> AnimeEffect:
	if sprite:
		var battleSprite := AnimeEffect.new();

		battleSprite.set_sprite_frames(sprite)
		var size := sprite.get_frame_texture("default",0).get_size()
		battleSprite.set_scale(Vector2(scale,scale*size.y/size.x))
		battleSprite.set_flip_h(flipped)
		battleSprite.start("default",speed);
		
		return battleSprite
	return null;
	
#same as above but add an effect to the center of a control
static func createEffectOnControl(sprite:SpriteFrames,control:Control,scale:float = 1,flipped:bool = false, speed:=1.0 ) -> AnimeEffect:
	var effect := createEffect(sprite,scale,flipped,speed);
	control.add_child(effect)
	effect.set_position(0.5*control.size)
	return effect

static func createEffectOnCreatureSlot(sprite:SpriteFrames,control:CreatureSlot,scale:float = 1,flipped:bool = false, speed:=1.0 ) -> AnimeEffect:
	if control:
		return createEffectOnControl(sprite,control.Sprite,scale,flipped,speed)
	return null
