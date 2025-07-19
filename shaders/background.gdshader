shader_type canvas_item;

uniform vec2 player_position;
uniform float repeat_scale;

void fragment() {
	COLOR = texture(TEXTURE, fract(fract(UV * repeat_scale + (player_position / 3000.0) * (repeat_scale / 5.0))));
}