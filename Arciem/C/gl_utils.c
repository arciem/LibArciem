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
#include "math_utils.h"

namespace arciem {

	GLfloat circularInterpolate(GLfloat fraction, GLfloat a, GLfloat b);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wglobal-constructors"
	const vector2 vector2::zero (0, 0);
	const vector2 vector2::one  (1, 1);
	const vector2 vector2::right(1, 0);
	const vector2 vector2::up   (0, 1);

	const vector3 vector3::zero   (0, 0, 0);
	const vector3 vector3::one    (1, 1, 1);
	const vector3 vector3::right  (1, 0, 0);
	const vector3 vector3::up     (0, 1, 0);
	const vector3 vector3::forward(0, 0, 1);
#pragma clang diagnostic pop

	vector3::vector3(vector4 const& v) : x(v.x), y(v.y), z(v.z) { }

	vector3 vector3::cross(vector3 const& p1, vector3 const& p2) const
	{
		vector3 v1 = p1 - *this;
		vector3 v2 = p2 - *this;
		return v1.cross(v2);
	}

	vector3 vector3::lerp(vector3 const& v, GLfloat t) const
	{
		return vector3(
		   denormalize(t, x, v.x),
		   denormalize(t, y, v.y),
		   denormalize(t, z, v.z)
		);
	}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wglobal-constructors"
	const vector4 vector4::zero(0, 0, 0, 0);
	const vector4 vector4::one (1, 1, 1, 1);
#pragma clang diagnostic pop

	color::color(color_hsb const& c)
	: a(c.a)
	{
		GLfloat v = c.b;
		if(c.s == 0.0) {
			r = g = b = v;
		} else {
			GLfloat h = c.h;
			GLfloat s = c.s;
			if(h == 1.0) h = 0.0;
			h *= 6.0;
			int i = (int)floor(h);
			GLfloat f = h - i;
			GLfloat p = v * (1.0 - s);
			GLfloat q = v * (1.0 - (s * f));
			GLfloat t = v * (1.0 - (s * (1.0 - f)));
			switch(i) {
				case 0: r = v; g = t; b = p; break;
				case 1: r = q; g = v; b = p; break;
				case 2: r = p; g = v; b = t; break;
				case 3: r = p; g = q; b = v; break;
				case 4: r = t; g = p; b = v; break;
				case 5: r = v; g = p; b = q; break;
			}
		}
	}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wglobal-constructors"
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
#pragma clang diagnostic pop

	color_hsb::color_hsb(color const& c)
	: a(c.a)
	{
		GLfloat cMax = fmaxf(c.r, fmaxf(c.g, c.b));
		GLfloat cMin = fminf(c.r, fminf(c.g, c.b));
		
		b = cMax;
		
		s = (cMax == 0.0) ? 0.0 : ((cMax - cMin) / cMax);
		
		if(s == 0.0) {
			h = 0.0;
		} else {
			GLfloat cDelta = cMax - cMin;
			if(c.r >= cMax) {
				h = (c.g - c.b) / cDelta;
			} else if(c.g >= cMax) {
				h = 2.0 + (c.b - c.r) / cDelta;
			} else if(c.b >= cMax) {
				h = 4.0 + (c.r - c.g) / cDelta;
			}
			h /= 6.0;
			if(h < 0.0) h += 1.0;
		}
	}
	
	GLfloat circularInterpolate(GLfloat fraction, GLfloat a, GLfloat b)
	{
		if(fabs(b - a) <= 0.5) {
			return denormalize(fraction, a, b);
		} else {
			GLfloat s;
			if(a <= b) {
				s = denormalize(fraction, a, b - 1.0f);
				if(s < 0.0) s += 1.0;
			} else {
				s = denormalize(fraction, a, b + 1.0f);
				if(s >= 1.0) s -= 1.0;
			}
			return s;
		}
	}
	
	color_hsb color_hsb::interpolate(color_hsb const& c, GLfloat fraction) const
	{
		color_hsb c1 = *this;
		color_hsb c2 = c;
		if(c1.s == 0.0) {
			c1.h = c2.h;
		} else if(c2.s == 0.0) {
			c2.h = c1.h;
		}
		
		return color_hsb(
						 circularInterpolate(fraction, c1.h, c2.h),
						 denormalize(fraction, c1.s, c2.s),
						 denormalize(fraction, c1.b, c2.b),
						 denormalize(fraction, c1.a, c2.a)
						 );
	}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wglobal-constructors"
	const matrix4x4 matrix4x4::zero(0, 0, 0, 0,
									0, 0, 0, 0,
									0, 0, 0, 0,
									0, 0, 0, 0);
	
	const matrix4x4 matrix4x4::identity(1, 0, 0, 0,
										0, 1, 0, 0,
										0, 0, 1, 0,
										0, 0, 0, 1);
#pragma clang diagnostic pop

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
		m = a*v.x + e*v.y + i*v.z + m;
		n = b*v.x + f*v.y + j*v.z + n;
		o = c*v.x + g*v.y + k*v.z + o;
		p = d*v.x + h*v.y + l*v.z + p;
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
		
		m.a = a.a*b.a + a.e*b.b + a.i*b.c + a.m*b.d;
		m.b = a.b*b.a + a.f*b.b + a.j*b.c + a.n*b.d;
		m.c = a.c*b.a + a.g*b.b + a.k*b.c + a.o*b.d;
		m.d = a.d*b.a + a.h*b.b + a.l*b.c + a.p*b.d;
		m.e = a.a*b.e + a.e*b.f + a.i*b.g + a.m*b.h;
		m.f = a.b*b.e + a.f*b.f + a.j*b.g + a.n*b.h;
		m.g = a.c*b.e + a.g*b.f + a.k*b.g + a.o*b.h;
		m.h = a.d*b.e + a.h*b.f + a.l*b.g + a.p*b.h;
		m.i = a.a*b.i + a.e*b.j + a.i*b.k + a.m*b.l;
		m.j = a.b*b.i + a.f*b.j + a.j*b.k + a.n*b.l;
		m.k = a.c*b.i + a.g*b.j + a.k*b.k + a.o*b.l;
		m.l = a.d*b.i + a.h*b.j + a.l*b.k + a.p*b.l;
		m.m = a.a*b.m + a.e*b.n + a.i*b.o + a.m*b.p;
		m.n = a.b*b.m + a.f*b.n + a.j*b.o + a.n*b.p;
		m.o = a.c*b.m + a.g*b.n + a.k*b.o + a.o*b.p;
		m.p = a.d*b.m + a.h*b.n + a.l*b.o + a.p*b.p;

		return m;
	}
	
	vector4 matrix4x4::operator*(vector4 const& v) const
	{
#if 0
		return vector4(a*v.x + b*v.y + c*v.z + d*v.w,
					   e*v.x + f*v.y + g*v.z + h*v.w,
					   i*v.x + j*v.y + k*v.z + l*v.w,
					   m*v.x + n*v.y + o*v.z + p*v.w);
#endif
		return vector4(a*v.x + e*v.y + i*v.z + m*v.w,
					   b*v.x + f*v.y + j*v.z + n*v.w,
					   c*v.x + g*v.y + k*v.z + o*v.w,
					   d*v.x + h*v.y + l*v.z + p*v.w);
	}

	GLfloat matrix4x4::determinant() const
	{
		return d*g*j*m - c*h*j*m - d*f*k*m + b*h*k*m + c*f*l*m - b*g*l*m - d*g*i*n + c*h*i*n + d*e*k*n - a*h*k*n - c*e*l*n + a*g*l*n + d*f*i*o - b*h*i*o - d*e*j*o + a*h*j*o + b*e*l*o - a*f*l*o - c*f*i*p + b*g*i*p + c*e*j*p - a*g*j*p - b*e*k*p + a*f*k*p;
	}

	matrix4x4 matrix4x4::inverse() const
	{
		float v1 = 1 / determinant();

		return matrix4x4(
			(-(h*k*n) + g*l*n + h*j*o - f*l*o - g*j*p + f*k*p) * v1,
			(d*k*n - c*l*n - d*j*o + b*l*o + c*j*p - b*k*p) * v1,
			(-(d*g*n) + c*h*n + d*f*o - b*h*o - c*f*p + b*g*p) * v1,
			(d*g*j - c*h*j - d*f*k + b*h*k + c*f*l - b*g*l) * v1,
			
			(h*k*m - g*l*m - h*i*o + e*l*o + g*i*p - e*k*p) * v1,
			(-(d*k*m) + c*l*m + d*i*o - a*l*o - c*i*p + a*k*p) * v1,
			(d*g*m - c*h*m - d*e*o + a*h*o + c*e*p - a*g*p) * v1,
			(-(d*g*i) + c*h*i + d*e*k - a*h*k - c*e*l + a*g*l) * v1,
			
			(-(h*j*m) + f*l*m + h*i*n - e*l*n - f*i*p + e*j*p) * v1,
			(d*j*m - b*l*m - d*i*n + a*l*n + b*i*p - a*j*p) * v1,
			(-(d*f*m) + b*h*m + d*e*n - a*h*n - b*e*p + a*f*p) * v1,
			(d*f*i - b*h*i - d*e*j + a*h*j + b*e*l - a*f*l) * v1,
			
			(g*j*m - f*k*m - g*i*n + e*k*n + f*i*o - e*j*o) * v1,
			(-(c*j*m) + b*k*m + c*i*n - a*k*n - b*i*o + a*j*o) * v1,
			(c*f*m - b*g*m - c*e*n + a*g*n + b*e*o - a*f*o) * v1,
			(-(c*f*i) + b*g*i + c*e*j - a*g*j - b*e*k + a*f*k) * v1
		);
	}
	
	matrix4x4 matrix4x4::transpose() const
	{
		return matrix4x4(
			a,e,i,m,
			b,f,j,n,
			c,g,k,o,
			d,h,l,p
		);
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
		o = 2 * far * near / (near - far);
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wglobal-constructors"
	const matrix3x3 matrix3x3::zero(0, 0, 0,
									0, 0, 0,
									0, 0, 0);

	const matrix3x3 matrix3x3::identity(1, 0, 0,
										0, 1, 0,
										0, 0, 1);
#pragma clang diagnostic pop
	
	matrix3x3::matrix3x3(GLfloat a, GLfloat b, GLfloat c,
						 GLfloat d, GLfloat e, GLfloat f,
						 GLfloat g, GLfloat h, GLfloat i)
	{
		this->a = a; this->b = b; this->c = c;
		this->d = d; this->e = e; this->f = f;
		this->g = g; this->h = h; this->i = i;
	}
	
	void matrix3x3::load_scale(vector2 const& v)
	{
		a = v.x;	b = 0;		c = 0;
		d = 0;		e = v.y;	f = 0;
		g = 0;		h = 0;		i = 1;
	}
	
	void matrix3x3::load_translation(vector2 const& v)
	{
		a = 1;   b = 0;   c = 0;
		d = 0;   e = 1;   f = 0;
		g = v.x; h = v.y; i = 1;
	}
	
	void matrix3x3::load_rotation(GLfloat radians)
	{
		GLfloat cr = cosf(radians);
		GLfloat sr = sinf(radians);
		
		a = cr;  b = sr; c = 0;
		d = -sr; e = cr; f = 0;
		g = 0;   h = 0;  i = 1;
	}
	
	void matrix3x3::translate(vector2 const& v)
	{
		g = a*v.x + d*v.y + g;
		h = b*v.x + e*v.y + h;
		i = c*v.x + f*v.y + i;
	}
	
	matrix3x3 matrix3x3::operator*(matrix3x3 const& b) const
	{
		matrix3x3 m;
		matrix3x3 const& a = *this;
		
		m.a = a.a*b.a + a.d*b.b + a.g*b.c;
		m.b = a.b*b.a + a.e*b.b + a.h*b.c;
		m.c = a.c*b.a + a.f*b.b + a.i*b.c;
		m.d = a.a*b.d + a.d*b.e + a.g*b.f;
		m.e = a.b*b.d + a.e*b.e + a.h*b.f;
		m.f = a.c*b.d + a.f*b.e + a.i*b.f;
		m.g = a.a*b.g + a.d*b.h + a.g*b.i;
		m.h = a.b*b.g + a.e*b.h + a.h*b.i;
		m.i = a.c*b.g + a.f*b.h + a.i*b.i;
		
		return m;
	}
	
	vector3 matrix3x3::operator*(vector3 const& v) const
	{
#if 0
		return vector3(
			a*v.x + b*v.y + c*v.z,
			d*v.x + e*v.y + f*v.z,
			g*v.x + h*v.y + i*v.z
		);
#endif
		return vector3(
					   a*v.x + d*v.y + g*v.z,
					   b*v.x + e*v.y + h*v.z,
					   c*v.x + f*v.y + i*v.z
					   );
	}
	
	GLfloat matrix3x3::determinant() const
	{
		return -(c*e*g) + b*f*g + c*d*h - a*f*h - b*d*i + a*e*i;
	}

	matrix3x3 matrix3x3::inverse() const
	{
		GLfloat v1 = 1 / determinant();

		return matrix3x3(
			(-(f*h) + e*i) * v1,
			(c*h - b*i) * v1,
			(-(c*e) + b*f) * v1,
			
			(f*g - d*i) * v1,
			(-(c*g) + a*i) * v1,
			(c*d - a*f) * v1,
			
			(-(e*g) + d*h) * v1,
			(b*g - a*h) * v1,
			(-(b*d) + a*e) * v1
		);
	}
	
	matrix3x3 matrix3x3::transpose() const
	{
		return matrix3x3(
			a,d,g,
			b,e,h,
			c,f,i
		);
	}

	matrix3x3 upper_left_submatrix(matrix4x4 const& m)
	{
		return matrix3x3(
			m.a, m.b, m.c,
			m.e, m.f, m.g,
			m.i, m.j, m.k
		);
	}

	matrix3x3 normal_matrix(matrix4x4 const& modelView)
	{
		// http://www.lighthouse3d.com/tutorials/glsl-tutorial/directional-lights-i/
		return upper_left_submatrix(modelView).inverse().transpose();
	}
}