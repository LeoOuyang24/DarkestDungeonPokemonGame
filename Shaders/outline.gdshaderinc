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
	//if outline color is transluscent, dont bother applying it
	return mix(mix(col, color, maxa - mina),col,float(color.a == 0.0)); 
}