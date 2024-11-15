vec4 spectral(sampler2D text, vec2 uv, vec4 a, vec4 b)
{
	vec4 col = texture(text,uv);
	return vec4(mix(a,b,distance(col,b)).rgb,col.a);
}