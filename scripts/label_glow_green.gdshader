shader_type canvas_item;

uniform vec4 glow_color:source_color=vec4(0.0,0.6,0.2,1.0);
uniform float glow_strength:hint_range(0.0,5.0)=5.0;
uniform float glow_size:hint_range(0.0,10.0)=2.0;

void fragment() {
    vec4 tint = COLOR;
    vec4 tex = texture(TEXTURE, UV);
    vec3 base_color = tex.rgb * tint.rgb;
    float base_alpha = tex.a * tint.a;
    float glow = 0.0;
    for (float x = -glow_size; x <= glow_size; x += 1.0) {
        for (float y = -glow_size; y <= glow_size; y += 1.0) {
            glow += texture(TEXTURE, UV + vec2(x, y) * TEXTURE_PIXEL_SIZE).a;
        }
    }
    glow /= pow(glow_size * 2.0 + 1.0, 2.0);
    vec3 final_color = mix(glow_color.rgb * glow_strength, base_color, base_alpha);
    float final_alpha = max(base_alpha, glow * glow_color.a * glow_strength);
    COLOR = vec4(final_color, final_alpha);
}