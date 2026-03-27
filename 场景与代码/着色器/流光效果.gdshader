shader_type canvas_item;

uniform float speed = 1.0;
uniform vec4 glow_color : source_color = vec4(0.3, 0.6, 1.0, 0.8);
void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    // 创建一个动态移动的亮度遮罩（流光效果）
    float moving_glow = sin(TIME * speed + UV.x * 3.14159 * 2.0) * 0.5 + 0.5;
    // 叠加一个整体的脉动效果
    float pulse = sin(TIME * 1.5) * 0.2 + 0.8;
    // 将原始纹理颜色、流光和脉动效果混合
    COLOR = mix(tex_color, glow_color, moving_glow * 0.3) * pulse;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
