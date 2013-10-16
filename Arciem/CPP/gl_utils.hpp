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

#ifndef ARCIEM_GL_UTILS_HPP
#define ARCIEM_GL_UTILS_HPP

#include <OpenGLES/ES2/gl.h>
#include <math.h>

namespace arciem {
	
	inline GLfloat to_radians(GLfloat d) { return d / 180.0f * M_PI; }
	inline GLfloat to_degrees(GLfloat r) { return r / M_PI * 180.0f; }
	
	struct vector2 {
		GLfloat x, y;
		
		vector2(GLfloat x = 0, GLfloat y = 0) : x(x), y(y) { }

		inline GLfloat operator[](int i) const { return (&x)[i]; }
		inline GLfloat& operator[](int i) { return (&x)[i]; }
		
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wfloat-equal"
		bool operator==(vector2 const& v) const { return x == v.x && y == v.y; }
		bool operator!=(vector2 const& v) const { return x != v.x || y != v.y; }
#pragma clang diagnostic pop
		vector2 operator+(vector2 const& v) const { return vector2(x + v.x, y + v.y); }
		vector2 operator-(vector2 const& v) const { return vector2(x - v.x, y - v.y); }
		vector2 operator*(vector2 const& v) const { return vector2(x * v.x, y * v.y); }
		vector2 operator/(vector2 const& v) const { return vector2(x / v.x, y / v.y); }

		vector2 operator*(GLfloat n) const { return vector2(x * n, y * n); }
		vector2 operator/(GLfloat n) const { return vector2(x / n, y / n); }

		vector2 operator-() const { return vector2(-x, -y); }

		GLfloat magnitude() const { return sqrtf(x*x + y*y); }
		GLfloat sqr_magnitude() const { return x*x + y*y; }
		vector2 normalized() const { return *this / magnitude(); }
		
		void normalize() { GLfloat m = magnitude(); x /= m; y /= m; }

		GLfloat distance(vector2 const& v) const { return (*this - v).magnitude(); }
		GLfloat dot(vector2 const& v) const { return x * v.x + y * v.y; }

		static const vector2 zero;
		static const vector2 one;
		static const vector2 right;
		static const vector2 up;
	};
	
	struct vector4;
	
	struct vector3 {
		GLfloat x, y, z;

		vector3(GLfloat x = 0, GLfloat y = 0, GLfloat z = 0) : x(x), y(y), z(z) { }
		vector3(vector2 const& v, GLfloat z = 0) : x(v.x), y(v.y), z(z) { }
		vector3(vector4 const& v);
		
		inline GLfloat operator[](int i) const { return (&x)[i]; }
		inline GLfloat& operator[](int i) { return (&x)[i]; }
		
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wfloat-equal"
		bool operator==(vector3 const& v) const { return x == v.x && y == v.y && z == v.z; }
		bool operator!=(vector3 const& v) const { return x != v.x || y != v.y || z != v.z; }
#pragma clang diagnostic pop
		vector3 operator+(vector3 const& v) const { return vector3(x + v.x, y + v.y, z + v.z); }
		vector3 operator-(vector3 const& v) const { return vector3(x - v.x, y - v.y, z - v.z); }
		vector3 operator*(vector3 const& v) const { return vector3(x * v.x, y * v.y, z * v.z); }
		vector3 operator/(vector3 const& v) const { return vector3(x / v.x, y / v.y, z / v.z); }

		vector3 operator*(GLfloat n) const { return vector3(x * n, y * n, z * n); }
		vector3 operator/(GLfloat n) const { return vector3(x / n, y / n, z / n); }
		
		vector3 operator-() const { return vector3(-x, -y, -z); }

		GLfloat magnitude() const { return sqrtf(x*x + y*y + z*z); }
		GLfloat sqr_magnitude() const { return x*x + y*y + z*z; }
		vector3 normalized() const { return *this / magnitude(); }

		void normalize() { GLfloat m = magnitude(); x /= m; y /= m; z /= m; }

		GLfloat distance(vector3 const& v) const { return (*this - v).magnitude(); }
		GLfloat dot(vector3 const& v) const { return x * v.x + y * v.y + z * v.z; }
		vector3 cross(vector3 const& v) const { return vector3(y * v.z - z * v.y, z * v.x - x * v.z, x * v.y - y * v.x); }
		vector3 cross(vector3 const& p1, vector3 const& p2) const;
		vector3 lerp(vector3 const& v, GLfloat t) const;

		static const vector3 zero;
		static const vector3 one;
		static const vector3 right;
		static const vector3 up;
		static const vector3 forward;
	};
	
	struct vector4 {
		GLfloat x, y, z, w;

		vector4(GLfloat x = 0, GLfloat y = 0, GLfloat z = 0, GLfloat w = 0) : x(x), y(y), z(z), w(w) { }
		vector4(vector3 const& v, GLfloat w = 0) : x(v.x), y(v.y), z(v.z), w(w) { }
		
		inline GLfloat operator[](int i) const { return (&x)[i]; }
		inline GLfloat& operator[](int i) { return (&x)[i]; }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wfloat-equal"
		bool operator==(vector4 const& v) const { return x == v.x && y == v.y && z == v.z && w == v.w; }
		bool operator!=(vector4 const& v) const { return x != v.x || y != v.y || z != v.z || w != v.w; }
#pragma clang diagnostic pop
		vector4 operator+(vector4 const& v) const { return vector4(x + v.x, y + v.y, z + v.z, w + v.w); }
		vector4 operator-(vector4 const& v) const { return vector4(x - v.x, y - v.y, z - v.z, w - v.w); }
		vector4 operator*(vector4 const& v) const { return vector4(x * v.x, y * v.y, z * v.z, w * v.w); }
		vector4 operator/(vector4 const& v) const { return vector4(x / v.x, y / v.y, z / v.z, w / v.w); }

		vector4 operator*(GLfloat n) const { return vector4(x * n, y * n, z * n, w * n); }
		vector4 operator/(GLfloat n) const { return vector4(x / n, y / n, z / n, w / n); }

		vector4 operator-() const { return vector4(-x, -y, -z, -w); }

		GLfloat magnitude() const { return sqrtf(x*x + y*y + z*z + w*w); }
		GLfloat sqr_magnitude() const { return x*x + y*y + z*z + w*w; }
		vector4 normalized() const { return *this / magnitude(); }

		void normalize() { GLfloat m = magnitude(); x /= m; y /= m; z /= m; w /= m; }

		GLfloat distance(vector4 const& v) const { return (*this - v).magnitude(); }
		GLfloat dot(vector4 const& v) const { return x * v.x + y * v.y + z * v.z + w * v.w; }

		static const vector4 zero;
		static const vector4 one;
	};

	struct color_hsb;

	struct color {
		GLfloat r, g, b, a;
		
		color(GLfloat r = 0, GLfloat g = 0, GLfloat b = 0, GLfloat a = 0) : r(r), g(g), b(b), a(a) { }
		color(vector4 const& v) :r(v.x), g(v.y), b(v.z), a(v.w) { }
		color(color_hsb const& c);
		
		inline GLfloat operator[](int i) const { return (&r)[i]; }
		inline GLfloat& operator[](int i) { return (&r)[i]; }
		
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wfloat-equal"
		bool operator==(color const& c) const { return r == c.r && g == c.g && b == c.b && a == c.a; }
		bool operator!=(color const& c) const { return r != c.r || g != c.g || b != c.b || a != c.a; }
#pragma clang diagnostic pop
		color operator+(color const& c) const { return color(r + c.r, g + c.g, b + c.b, a + c.a); }
		color operator-(color const& c) const { return color(r - c.r, g - c.g, b - c.b, a - c.a); }
		color operator*(color const& c) const { return color(r * c.r, g * c.g, b * c.b, a * c.a); }
		color operator/(color const& c) const { return color(r / c.r, g / c.g, b / c.b, a / c.a); }

		color operator*(GLfloat n) const { return color(r * n, g * n, b * n, a * n); }
		color operator/(GLfloat n) const { return color(r / n, g / n, b / n, a / n); }
		
		operator vector4() const { return vector4(r, g, b, a); }
		
		static const color red;
		static const color green;
		static const color blue;
		static const color cyan;
		static const color magenta;
		static const color yellow;
		static const color white;
		static const color black;
		static const color gray;
		static const color grey;
		static const color clear;
	};
	
	struct color_hsb {
		GLfloat h, s, b, a;
		
		color_hsb(GLfloat h = 0, GLfloat s = 0, GLfloat b = 0, GLfloat a = 0) : h(h), s(s), b(b), a(a) { }
		color_hsb(color const& c);
		
		color_hsb interpolate(color_hsb const& c, GLfloat fraction) const;
	};
	
	struct matrix4x4 {
		GLfloat a, b, c, d,  e, f, g, h,  i, j, k, l,  m, n, o, p;

		matrix4x4(void) { }
		matrix4x4(GLfloat a, GLfloat b, GLfloat c, GLfloat d,
				  GLfloat e, GLfloat f, GLfloat g, GLfloat h,
				  GLfloat i, GLfloat j, GLfloat k, GLfloat l,
				  GLfloat m, GLfloat n, GLfloat o, GLfloat p);

		inline GLfloat operator[](int i) const { return (&a)[i]; }
		inline GLfloat& operator[](int i) { return (&a)[i]; }
		
		void load_zero() { *this = zero; }
		void load_identity() { *this = identity; }
		void load_scale(vector3 const& v);
		void load_translation(vector3 const& v);
		void load_rotation_x(GLfloat radians);
		void load_rotation_y(GLfloat radians);
		void load_rotation_z(GLfloat radians);

		void translate(vector3 const& v);
		
		static const matrix4x4 zero;
		static const matrix4x4 identity;

		matrix4x4 operator*(matrix4x4 const& b) const;
		vector4 operator*(vector4 const& v) const;
		GLfloat determinant() const;
		matrix4x4 inverse() const;
		matrix4x4 transpose() const;

		void look_at(vector3 const& eye, vector3 const& center, vector3 const& upvec);
		void load_perspective(float fovRadians, float aspect, float zNear, float zFar);
		void load_ortho(float left, float right, float bottom, float top, float near, float far);
	};
	
	struct matrix3x3 {
		GLfloat a, b, c,  d, e, f,  g, h, i;
		
		matrix3x3(void) { }
		matrix3x3(GLfloat a, GLfloat b, GLfloat c,
				  GLfloat d, GLfloat e, GLfloat f,
				  GLfloat g, GLfloat h, GLfloat i);

		inline GLfloat operator[](int i) const { return (&a)[i]; }
		inline GLfloat& operator[](int i) { return (&a)[i]; }

		void load_zero() { *this = zero; }
		void load_identity() { *this = identity; }
		void load_scale(vector2 const& v);
		void load_translation(vector2 const& v);
		void load_rotation(GLfloat radians);

		void translate(vector2 const& v);

		static const matrix3x3 zero;
		static const matrix3x3 identity;

		matrix3x3 operator*(matrix3x3 const& b) const;
		vector3 operator*(vector3 const& v) const;
		GLfloat determinant() const;
		matrix3x3 inverse() const;
		matrix3x3 transpose() const;

	};
	
	matrix3x3 upper_left_submatrix(matrix4x4 const& m);
	matrix3x3 normal_matrix(matrix4x4 const& modelView);

} // namespace

#endif // ARCIEM_GL_UTILS_HPP