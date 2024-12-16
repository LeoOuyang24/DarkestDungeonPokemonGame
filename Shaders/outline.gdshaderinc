//col is the color of the current texture, used for if we wanted to apply effects before
//color is the outline color
vec4 outline(sampler2D text, vec2 uv,vec4 col, vec2 pixel_size,float width, vec4 color)
{
	//vec4 col = texture(text,uv);
	float a;
	float maxa = col.a;
	float mina = col.a;

	a = texture(text,uv + vec2(0.0, -width) * pixel_size).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(text,uv + vec2(0.0, width) * pixel_size).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(text,uv + vec2(-width, 0.0) * pixel_size).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(text,uv + vec2(width, 0.0) * pixel_size).a;
	maxa = max(a, maxa);
	mina = min(a, mina);
	//final color of this fragment (maybe)
	vec4 outline = mix(col, color, maxa - mina);
	//if outline color is transluscent, dont bother applying it
	return mix(outline,col,float(color.a == 0.0 || col.a < 0.5)); 
}