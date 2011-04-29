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

#ifndef ARCIEM_MATRIX_UTILS_HPP
#define ARCIEM_MATRIX_UTILS_HPP

void mat4f_LoadIdentity(float* m);
void mat4f_LoadScale(const float* s, float* m);

void mat4f_LoadXRotation(float radians, float* mout);
void mat4f_LoadYRotation(float radians, float* mout);
void mat4f_LoadZRotation(float radians, float* mout);

void mat4f_LoadTranslation(const float* t, float* mout);

void mat4f_LoadPerspective(float fov_radians, float aspect, float zNear, float zFar, float* mout);
void mat4f_LoadOrtho(float left, float right, float bottom, float top, float near, float far, float* mout);

void mat4f_LoadPerspective2(float fov_degrees, float aspect, float zNear, float zFar, float* mout);
void mat4f_LoadFrustum(float left, float right, float bottom, float top, float zNear, float zFar, float* mout);

void mat4f_MultiplyMat4f(const float* a, const float* b, float* mout);

void vec3f_Normalize(float* vec);
void vec3f_ComputeNormal(const float* vec1, const float* vec2, float* vout);
void vec3f_ComputeNormal(const float* p1, const float* p2, const float* p3, float* vout);
void vec3f_Assign(float x, float y, float z, float* vout);

void mat4f_Translate(float x, float y, float z, float *matrix);
void mat4f_LookAt(const float* eye, const float* center, const float* upvec, float *mout);

#endif /* ARCIEM_MATRIX_UTILS_HPP */