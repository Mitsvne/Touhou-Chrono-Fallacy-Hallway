shader_type canvas_item;
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.02;
void fragment() {
	// 生成一个简单的噪声值，用于偏移 UV
	// 这里使用 UV 本身和 TIME 来生成一个流动的噪声
	float noise = sin(UV.x * 20.0 + TIME) * cos(UV.y * 20.0 + TIME);
	// 根据噪声偏移 UV，产生扭曲感
	vec2 distorted_uv = UV + vec2(noise) * distortion_strength;
	// 使用扭曲后的 UV 进行采样
	vec4 original_color = texture(TEXTURE, distorted_uv);
	COLOR = original_color;
}