shader_type canvas_item;

uniform vec2 world_center = vec2(0.0, 0.0);
uniform float world_radius = 100.0;
uniform vec2 camera_pos = vec2(0.0, 0.0);
uniform vec2 camera_zoom = vec2(1.0, 1.0);
uniform vec2 viewport_size = vec2(1024.0, 768.0);
uniform float feather = 0.0;

void fragment() {
	vec2 screen_pos = SCREEN_UV * viewport_size;
	vec2 world_pos = camera_pos + (screen_pos - viewport_size * 0.5) / camera_zoom;
	float dist_to_center = length(world_pos - world_center);
	float alpha = step(world_radius, dist_to_center);
	if (feather > 0.0) {
		alpha = smoothstep(world_radius - feather, world_radius + feather, dist_to_center);
	}
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
