
shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.5, 0.8, 1.0, 1.0);
uniform float radius = 10.0;
uniform float intensity = 3.3;

void fragment() {
    vec4 base = texture(TEXTURE, UV);

    float glow = 0.0;

    for (float i = 0.0; i < 32.0; i++) {
        float angle = i / 32.0 * 6.28318;
        vec2 dir = vec2(cos(angle), sin(angle));

        for (float d = 9.0; d <= radius; d += 1.0) {
            vec2 offset = dir * d * TEXTURE_PIXEL_SIZE;
            glow += texture(TEXTURE, UV + offset).a * (1.0 - d / radius);
        }
    }

    glow = glow / 16.0;

    vec4 glow_col = glow_color * glow * intensity;

    COLOR = base + glow_col * (1.2 - base.a);
}
