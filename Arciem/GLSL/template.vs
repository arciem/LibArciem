attribute vec4 a_position;
attribute vec4 a_normal;
attribute vec4 a_color;

uniform mat4 u_mvp_matrix;

varying vec4 v_color;

void main()
{
	gl_Position = u_mvp_matrix * a_position;
	v_color = a_color;
}
