shader_type canvas_item;

void fragment() {
	float average = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
//	if (COLOR.b > 1.2 * average) {
//		COLOR.r /= 2.0;
//		COLOR.g /= 2.0;
//		COLOR.b /= 2.0;
//	}
	float factor = COLOR.b + 0.6;
	COLOR.r /= factor;
	COLOR.g /= factor;
	COLOR.b /= factor;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
