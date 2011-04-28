#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

varying vec4 colorVarying;

void main()
{
	if(gl_FrontFacing) {
		gl_FragColor = colorVarying;
	} else {
		gl_FragColor = vec4(0.5, 0.5, 0.5, 1.0);
	}
//	gl_FragColor = vec4(colorVarying[0], colorVarying[1], colorVarying[2], 0.5);
//	gl_FragColor = vec4(1.0, 0.0, 0.0, 0.5);
}
