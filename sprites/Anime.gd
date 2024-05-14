class_name Anime extends TextureRect

@export var frames:SpriteFrames = null
@export var currentAnimation:StringName = "default"

#time we started at
var start:int = 0; 

func setSprite(frames:SpriteFrames):
	self.frames = frames;

func getSprite():
	return frames;

#sets the current time we started and optionally sets new SpriteFrames
func play(frames_:SpriteFrames = null):
	if frames_ != null:
		setSprite(frames_)
	if frames:
		start = Time.get_ticks_msec();
	
	
#return frame at index
#accounts for index being out of range
func getFrameAtIndex(index:int):
	if frames:
		return frames.get_frame_texture(currentAnimation,index%(frames.get_frame_count(currentAnimation)));
	return null
	
#convert ticks (milliseconds) passed to the index of the frame
func framesToIndex(ticks:int):
	if frames:
		return int(ticks/1000.0*frames.get_animation_speed(currentAnimation))%(frames.get_frame_count(currentAnimation))
	return -1;
	
#return the frame after "ticks" milliseconds
func getFrameAfterTime(ticks:int):
	if frames:
		return getFrameAtIndex(framesToIndex(ticks));
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
			return float(framesToIndex(getRuntime()))/(framesCount);
		return 1;
	else:
		return -1;
	
func _process(delta):
	if frames:
		set_texture(getCurrentFrame());
	
