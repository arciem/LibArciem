#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

varying vec4 v_color;

void main()
{
	if(gl_FrontFacing) {
		gl_FragColor = v_color;
	} else {
		discard;
	}
}
