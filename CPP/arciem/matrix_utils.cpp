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

#include <string.h>
#include <math.h>
#include "matrix_utils.hpp"


void mat4f_LoadIdentity(float* m)
{
	m[0] = 1.0f;
	m[1] = 0.0f;
	m[2] = 0.0f;
	m[3] = 0.0f;
	
	m[4] = 0.0f;
	m[5] = 1.0f;
	m[6] = 0.0f;
	m[7] = 0.0f;
	
	m[8] = 0.0f;
	m[9] = 0.0f;
	m[10] = 1.0f;
	m[11] = 0.0f;	

	m[12] = 0.0f;
	m[13] = 0.0f;
	m[14] = 0.0f;
	m[15] = 1.0f;
}

// s is a 3D vector
void mat4f_LoadScale(const float* s, float* m)
{
	m[0] = s[0];
	m[1] = 0.0f;
	m[2] = 0.0f;
	m[3] = 0.0f;
	
	m[4] = 0.0f;
	m[5] = s[1];
	m[6] = 0.0f;
	m[7] = 0.0f;
	
	m[8] = 0.0f;
	m[9] = 0.0f;
	m[10] = s[2];
	m[11] = 0.0f;	
	
	m[12] = 0.0f;
	m[13] = 0.0f;
	m[14] = 0.0f;
	m[15] = 1.0f;
}

void mat4f_LoadXRotation(float radians, float* m)
{
	float cosrad = cosf(radians);
	float sinrad = sinf(radians);
	
	m[0] = 1.0f;
	m[1] = 0.0f;
	m[2] = 0.0f;
	m[3] = 0.0f;
	
	m[4] = 0.0f;
	m[5] = cosrad;
	m[6] = sinrad;
	m[7] = 0.0f;
	
	m[8] = 0.0f;
	m[9] = -sinrad;
	m[10] = cosrad;
	m[11] = 0.0f;	
	
	m[12] = 0.0f;
	m[13] = 0.0f;
	m[14] = 0.0f;
	m[15] = 1.0f;
}

void mat4f_LoadYRotation(float radians, float* mout)
{
	float cosrad = cosf(radians);
	float sinrad = sinf(radians);
	
	mout[0] = cosrad;
	mout[1] = 0.0f;
	mout[2] = -sinrad;
	mout[3] = 0.0f;
	
	mout[4] = 0.0f;
	mout[5] = 1.0f;
	mout[6] = 0.0f;
	mout[7] = 0.0f;
	
	mout[8] = sinrad;
	mout[9] = 0.0f;
	mout[10] = cosrad;
	mout[11] = 0.0f;	
	
	mout[12] = 0.0f;
	mout[13] = 0.0f;
	mout[14] = 0.0f;
	mout[15] = 1.0f;
}

void mat4f_LoadZRotation(float radians, float* mout)
{
	float cosrad = cosf(radians);
	float sinrad = sinf(radians);
	
	mout[0] = cosrad;
	mout[1] = sinrad;
	mout[2] = 0.0f;
	mout[3] = 0.0f;
	
	mout[4] = -sinrad;
	mout[5] = cosrad;
	mout[6] = 0.0f;
	mout[7] = 0.0f;
	
	mout[8] = 0.0f;
	mout[9] = 0.0f;
	mout[10] = 1.0f;
	mout[11] = 0.0f;	
	
	mout[12] = 0.0f;
	mout[13] = 0.0f;
	mout[14] = 0.0f;
	mout[15] = 1.0f;
}

// v is a 3D vector
void mat4f_LoadTranslation(const float* v, float* mout)
{
	mout[0] = 1.0f;
	mout[1] = 0.0f;
	mout[2] = 0.0f;
	mout[3] = 0.0f;
	
	mout[4] = 0.0f;
	mout[5] = 1.0f;
	mout[6] = 0.0f;
	mout[7] = 0.0f;
	
	mout[8] = 0.0f;
	mout[9] = 0.0f;
	mout[10] = 1.0f;
	mout[11] = 0.0f;	
	
	mout[12] = v[0];
	mout[13] = v[1];
	mout[14] = v[2];
	mout[15] = 1.0f;
}

void vec3f_Normalize(float* vec)
{
	float d = 1.0f / sqrtf(vec[0] * vec[0] + vec[1] * vec[1] + vec[2] * vec[2]);
	vec[0] *= d;
	vec[1] *= d;
	vec[2] *= d;
}

void vec3f_Subtract(const float* vec1, const float* vec2, float* vout)
{
	vout[0] = vec1[0] - vec2[0];
	vout[1] = vec1[1] - vec2[1];
	vout[2] = vec1[2] - vec2[2];
}

void vec3f_ComputeNormal(const float* vec1, const float* vec2, float* vout)
{
	vout[0] = (vec1[1] * vec2[2]) - (vec1[2] * vec2[1]);
	vout[1] = (vec1[2] * vec2[0]) - (vec1[0] * vec2[2]);
	vout[2] = (vec1[0] * vec2[1]) - (vec1[1] * vec2[0]);
}

void vec3f_ComputeNormal(const float* p1, const float* p2, const float* p3, float* vout)
{
	float v1[3], v2[3];
	vec3f_Subtract(p2, p1, v1);
	vec3f_Subtract(p3, p1, v2);
	vec3f_ComputeNormal(v1, v2, vout);
}

void vec3f_Assign(float x, float y, float z, float* vout)
{
	vout[0] = x;
	vout[1] = y;
	vout[2] = z;
}

void mat4f_Translate(float x, float y, float z, float *matrix)
{
	matrix[12]=matrix[0]*x+matrix[4]*y+matrix[8]*z+matrix[12];
	matrix[13]=matrix[1]*x+matrix[5]*y+matrix[9]*z+matrix[13];
	matrix[14]=matrix[2]*x+matrix[6]*y+matrix[10]*z+matrix[14];
	matrix[15]=matrix[3]*x+matrix[7]*y+matrix[11]*z+matrix[15];
}

void mat4f_LookAt(const float* eye, const float* center, const float* upvec, float *mout)
{
	float forward[3], side[3], up[3];
	float matrix2[16], resultMatrix[16];
	
	forward[0]=center[0]-eye[0];
	forward[1]=center[1]-eye[1];
	forward[2]=center[2]-eye[2];
	vec3f_Normalize(forward);
	
	//Side = forward x up
	vec3f_ComputeNormal(forward, upvec, side);
	vec3f_Normalize(side);
	
	//Recompute up as: up = side x forward
	vec3f_ComputeNormal(side, forward, up);
	
	matrix2[0]=side[0];
	matrix2[4]=side[1];
	matrix2[8]=side[2];
	matrix2[12]=0.0;
	
	matrix2[1]=up[0];
	matrix2[5]=up[1];
	matrix2[9]=up[2];
	matrix2[13]=0.0;
	
	matrix2[2]=-forward[0];
	matrix2[6]=-forward[1];
	matrix2[10]=-forward[2];
	matrix2[14]=0.0;
	
	matrix2[3]=matrix2[7]=matrix2[11]=0.0;
	matrix2[15]=1.0;
	
	mat4f_MultiplyMat4f(mout, matrix2, resultMatrix);
	mat4f_Translate(-eye[0], -eye[1], -eye[2], resultMatrix);
	
	memcpy(mout, resultMatrix, 16*sizeof(float));
}

void mat4f_LoadPerspective2(float fov_degrees, float aspect, float zNear, float zFar, float* mout)
{
	float ymax = zNear * tanf(fov_degrees * M_PI / 360.0);
	//ymin = -ymax;
	//xmin = -ymax * aspect;
	float xmax = ymax * aspect;
	mat4f_LoadFrustum(-xmax, xmax, -ymax, ymax, zNear, zFar, mout);
}

void mat4f_LoadFrustum(float left, float right, float bottom, float top, float zNear, float zFar, float* mout)
{
	float temp = 2.0 * zNear;
	float temp2 = right - left;
	float temp3 = top - bottom;
	float temp4 = zFar - zNear;
	mout[0] = temp / temp2;
	mout[1] = 0.0;
	mout[2] = 0.0;
	mout[3] = 0.0;
	mout[4] = 0.0;
	mout[5] = temp / temp3;
	mout[6] = 0.0;
	mout[7] = 0.0;
	mout[8] = (right + left) / temp2;
	mout[9] = (top + bottom) / temp3;
	mout[10] = (-zFar - zNear) / temp4;
	mout[11] = -1.0;
	mout[12] = 0.0;
	mout[13] = 0.0;
	mout[14] = (-temp * zFar) / temp4;
	mout[15] = 0.0;
}

void mat4f_LoadPerspective(float fov_radians, float aspect, float zNear, float zFar, float* mout)
{
	float f = 1.0f / tanf(fov_radians/2.0f);
	
	mout[0] = f / aspect;
	mout[1] = 0.0f;
	mout[2] = 0.0f;
	mout[3] = 0.0f;
	
	mout[4] = 0.0f;
	mout[5] = f;
	mout[6] = 0.0f;
	mout[7] = 0.0f;
	
	mout[8] = 0.0f;
	mout[9] = 0.0f;
	mout[10] = (zFar + zNear) / (zNear-zFar);
	mout[11] = -1.0f;
	
	mout[12] = 0.0f;
	mout[13] = 0.0f;
	mout[14] = 2 * zFar * zNear /  (zNear-zFar);
	mout[15] = 0.0f;
}

void mat4f_LoadOrtho(float left, float right, float bottom, float top, float near, float far, float* mout)
{
	float r_l = right - left;
	float t_b = top - bottom;
	float f_n = far - near;
	float tx = - (right + left) / (right - left);
	float ty = - (top + bottom) / (top - bottom);
	float tz = - (far + near) / (far - near);

	mout[0] = 2.0f / r_l;
	mout[1] = 0.0f;
	mout[2] = 0.0f;
	mout[3] = 0.0f;
	
	mout[4] = 0.0f;
	mout[5] = 2.0f / t_b;
	mout[6] = 0.0f;
	mout[7] = 0.0f;
	
	mout[8] = 0.0f;
	mout[9] = 0.0f;
	mout[10] = -2.0f / f_n;
	mout[11] = 0.0f;
	
	mout[12] = tx;
	mout[13] = ty;
	mout[14] = tz;
	mout[15] = 1.0f;
}

void mat4f_MultiplyMat4f(const float* a, const float* b, float* mout)
{
	mout[0]  = a[0] * b[0]  + a[4] * b[1]  + a[8] * b[2]   + a[12] * b[3];
	mout[1]  = a[1] * b[0]  + a[5] * b[1]  + a[9] * b[2]   + a[13] * b[3];
	mout[2]  = a[2] * b[0]  + a[6] * b[1]  + a[10] * b[2]  + a[14] * b[3];
	mout[3]  = a[3] * b[0]  + a[7] * b[1]  + a[11] * b[2]  + a[15] * b[3];

	mout[4]  = a[0] * b[4]  + a[4] * b[5]  + a[8] * b[6]   + a[12] * b[7];
	mout[5]  = a[1] * b[4]  + a[5] * b[5]  + a[9] * b[6]   + a[13] * b[7];
	mout[6]  = a[2] * b[4]  + a[6] * b[5]  + a[10] * b[6]  + a[14] * b[7];
	mout[7]  = a[3] * b[4]  + a[7] * b[5]  + a[11] * b[6]  + a[15] * b[7];

	mout[8]  = a[0] * b[8]  + a[4] * b[9]  + a[8] * b[10]  + a[12] * b[11];
	mout[9]  = a[1] * b[8]  + a[5] * b[9]  + a[9] * b[10]  + a[13] * b[11];
	mout[10] = a[2] * b[8]  + a[6] * b[9]  + a[10] * b[10] + a[14] * b[11];
	mout[11] = a[3] * b[8]  + a[7] * b[9]  + a[11] * b[10] + a[15] * b[11];

	mout[12] = a[0] * b[12] + a[4] * b[13] + a[8] * b[14]  + a[12] * b[15];
	mout[13] = a[1] * b[12] + a[5] * b[13] + a[9] * b[14]  + a[13] * b[15];
	mout[14] = a[2] * b[12] + a[6] * b[13] + a[10] * b[14] + a[14] * b[15];
	mout[15] = a[3] * b[12] + a[7] * b[13] + a[11] * b[14] + a[15] * b[15];
}
