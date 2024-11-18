shader_type canvas_item;

uniform float outline_width = 3.0;
uniform vec4 outline_color : source_color;
uniform bool isSpectral = false;

#include "res://Shaders/outline.gdshaderinc"
#include "res://Shaders/regen.gdshaderinc"
#include "res://Shaders/spectral.gdshaderinc"

void fragment() {

	COLOR = mix(COLOR,spectral(TEXTURE,UV,vec4(1,1,1,1),vec4(0.3,0,0.6,1)),float(isSpectral));
	//COLOR = texture(TEXTURE,UV);
	COLOR = outline(TEXTURE,UV,COLOR,TEXTURE_PIXEL_SIZE,outline_width,outline_color);

}
//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
