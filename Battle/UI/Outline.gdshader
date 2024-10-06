shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(0,0,0,1); // White color
uniform float line_thickness : hint_range(0.0, 20.0) = 10.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
	
	float left = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
	float right = texture(TEXTURE, UV + vec2(size.x, 0)).a;
	float up = texture(TEXTURE, UV + vec2(0, size.y)).a;
	float down = texture(TEXTURE, UV + vec2(0, -size.y)).a;
	
	float sum = min(left + right + up + down,1.0f);
	vec4 curColor = texture(TEXTURE,UV);
	
	
	COLOR = mix(curColor,line_color,sum - curColor.a);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
