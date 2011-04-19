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

#import <LibArciem/CLog.h>

static NSMutableSet* sLogTags = nil;
static CLogLevel sLogLevel = kLogWarn;

void CLogv(CLogLevel level, NSString *format, va_list args)
{
	if(level >= sLogLevel) {
		NSString* levelStr = nil;
		
		switch(level) {
			case kLogOff:
				levelStr = @"OFF";
				break;
			case kLogFatal:
				levelStr = @"FATAL";
				break;
			case kLogError:
				levelStr = @"ERROR";
				break;
			case kLogWarn:
				levelStr = @"WARN";
				break;
			case kLogInfo:
				levelStr = @"INFO";
				break;
			case kLogDebug:
				levelStr = @"DEBUG";
				break;
			case kLogTrace:
				levelStr = @"TRACE";
				break;
			case kLogAll:
				levelStr = @"ALL";
				break;
			default:
				levelStr = [NSString stringWithFormat:@"%d", level];
				break;
		}
		NSString* format2 = [NSString stringWithFormat:@"%@: %@", levelStr, format];
		NSLogv(format2, args);
	}
}

static NSMutableSet* getLogTags()
{
	if(sLogTags == nil) {
		sLogTags = [[NSMutableSet alloc] init];
	}
	
	return sLogTags;
}

void CLogSetTagActive(NSString* tag, BOOL active)
{
	if(active) {
		[getLogTags() addObject:tag];
	} else {
		[getLogTags() removeObject:tag];
	}
}

void CLogSetLevel(CLogLevel logLevel)
{
	sLogLevel = logLevel;
}

void _CLog(CLogLevel level, NSString *tag, NSString *format, va_list args)
{
	if(tag != nil) {
		if([getLogTags() containsObject:tag]) {
			NSString* format2 = [NSString stringWithFormat:@"[%@] %@", tag, format];
			CLogv(level, format2, args);
		}
	} else {
		CLogv(level, format, args);
	}
}

void CLog(CLogLevel level, NSString *tag, NSString *format, ...)
{
	va_list args;
	va_start(args, format);
	_CLog(level, tag, format, args);
}

void CLogFatal(NSString* tag, NSString *format, ...)
{
	va_list args;
	va_start(args, format);
	_CLog(kLogFatal, tag, format, args);
}

void CLogError(NSString* tag, NSString *format, ...)
{
	va_list args;
	va_start(args, format);
	_CLog(kLogError, tag, format, args);
}

void CLogWarn(NSString* tag, NSString *format, ...)
{
	va_list args;
	va_start(args, format);
	_CLog(kLogWarn, tag, format, args);
}

void CLogInfo(NSString* tag, NSString *format, ...)
{
	va_list args;
	va_start(args, format);
	_CLog(kLogInfo, tag, format, args);
}

void CLogDebug(NSString* tag, NSString *format, ...)
{
	va_list args;
	va_start(args, format);
	_CLog(kLogDebug, tag, format, args);
}

void CLogTrace(NSString* tag, NSString *format, ...)
{
	va_list args;
	va_start(args, format);
	_CLog(kLogTrace, tag, format, args);
}

