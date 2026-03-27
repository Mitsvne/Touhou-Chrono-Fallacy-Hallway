shader_type canvas_item;

// --- 定义控制旋钮 (uniforms) ---
// 通过这些变量，你可以在编辑器的Inspector或代码中，独立地调整每个效果的强度或开关
uniform float edge_intensity : hint_range(0.0, 2.0) = 1.0;      // 边缘光强度
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.02; // 折射扭曲强度
uniform float sparkle_amount : hint_range(0.0, 1.0) = 0.5;       // 闪光数量

void fragment() {
    // --- 第1步：基础纹理采样 ---
    // 先读取精灵原本的样子
    vec4 original_color = texture(TEXTURE, UV);

    // --- 第2步：计算折射扭曲效果 (影响UV坐标) ---
    // 注意：效果之间有依赖关系。我们希望看到的是“被扭曲了的水晶”，
    // 所以后续的边缘光和闪光，都应该基于扭曲后的图像来计算。
    float noise = sin(UV.x * 20.0 + TIME) * cos(UV.y * 20.0 + TIME);
    vec2 distorted_uv = UV + vec2(noise) * distortion_strength;
    vec4 color_with_distortion = texture(TEXTURE, distorted_uv);

    // --- 第3步：计算边缘光效果 (基于原始UV计算边缘因子) ---
    // 边缘因子通常基于像素离图形边缘的距离，使用原始UV计算更准确
    vec2 dist_to_edge = min(UV, 1.0 - UV);
    float edge_factor = 1.0 - min(dist_to_edge.x, dist_to_edge.y);
    edge_factor = pow(edge_factor, 2.0); // 调整边缘过渡的锐利度
    vec3 edge_light = vec3(1.0) * edge_factor * edge_intensity; // 假设边缘光为白色

    // --- 第4步：计算动态闪光效果 (基于扭曲后的图像和位置) ---
    // 闪光点应该出现在水晶表面，所以基于扭曲后的UV计算会更自然
    float sparkle_noise = sin(distorted_uv.x * 100.0 + TIME * 5.0) * cos(distorted_uv.y * 100.0 + TIME * 3.0);
    sparkle_noise = sparkle_noise * 0.5 + 0.5;
    float sparkle = step(1.0 - sparkle_amount, sparkle_noise);
    vec3 sparkle_light = vec3(0.8) * sparkle; // 闪光颜色

    // --- 第5步：最终混合 ---
    // 现在，我们将所有效果叠加起来。
    // 先加上边缘光，再加上闪光。颜色混合使用加法通常效果不错。
    vec3 final_color = color_with_distortion.rgb + edge_light + sparkle_light;

    // 输出最终颜色，保持原有的透明度
    COLOR = vec4(final_color, original_color.a);
}