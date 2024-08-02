class_name Anime extends TextureRect

@export var frames:SpriteFrames = null
@export var currentAnimation:StringName = "default"

signal looping() #when the animation loops

#time we started at
var start:int = 0; 

func setSprite(newFrames:SpriteFrames):
	self.frames = newFrames;
	if newFrames:
		var newSize = newFrames.get_frame_texture(currentAnimation,0).get_size()
		set_texture(getCurrentFrame());
		#self.size = newSize


func getSprite():
	return frames;

#sets the current time we started and optionally sets new SpriteFrames
func play(frames_:SpriteFrames = null):
	if frames_ != null:
		setSprite(frames_)
	if frames:
		start = Time.get_ticks_msec();
	
#change the currentAnimation
func changeAnimation(newAnimation:String):
	if frames.get_animation_names().find(newAnimation) != -1:
		currentAnimation = newAnimation;
	
#return frame at index
#accounts for index being out of range
func getFrameAtIndex(index:int):
	if frames:
		return frames.get_frame_texture(currentAnimation,index%(frames.get_frame_count(currentAnimation)));
	return null
	
#convert ticks (milliseconds) passed to the index of the frame
func ticksToIndex(ticks:int):
	if frames:
		return int(ticks/1000.0*frames.get_animation_speed(currentAnimation))%(frames.get_frame_count(currentAnimation))
	return -1;
	
#return the frame after "ticks" milliseconds
func getFrameAfterTime(ticks:int):
	if frames:
		return getFrameAtIndex(ticksToIndex(ticks));
	return null
	
#get the amount of milliseconds we've run for
func getRuntime():
	return Time.get_ticks_msec() - start
	
func getCurrentFrame():
	return getFrameAfterTime(getRuntime());
	
#return the progress of our animation
#0 if first frame
#1 if last frame or if there's only one frame
#index/(frames-1) if none of the aboe
#-1 if null sprite
func getFramesProgress():
	if frames:
		var framesCount = frames.get_frame_count(currentAnimation) - 1;
		if framesCount > 1:
			return float(ticksToIndex(getRuntime()))/(framesCount);
		return 1;
	else:
		return -1;
	
func _init():
	set_stretch_mode(STRETCH_KEEP_ASPECT)
	set_expand_mode(EXPAND_IGNORE_SIZE)
	
#set dimensions of the sprite
func setSize(size:Vector2):
	self.size = size

func getFrameSize(frame:int = 0,animation:StringName = "default") -> Vector2:
	if frames:
		return frames.get_frame_texture(animation,frame).get_size()
	return Vector2(0,0)

func _process(delta):
	if frames:
		set_texture(getCurrentFrame());
		if getFramesProgress() == 1:
			looping.emit()
		

	
