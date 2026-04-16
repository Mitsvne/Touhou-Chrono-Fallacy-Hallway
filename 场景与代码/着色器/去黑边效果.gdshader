shader_type canvas_item;

// 定义颜色阈值，用于判断哪些颜色被视为“黑色”
uniform float cutoff_threshold : hint_range(0.0, 1.0) = 0.1;

void fragment() {
    // 获取原始像素颜色
    vec4 color = texture(TEXTURE, UV);
    
    // 计算当前像素的亮度 (灰度值)
    float luminance = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    
    // 如果亮度低于阈值，则将alpha设为0（完全透明）
   float alpha = smoothstep(cutoff_threshold - 0.1, cutoff_threshold + 0.1, luminance);
	color.a *= alpha; // 将计算出的透明度与原透明度相乘
    
    // 输出处理后的颜色
    COLOR = color;
}