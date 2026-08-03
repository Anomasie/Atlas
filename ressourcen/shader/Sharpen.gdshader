shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec4 WHITE = vec4(252.0, 250, 252, 256);
uniform vec4 BEIGE = vec4(236, 154, 84, 256);
uniform vec4 BROWN = vec4(132, 66, 4, 256);
uniform vec4 BLACK = vec4(4, 2, 4, 256);

void fragment() {
	vec4 bg = texture(SCREEN_TEXTURE, SCREEN_UV);
	float average = (bg.r + bg.g + bg.b) / 3.0;
	// not blue? -> color by hue
	if (average < 0.2) {
		if (average < 0.1) {
			COLOR = BLACK / 256.0;
		} else {
			if ((int(VERTEX.x) + int(VERTEX.y)) % 2 == 0) {
				COLOR = BLACK / 256.0;
			} else {
			COLOR = BROWN / 256.0;
			}
		}
	} else if (average < 0.5) {
		if (average < 0.4) {
			COLOR = BROWN / 256.0;
		} else {
			if ((int(VERTEX.x) + int(VERTEX.y)) % 2 == 0) {
				COLOR = BROWN / 256.0;
			} else {
			COLOR = BEIGE / 256.0;
			}
		}
	} else if (average < 0.9) {
		if (average < 0.8) {
			COLOR = BEIGE / 256.0;
		} else {
			if ((int(VERTEX.x) + int(VERTEX.y)) % 2 == 0) {
				COLOR = BEIGE / 256.0;
			} else {
			COLOR = WHITE / 256.0;
			}
		}
	} else {
		COLOR = WHITE / 256.0;
	}
	//COLOR = vec4(average, average, average, 1.0);
}
