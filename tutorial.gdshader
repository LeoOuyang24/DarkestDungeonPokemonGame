shader_type canvas_item;

uniform float screenWidth = 1920; //set these in _ready()
uniform float screenHeight = 1080;
uniform vec4 rect; //rect we want to see
uniform vec4 color = vec4(0,0,0,0.7); //color of everything else


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 screenCoord = vec2(UV.x*screenWidth,UV.y*screenHeight);
	COLOR = mix(color,vec4(0),float(screenCoord.x >= rect.x && screenCoord.x <= rect.x + rect.z && screenCoord.y >= rect.y && screenCoord.y <= rect.y + rect.a));

}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
