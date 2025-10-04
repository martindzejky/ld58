shader_type canvas_item;

uniform vec2 world_center = vec2(0.0, 0.0);
uniform float world_radius = 100.0;
uniform vec2 camera_pos = vec2(0.0, 0.0);
uniform vec2 camera_zoom = vec2(1.0, 1.0);
uniform vec2 viewport_size = vec2(1024.0, 768.0);

uniform float wobble_amp1 = 6.0;
uniform float wobble_freq1 = 8.0;
uniform float wobble_speed1 = 0.6;

uniform float wobble_amp2 = 3.0;
uniform float wobble_freq2 = 15.0;
uniform float wobble_speed2 = -0.35;

uniform float wobble_amp3 = 2.0;
uniform float wobble_freq3 = 27.0;
uniform float wobble_speed3 = 0.9;

void fragment() {
	vec2 screen_pos = SCREEN_UV * viewport_size;
	vec2 world_pos = camera_pos + (screen_pos - viewport_size * 0.5) / camera_zoom;

	vec2 to_center = world_pos - world_center;
	float dist_to_center = length(to_center);

	float angle = atan(to_center.y, to_center.x);
	float wobble = 0.0;

	float t1 = TIME * wobble_speed1;
	wobble += 0.5 * wobble_amp1 * (
		sin(angle * wobble_freq1 + t1 + 0.0) +
		sin(angle * wobble_freq1 - t1 + 1.1)
	);

	float t2 = TIME * wobble_speed2;
	wobble += 0.5 * wobble_amp2 * (
		sin(angle * wobble_freq2 + t2 + 0.7) +
		sin(angle * wobble_freq2 - t2 + 2.3)
	);

	float t3 = TIME * wobble_speed3;
	wobble += 0.5 * wobble_amp3 * (
		sin(angle * wobble_freq3 + t3 + 2.1) +
		sin(angle * wobble_freq3 - t3 + 3.6)
	);
	float effective_radius = world_radius + wobble;

	float alpha = step(effective_radius, dist_to_center);
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
