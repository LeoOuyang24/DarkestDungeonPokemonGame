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
	var shader :=  ShaderMaterial.new()
	shader.set_shader(load("res://Battle/UI/Outline.gdshader"))
	set_material(shader)
	if source:
		setSprite(source)
	pass # Replace with function body.

#set the sprite and it if it's not null, play it, and scale the button to fit the sprite size
func setSprite(sprite:SpriteFrames) -> void:
	self.sprite.setSprite(sprite)
	if sprite:
		self.sprite.play()

func changeAnimation(animation:String) -> void:
	sprite.changeAnimation(animation)

func setSize(size:Vector2):
	self.custom_minimum_size = size
	self.size = size
	
func setOutlineColor(color:Color): 
	material.set_shader_parameter("outline_color", color)	

#function that changes outline based on if we are being hovered
#override in child class to disable
func onHover():
	if material and onHoverOutline:
		setOutlineColor( Color.YELLOW if is_hovered() else Color(0,0,0,0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if sprite.getCurrentFrame():
		set_texture_normal(sprite.getCurrentFrame())
	else:
		set_texture_normal(null)
	onHover()

	pass
