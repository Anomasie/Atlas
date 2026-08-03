shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec4 BLUE = vec4(156, 146, 244, 256);
uniform vec4 WHITE = vec4(252.0, 250, 172, 256);
uniform vec4 RED = vec4(236, 138, 140, 256);
uniform vec4 BLACK = vec4(4, 2, 4, 256);

void fragment() {
	vec4 bg = texture(SCREEN_TEXTURE, SCREEN_UV);
	// blue? -> leave it be
	if (bg.b > bg.r * 1.5 && bg.b > bg.g * 1.5) {
		COLOR = BLUE / 256.0;
	}
	else {
		float average = (bg.r + bg.g + bg.b) / 3.0;
		// not blue? -> color by hue
		if (average < 0.6) {
			if (average < 0.4) {
				COLOR = BLACK / 256.0;
			} else {
				if ((int(VERTEX.x) + int(VERTEX.y)) % 2 == 0) {
					COLOR = BLACK / 256.0;
				} else {
				COLOR = RED / 256.0;
				}
			}
		} else {
			if (average < 0.7) {
				COLOR = RED / 256.0;
			} else {
				COLOR = WHITE / 256.0;
			}
		}
	}
	//COLOR = vec4(average, average, average, 1.0);
}
