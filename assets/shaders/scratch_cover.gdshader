shader_type canvas_item;

// Metalik kapak shader'i.
// reveal: 0.0 = tam kapali, 1.0 = tam acik (dissolve).
uniform float reveal : hint_range(0.0, 1.0) = 0.0;
uniform vec4 base_color : source_color = vec4(0.55, 0.55, 0.6, 1.0);
uniform vec4 shine_color : source_color = vec4(0.75, 0.75, 0.8, 1.0);

// Basit hash noise (mobil uyumlu)
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
	vec2 uv = UV;

	// Metalik gradient (yukari parlak, asagi koyu)
	float gradient = mix(0.85, 1.15, uv.y * 0.5 + 0.25);
	vec4 metal = mix(base_color, shine_color, smoothstep(0.3, 0.7, uv.x + uv.y * 0.3)) * gradient;

	// Metalik parlama cizgisi
	float shine_line = smoothstep(0.48, 0.5, uv.x + uv.y * 0.5 - 0.25) - smoothstep(0.5, 0.52, uv.x + uv.y * 0.5 - 0.25);
	metal.rgb += shine_line * 0.3;

	// Dissolve (reveal > 0)
	float n = noise(uv * 8.0);
	float dissolve_edge = smoothstep(reveal - 0.05, reveal + 0.05, n);

	// Kenar parlama (dissolve sirasinda)
	float edge_glow = smoothstep(reveal - 0.08, reveal, n) - smoothstep(reveal, reveal + 0.08, n);

	COLOR = metal;
	COLOR.rgb += edge_glow * vec3(0.3, 1.0, 0.5) * step(0.01, reveal) * step(reveal, 0.99);
	COLOR.a *= dissolve_edge;
}
