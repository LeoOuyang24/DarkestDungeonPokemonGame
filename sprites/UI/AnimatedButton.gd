class_name AnimatedButton extends TextureButton

@export var onHoverOutline:bool = true #true if we want to show an outline when hovered over
@export var source:SpriteFrames = null
var sprite:Anime = Anime.new()

func _init():
	#stretch to fit sprite
	#you don't always want to ignore texture size. CreatureSlot does, for example but TeamViewSlot doesn't
	#manually set ignore_texture if you want to ignore texture size
	set_stretch_mode(TextureButton.STRETCH_KEEP_ASPECT)
# Called when the node enters the scene tree for the first time.
func _ready():
	if source:
		setSprite(source)

#set the sprite and it if it's not null, play it, and scale the button to fit the sprite size
func setSprite(sprite:SpriteFrames) -> void:
	self.sprite.setSprite(sprite)
	if sprite:
		setSize(self.sprite.getFrameSize())
		self.sprite.play()

func changeAnimation(animation:String) -> void:
	sprite.changeAnimation(animation)

func setSize(size:Vector2):
	self.custom_minimum_size = size
	self.size = size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if sprite.getCurrentFrame():
		set_texture_normal(sprite.getCurrentFrame())
	else:
		set_texture_normal(null)
	if onHoverOutline and not disabled:
		Resources.highlight(self,Color.YELLOW if is_hovered() else Color(0,0,0,0))

	pass
