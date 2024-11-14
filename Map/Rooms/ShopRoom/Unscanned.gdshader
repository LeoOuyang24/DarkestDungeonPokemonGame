shader_type canvas_item;

uniform vec3 color = vec3(0,1,0);
uniform float reach = 1;
uniform float disabled = 0;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 pixel = texture(TEXTURE,UV);
	vec3 background=mix(color,vec3(0.5,0.5,0.5),disabled);
	COLOR = vec4(background,distance(pixel,vec4(0,0,0,1)));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
