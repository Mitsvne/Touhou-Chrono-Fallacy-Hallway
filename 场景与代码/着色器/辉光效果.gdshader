shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // 辉光颜色
uniform float glow_strength : hint_range(0.0, 5.0) = 1.0; // 辉光强度
uniform float glow_size : hint_range(0.0, 5.0) = 1.0; // 辉光大小/模糊程度

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);
    vec4 color = original_color;
    
    // 简单的径向辉光算法
    vec2 centered_uv = UV - vec2(0.5);
    float dist = length(centered_uv);
    float glow = smoothstep(0.5, 0.5 - glow_size * 0.1, dist);
    
    color.rgb = mix(color.rgb, glow_color.rgb, glow * glow_strength);
    COLOR = color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
