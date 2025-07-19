shader_type canvas_item;

uniform sampler2D screen : hint_screen_texture;
uniform vec4 hit_color : source_color;

void fragment() {
	vec4 bgColor = texture(screen, SCREEN_UV);
	vec4 textColor = texture(TEXTURE, UV);
	COLOR = vec4(textColor.rgb * .9 - (vec3(.9) - bgColor.rgb) * .8 + hit_color.rgb, textColor.a);
}