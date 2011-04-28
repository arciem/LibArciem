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

#import <Foundation/Foundation.h>

typedef enum {
	kLogOff = 2147483647,	// The OFF has the highest possible rank and is intended to turn off logging.
	kLogFatal = 50000,		// The FATAL level designates very severe error events that will presumably lead the application to abort.
	kLogError = 40000,		// The ERROR level designates error events that might still allow the application to continue running.
	kLogWarn = 30000,		// The WARN level designates potentially harmful situations.
	kLogInfo = 20000,		// The INFO level designates informational messages that highlight the progress of the application at coarse-grained level.
	kLogDebug = 10000,		// The DEBUG Level designates fine-grained informational events that are most useful to debug an application.
	kLogTrace = 5000,		// The TRACE Level designates finer-grained informational events than the DEBUG
	kLogAll = -2147483647	// The ALL has the lowest possible rank and is intended to turn on all logging.
} CLogLevel;

void CLogSetTagActive(NSString* tag, BOOL active);
BOOL CLogIsTagActive(NSString* tag);
void CLogSetLevel(CLogLevel logLevel);

// For any of the below methods to print to the console, both of the following conditions must hold:
//   1) The level argument must be >= the global loglevel set by CLogSetLevel (default is kLogWarn).
//   2) The tag argument must be nil, or must have been activated by CLogSetTagActive.
void CLog(CLogLevel level, NSString *tag, NSString *format, ...);
void CLogFatal(NSString* tag, NSString *format, ...);
void CLogError(NSString* tag, NSString *format, ...);
void CLogWarn(NSString* tag, NSString *format, ...);
void CLogInfo(NSString* tag, NSString *format, ...);
void CLogDebug(NSString* tag, NSString *format, ...);
void CLogTrace(NSString* tag, NSString *format, ...);
