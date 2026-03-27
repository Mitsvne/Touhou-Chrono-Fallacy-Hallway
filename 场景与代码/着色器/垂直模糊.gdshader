shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float strength : hint_range(0.0, 10.0) = 0.0;

void fragment() {
    vec2 ps = SCREEN_PIXEL_SIZE * strength;
    vec4 col = texture(screen_texture, SCREEN_UV) * 0.2;
    col += texture(screen_texture, SCREEN_UV + vec2(0.0,ps.y)) * 0.2;
    col += texture(screen_texture, SCREEN_UV - vec2(0.0,ps.y)) * 0.2;
    col += texture(screen_texture, SCREEN_UV + vec2(0.0,ps.y * 20.0)) * 0.15;
    col += texture(screen_texture, SCREEN_UV - vec2(0.0,ps.y * 20.0)) * 0.15;
    // 可以根据需要增加更多采样
    COLOR = col;
}
