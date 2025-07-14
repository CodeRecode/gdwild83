shader_type canvas_item;
const float shadow_threshold = .01;
const float light_threshold = .99;

void fragment() {
	vec2 uv = fract(UV + vec2(.5, .5));
	vec4 shadow = vec4(0.0);
	vec4 light = vec4(0.0);

	if (uv.x < shadow_threshold) {
		shadow = vec4((shadow_threshold - uv.x) * 5.0);
	}
	if (uv.x > light_threshold) {
		light = vec4((uv.x - light_threshold) * 5.0);
	}
	if (uv.y < shadow_threshold) {
		shadow += vec4((shadow_threshold - uv.y) * 5.0);
	}
	if (uv.y > light_threshold) {
		light += vec4((uv.y - light_threshold) * 5.0);
	}

	vec4 noise_text = texture(TEXTURE, uv);
	vec4 base_color = vec4(0.924, 0.806, 0.649, 1.0);
	COLOR = base_color + noise_text * .05 - shadow + light;
}
