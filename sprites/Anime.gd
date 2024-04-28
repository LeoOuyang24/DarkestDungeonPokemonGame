class_name Anime extends TextureRect

@export var frames:SpriteFrames = null
@export var currentAnimation:StringName = "default"

#time we started at
var start:int = 0; 

#sets the current time we started and optionally sets new SpriteFrames
func play(frames_:SpriteFrames = null):
	if frames_ != null:
		frames = frames_;
	if frames:
		start = Time.get_ticks_msec();
	
	
#return frame at index
func getFrameAtIndex(index:int):
	if frames:
		return frames.get_frame_texture(currentAnimation,index%(frames.get_frame_count(currentAnimation)));
	return null
	
#return the frame after "ticks" milliseconds
func getFrameAfterTime(ticks:int):
	if frames:
		return getFrameAtIndex(ticks/1000.0*frames.get_animation_speed(currentAnimation));
	return null
	
func getCurrentFrame():
	return getFrameAfterTime(Time.get_ticks_msec() - start);
	
	
func _process(delta):
	if frames:
		set_texture(getCurrentFrame());
	
