class_name AnimeEffect extends AnimatedSprite2D

#animated effects that die when they end

# Called when the node enters the scene tree for the first time.
func _ready():
	self.animation_looped.connect(_on_animation_looped)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start(str:StringName = "default") -> void:
	set_visible(true);
	play(str);


func _on_animation_looped():
	set_visible(false)
	queue_free()
	pass # Replace with function body.

#run an animation once, useful for move animations
#scale only affects the width, the height is scaled appropriately
static func createEffect(sprite:SpriteFrames,scale:float = 1, flipped:bool = false) -> AnimeEffect:
	if sprite:
		var battleSprite := AnimeEffect.new();

		battleSprite.set_sprite_frames(sprite)
		var size := sprite.get_frame_texture("default",0).get_size()
		battleSprite.set_scale(Vector2(scale,scale*size.y/size.x))
		battleSprite.set_flip_h(flipped)
		battleSprite.start();
		
		return battleSprite
	return null;
	
#same as above but add an effect to the center of a control
static func createEffectOnControl(sprite:SpriteFrames,control:Control,scale:float = 1,flipped:bool = false ) -> void:
	var effect := createEffect(sprite,scale,flipped);
	control.add_child(effect)
	effect.set_position(0.5*control.size)
