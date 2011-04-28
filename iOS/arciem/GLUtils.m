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

#import "GLUtils.h"

/* Create and compile a shader from the provided source(s) */
GLint CompileShader(GLuint *shader, GLenum type, GLsizei count, NSString *file)
{
	GLint status;
	const GLchar *sources;
	
	// get source code
	sources = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
	if (!sources)
	{
		CLogError(nil, @"Failed to load vertex shader");
		return 0;
	}
	
    *shader = glCreateShader(type);				// create shader
    glShaderSource(*shader, 1, &sources, NULL);	// set source code in the shader
    glCompileShader(*shader);					// compile shader
	
	if(CLogIsTagActive(@"SHADER_DEBUG")) {
		GLint logLength;
		glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
		if (logLength > 0)
		{
			GLchar *log = (GLchar *)malloc(logLength);
			glGetShaderInfoLog(*shader, logLength, &logLength, log);
			CLogInfo(@"SHADER_DEBUG", @"Shader compile log:\n%s", log);
			free(log);
		}
	}
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE)
	{
		CLogError(nil, @"Failed to compile shader:\n");
		int i;
		for (i = 0; i < count; i++)
			CLogError(nil, @"%s", sources[i]);
	}
	
	return status;
}


/* Link a program with all currently attached shaders */
GLint LinkProgram(GLuint prog)
{
	GLint status;
	
	glLinkProgram(prog);
	
	if(CLogIsTagActive(@"SHADER_DEBUG")) {
		GLint logLength;
		glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
		if (logLength > 0)
		{
			GLchar *log = (GLchar *)malloc(logLength);
			glGetProgramInfoLog(prog, logLength, &logLength, log);
			CLogInfo(@"SHADER_DEBUG", @"Program link log:\n%s", log);
			free(log);
		}
	}
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == GL_FALSE)
		CLogError(nil, @"Failed to link program %d", prog);
	
	return status;
}


/* Validate a program (for i.e. inconsistent samplers) */
GLint ValidateProgram(GLuint prog)
{
	GLint logLength, status;

	if(CLogIsTagActive(@"SHADER_DEBUG")) {
		glValidateProgram(prog);
		glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
		if (logLength > 0)
		{
			GLchar *log = (GLchar *)malloc(logLength);
			glGetProgramInfoLog(prog, logLength, &logLength, log);
			CLogInfo(@"SHADER_DEBUG", @"Program validate log:\n%s", log);
			free(log);
		}
	}
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == GL_FALSE)
		CLogError(nil, @"Failed to validate program %d", prog);
	
	return status;
}

/* delete shader resources */
void DestroyShaders(GLuint vertShader, GLuint fragShader, GLuint prog)
{	
	if (vertShader) {
		glDeleteShader(vertShader);
		vertShader = 0;
	}
	if (fragShader) {
		glDeleteShader(fragShader);
		fragShader = 0;
	}
	if (prog) {
		glDeleteProgram(prog);
		prog = 0;
	}
}

GLint GetRenderbufferWidth()
{
	GLint val;
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &val);
	return val;
}

GLint GetRenderbufferHeight()
{
	GLint val;
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &val);
	return val;
}

GLuint GenFrameBuffer()
{
	GLuint name;
	glGenFramebuffers(1, &name);
	return name;
}

GLuint GenRenderBuffer()
{
	GLuint name;
	glGenRenderbuffers(1, &name);
	return name;
}

void DeleteFramebuffer(GLuint buf)
{
	glDeleteFramebuffers(1, &buf);
}

void DeleteRenderbuffer(GLuint buf)
{
	glDeleteRenderbuffers(1, &buf);
}
