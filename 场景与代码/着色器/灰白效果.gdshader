shader_type canvas_item;
// 定义一个控制灰度强度的uniform，方便在编辑器调整
uniform float gray_intensity : hint_range(0.0, 1.0) = 1;
void fragment() {
    // 1. 获取纹理原本的颜色
    vec4 original_color = texture(TEXTURE, UV);
    // 2. 计算颜色的亮度（使用标准的人眼感知权重）
    float brightness = dot(original_color.rgb, vec3(0.299, 0.587, 0.114));
    // 3. 根据灰度强度，在原始颜色和灰色之间混合
    vec3 gray_color = vec3(brightness);
    vec3 final_color = mix(original_color.rgb, gray_color, gray_intensity);
    // 4. 输出最终颜色，保持原始透明度
    COLOR = vec4(final_color, original_color.a);
	 // 如果像素在边缘上，则将其颜色设置为发光色
}



