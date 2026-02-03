shader_type canvas_item;
render_mode blend_mix;

/* =======================
   GLOW
======================= */
uniform vec4 glow_color : source_color = vec4(0.5, 0.8, 1.0, 1.0);
uniform float glow_radius = 10.0;
uniform float glow_intensity = 3.3;

/* =======================
   HIT FLASH
======================= */
uniform bool hit_flash_enabled = false;
uniform vec4 hit_flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

/* =======================
   DISSOLVE
======================= */
uniform sampler2D dissolve_noise;
uniform float dissolve_value : hint_range(0.0, 1.0);
uniform vec4 dissolve_outline_color : source_color = vec4(0.305882, 0.854902, 0.941176, 1.0);

void fragment() {
    /* =======================
       BASE COLOR
    ======================= */
    vec4 base_tex = texture(TEXTURE, UV) * COLOR;
    float base_alpha = base_tex.a;

    /* =======================
       DISSOLVE
    ======================= */
    vec2 screen_uv = SCREEN_UV;
    float noise = texture(dissolve_noise, screen_uv).r;

    float epsilon = 0.00001;

    // Dissolve mask for color
    vec3 dissolve_mask_color;
    if (abs(noise - dissolve_value) < epsilon) {
        dissolve_mask_color = vec3(0.0);
    } else if (noise < dissolve_value) {
        dissolve_mask_color = vec3(1.0);
    } else {
        dissolve_mask_color = vec3(0.0);
    }

    // Slightly offset dissolve mask for alpha
    float dissolve_value_alpha = dissolve_value + 0.03;
    vec3 dissolve_mask_alpha;
    if (abs(noise - dissolve_value_alpha) < epsilon) {
        dissolve_mask_alpha = vec3(0.0);
    } else if (noise < dissolve_value_alpha) {
        dissolve_mask_alpha = vec3(1.0);
    } else {
        dissolve_mask_alpha = vec3(0.0);
    }

    // Mix outline color and base texture
    vec3 dissolved_color = mix(dissolve_outline_color.rgb, base_tex.rgb, dissolve_mask_color);

    // Apply alpha
    float final_alpha = base_alpha * dissolve_mask_alpha.x;

    /* =======================
       HIT FLASH
    ======================= */
    vec3 final_color = dissolved_color;
    if (hit_flash_enabled) {
        final_color = hit_flash_color.rgb;
    }

    /* =======================
       GLOW
    ======================= */
    float glow = 0.0;
    for (float i = 0.0; i < 32.0; i++) {
        float angle = i / 32.0 * 6.28318;
        vec2 dir = vec2(cos(angle), sin(angle));
        for (float d = 9.0; d <= glow_radius; d += 1.0) {
            vec2 offset = dir * d * TEXTURE_PIXEL_SIZE;
            glow += texture(TEXTURE, UV + offset).a * (1.0 - d / glow_radius);
        }
    }
    glow = glow / 16.0;

    vec4 glow_col = glow_color * glow * glow_intensity;
    if (dissolve_value < 1.0) {
        glow_col = vec4(0.0);
    }

    /* =======================
       FINAL OUTPUT
    ======================= */
    COLOR = vec4(final_color, final_alpha) + glow_col * (1.2 - base_tex.a);
}