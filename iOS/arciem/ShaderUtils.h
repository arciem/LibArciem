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

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

GLint CompileShader(GLuint *shader, GLenum type, GLsizei count, NSString *file);
GLint LinkProgram(GLuint prog);
GLint ValidateProgram(GLuint prog);
void DestroyShaders(GLuint vertShader, GLuint fragShader, GLuint prog);
