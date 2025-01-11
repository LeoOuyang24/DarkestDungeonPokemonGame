extends Node

@onready var Name:RichTextLabel = %Name
@onready var Message:RichTextLabel = %Message
@onready var Icon:TextureRect = %Icon

var nameStr:String = ""
var nameColor:Color = Color.WHITE;

var message:String = ""
#the UI that shows up when hovering over something

func setName(str:String, color:Color=Color.WHITE) -> void:
	nameStr = str
	nameColor = color
	
#I don't know why, but setting Icon directly, even when before _ready is called, works perfectly.
#However, if you do this with setName or setMessage, Godot allocates way too much space for the VBox
#so when setting Name or Message, that is deferred to _ready() and setting Icon just does it immediately
func setIcon(text:Texture2D) -> void:
	%Icon.set_texture(text);
	
func setMessage(str:String) -> void:
	message = str;
	
func _ready():
	Name.push_color(nameColor)
	Name.append_text(nameStr)
	Message.append_text(message)

