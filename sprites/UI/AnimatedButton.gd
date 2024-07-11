class_name AnimatedButton extends TextureButton

@export var source:SpriteFrames = null
var sprite = Anime.new()

func _init():
	set_ignore_texture_size(true)
	set_stretch_mode(TextureButton.STRETCH_KEEP_ASPECT)
# Called when the node enters the scene tree for the first time.
func _ready():

	if source:
		setSprite(source)
	pass # Replace with function body.

#set the sprite and it if it's not null, play it, and scale the button to fit the sprite size
func setSprite(sprite:SpriteFrames) -> void:
	self.sprite.setSprite(sprite)
	if sprite:
		self.sprite.play()
		#have our size fit the sprite
		size = sprite.get_frame_texture("default",0).get_size()
		setSize(size)

func changeAnimation(animation:String) -> void:
	sprite.changeAnimation(animation)

func setSize(size:Vector2):
	#self.custom_minimum_size = size
	self.size = size
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_texture_normal(sprite.getCurrentFrame())
	pass
