shader_type canvas_item;

// 浮动参数
uniform float speed_x1 : hint_range(0.0, 2.0) = 0.5;
uniform float speed_x2 : hint_range(0.0, 2.0) = 0.7;
uniform float speed_y1 : hint_range(0.0, 2.0) = 1.0;
uniform float speed_y2 : hint_range(0.0, 2.0) = 1.0;
uniform float amplitude : hint_range(0.0, 20.0) = 20.0;   // 最大偏移量（像素）

void vertex() {
    // 使用两个不同频率的正弦/余弦组合，产生类似随机的漂移路径
    float offset_x = sin(TIME * speed_x1) * cos(TIME * speed_x2) * amplitude;
    float offset_y = sin(TIME * speed_y1) * cos(TIME * speed_y2) * amplitude;
    
    VERTEX.x += offset_x;
    VERTEX.y += offset_y;
}