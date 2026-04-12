shader_type canvas_item;

// 声明全局着色器变量（需要在项目设置中已添加）
global uniform float CUSTOM_TIME;

// 浮动参数（保持不变）
uniform float speed_x1 : hint_range(0.0, 2.0) = 0.5;
uniform float speed_x2 : hint_range(0.0, 2.0) = 0.7;
uniform float speed_y1 : hint_range(0.0, 2.0) = 1.0;
uniform float speed_y2 : hint_range(0.0, 2.0) = 1.0;
uniform float amplitude : hint_range(0.0, 20.0) = 20.0;   // 最大偏移量（像素）

void vertex() {
    // ✅ 将 TIME 替换为 CUSTOM_TIME
    float offset_x = sin(CUSTOM_TIME * speed_x1) * cos(CUSTOM_TIME * speed_x2) * amplitude;
    float offset_y = sin(CUSTOM_TIME * speed_y1) * cos(CUSTOM_TIME * speed_y2) * amplitude;
    
    VERTEX.x += offset_x;
    VERTEX.y += offset_y;
}