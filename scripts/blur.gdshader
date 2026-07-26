shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float intensity : hint_range(0.0, 1.0) = 0.5;
uniform float corner_size : hint_range(0.0, 1.0) = 0.4;

void fragment() {
	vec2 uv = SCREEN_UV;

	// distanța de la centru (0 = centru, ~0.7 = colț)
	vec2 centered = uv - vec2(0.5);
	float dist = length(centered);

	// mască: 0 în centru, 1 spre colțuri
	float mask = smoothstep(corner_size, 0.75, dist) * intensity;

	vec4 col = vec4(0.0);
	float total = 0.0;
	float blur_amount = 6.0 * intensity;

	for (float x = -3.0; x <= 3.0; x += 1.0) {
		for (float y = -3.0; y <= 3.0; y += 1.0) {
			vec2 offset = vec2(x, y) * blur_amount * SCREEN_PIXEL_SIZE;
			col += texture(screen_texture, uv + offset);
			total += 1.0;
		}
	}
	col /= total;

	COLOR = mix(texture(screen_texture, uv), col, mask);
}