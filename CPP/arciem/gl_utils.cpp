/*******************************************************************************
 
 Copyright 2011 Arciem LLC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 *******************************************************************************/

#include "gl_utils.hpp"

namespace arciem {

	const vector2 vector2::zero (0, 0);
	const vector2 vector2::one  (1, 1);
	const vector2 vector2::right(1, 0);
	const vector2 vector2::up   (0, 1);

	const vector3 vector3::zero   (0, 0, 0);
	const vector3 vector3::one    (1, 1, 1);
	const vector3 vector3::right  (1, 0, 0);
	const vector3 vector3::up     (0, 1, 0);
	const vector3 vector3::forward(0, 0, 1);
	
	vector3 vector3::cross(vector3 const& p1, vector3 const& p2)
	{
		vector3 v1 = p1 - *this;
		vector3 v2 = p2 - *this;
		return v1.cross(v2);
	}

	const vector4 vector4::zero(0, 0, 0, 0);
	const vector4 vector4::one (1, 1, 1, 1);

	const color color::red    (1, 0, 0, 1);
	const color color::green  (0, 1, 0, 1);
	const color color::blue   (0, 0, 1, 1);
	const color color::cyan   (0, 1, 1, 1);
	const color color::magenta(1, 0, 1, 1);
	const color color::yellow (1, 1, 0, 1);
	const color color::white  (1, 1, 1, 1);
	const color color::black  (0, 0, 0, 1);
	const color color::gray   (0.5, 0.5, 0.5, 1);
	const color color::grey   (0.5, 0.5, 0.5, 1);
	const color color::clear  (0, 0, 0, 0);

	const matrix4x4 matrix4x4::zero(0, 0, 0, 0,
									0, 0, 0, 0,
									0, 0, 0, 0,
									0, 0, 0, 0);
	
	const matrix4x4 matrix4x4::identity(1, 0, 0, 0,
										0, 1, 0, 0,
										0, 0, 1, 0,
										0, 0, 0, 1);

	matrix4x4::matrix4x4(GLfloat a, GLfloat b, GLfloat c, GLfloat d,
						 GLfloat e, GLfloat f, GLfloat g, GLfloat h,
						 GLfloat i, GLfloat j, GLfloat k, GLfloat l,
						 GLfloat m, GLfloat n, GLfloat o, GLfloat p)
	{
		this->a = a; this->b = b; this->c = c; this->d = d;
		this->e = e; this->f = f; this->g = g; this->h = h;
		this->i = i; this->j = j; this->k = k; this->l = l;
		this->m = m; this->n = n; this->o = o; this->p = p;
	}

	void matrix4x4::load_scale(vector3 const& v)
	{
		a = v.x;	b = 0;		c = 0;		d = 0;
		e = 0;		f = v.y;	g = 0;		h = 0;
		i = 0;		j = 0;		k = v.z;	l = 0;
		m = 0;		n = 0;		o = 0;		p = 1;
	}
	
	void matrix4x4::load_translation(vector3 const& v)
	{
		a = 1;   b = 0;   c = 0;   d = 0;
		e = 0;   f = 1;   g = 0;   h = 0;
		i = 0;   j = 0;   k = 1;   l = 0;	
		m = v.x; n = v.y; o = v.z; p = 1;
	}
	
	void matrix4x4::load_rotation_x(GLfloat radians)
	{
		GLfloat cr = cosf(radians);
		GLfloat sr = sinf(radians);
		
		a = 1; b = 0;	c = 0;	d = 0;
		e = 0; f = cr;	g = sr; h = 0;
		i = 0; j = -sr;	k = cr; l = 0;	
		m = 0; n = 0;	o = 0;	p = 1;
	}
	
	void matrix4x4::load_rotation_y(GLfloat radians)
	{
		GLfloat cr = cosf(radians);
		GLfloat sr = sinf(radians);
		
		a = cr; b = 0; c = -sr; d = 0;
		e = 0;	f = 1; g = 0;	h = 0;
		i = sr; j = 0; k = cr;	l = 0;	
		m = 0;	n = 0; o = 0;	p = 1;
	}
	
	void matrix4x4::load_rotation_z(GLfloat radians)
	{
		GLfloat cr = cosf(radians);
		GLfloat sr = sinf(radians);
		
		a = cr;  b = sr; c = 0; d = 0;
		e = -sr; f = cr; g = 0; h = 0;
		i = 0;   j = 0;  k = 1; l = 0;	
		m = 0;   n = 0;  o = 0; p = 1;
	}

	void matrix4x4::translate(vector3 const& v)
	{
		m = a * v.x + e * v.y + i * v.z + m;
		n = b * v.x + f * v.y + j * v.z + n;
		o = c * v.x + g * v.y + k * v.z + o;
		p = d * v.x + h * v.y + l * v.z + p;
	}

	void matrix4x4::look_at(vector3 const& eye, vector3 const& center, vector3 const& upvec)
	{
		vector3 forward = (center - eye).normalized();
		vector3 side = forward.cross(upvec).normalized();
		vector3 up = side.cross(forward);
		
		matrix4x4 matrix2;

		matrix2[0] = side.x;
		matrix2[4] = side.y;
		matrix2[8] = side.z;
		matrix2[12] = 0;
		
		matrix2[1] = up.x;
		matrix2[5] = up.y;
		matrix2[9] = up.z;
		matrix2[13] = 0;
		
		matrix2[2] = -forward.x;
		matrix2[6] = -forward.y;
		matrix2[10] = -forward.z;
		matrix2[14] = 0;
		
		matrix2[3] = matrix2[7] = matrix2[11] = 0;
		matrix2[15] = 1;
		
		matrix4x4 resultMatrix = *this * matrix2;
		resultMatrix.translate(-eye);
		
		*this = resultMatrix;
	}
	
	matrix4x4 matrix4x4::operator*(matrix4x4 const& b) const
	{
		matrix4x4 m;
		matrix4x4 const& a = *this;
		
		m[0]  = a[0] * b[0]  + a[4] * b[1]  + a[8] * b[2]   + a[12] * b[3];
		m[1]  = a[1] * b[0]  + a[5] * b[1]  + a[9] * b[2]   + a[13] * b[3];
		m[2]  = a[2] * b[0]  + a[6] * b[1]  + a[10] * b[2]  + a[14] * b[3];
		m[3]  = a[3] * b[0]  + a[7] * b[1]  + a[11] * b[2]  + a[15] * b[3];
		
		m[4]  = a[0] * b[4]  + a[4] * b[5]  + a[8] * b[6]   + a[12] * b[7];
		m[5]  = a[1] * b[4]  + a[5] * b[5]  + a[9] * b[6]   + a[13] * b[7];
		m[6]  = a[2] * b[4]  + a[6] * b[5]  + a[10] * b[6]  + a[14] * b[7];
		m[7]  = a[3] * b[4]  + a[7] * b[5]  + a[11] * b[6]  + a[15] * b[7];
		
		m[8]  = a[0] * b[8]  + a[4] * b[9]  + a[8] * b[10]  + a[12] * b[11];
		m[9]  = a[1] * b[8]  + a[5] * b[9]  + a[9] * b[10]  + a[13] * b[11];
		m[10] = a[2] * b[8]  + a[6] * b[9]  + a[10] * b[10] + a[14] * b[11];
		m[11] = a[3] * b[8]  + a[7] * b[9]  + a[11] * b[10] + a[15] * b[11];
		
		m[12] = a[0] * b[12] + a[4] * b[13] + a[8] * b[14]  + a[12] * b[15];
		m[13] = a[1] * b[12] + a[5] * b[13] + a[9] * b[14]  + a[13] * b[15];
		m[14] = a[2] * b[12] + a[6] * b[13] + a[10] * b[14] + a[14] * b[15];
		m[15] = a[3] * b[12] + a[7] * b[13] + a[11] * b[14] + a[15] * b[15];
		
		return m;
	}
	
	void matrix4x4::load_perspective(float fovRadians, float aspect, float near, float far)
	{
		float ff = 1 / tanf(fovRadians / 2);
		
		a = ff / aspect;
		b = 0;
		c = 0;
		d = 0;
		
		e = 0;
		f = ff;
		g = 0;
		h = 0;
		
		i = 0;
		j = 0;
		k = (far + near) / (near - far);
		l = -1.0f;
		
		m = 0;
		n = 0;
		o = 2 * far * near /  (near - far);
		p = 0;
	}
	
	void matrix4x4::load_ortho(float left, float right, float bottom, float top, float near, float far)
	{
		float r_l = right - left;
		float t_b = top - bottom;
		float f_n = far - near;
		float tx = - (right + left) / (right - left);
		float ty = - (top + bottom) / (top - bottom);
		float tz = - (far + near) / (far - near);
		
		a = 2 / r_l;
		b = 0;
		c = 0;
		d = 0;
		
		e = 0;
		f = 2 / t_b;
		g = 0;
		h = 0;
		
		i = 0;
		j = 0;
		k = -2 / f_n;
		l = 0;
		
		m = tx;
		n = ty;
		o = tz;
		p = 1;
	}
}