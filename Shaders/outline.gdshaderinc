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
	vec4 outline = mix(col, color, maxa - mina);
	//for transparency, use the original texel if the outline would be transparaent
	return vec4(outline.rgb,mix(col.a,outline.a,float(outline.a < 1.0))); 
}