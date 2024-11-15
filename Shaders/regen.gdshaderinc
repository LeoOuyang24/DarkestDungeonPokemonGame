vec4 color_swap(sampler2D text, vec2 uv, vec4 a, vec4 b)
{
	vec4 col = texture(text,uv);
	return mix(a,col,distance(col,b));
}
