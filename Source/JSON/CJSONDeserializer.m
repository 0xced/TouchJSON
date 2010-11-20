//
//  CJSONDeserializer.m
//  TouchCode
//
//  Created by Jonathan Wight on 12/15/2005.
//  Copyright 2005 toxicsoftware.com. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "CJSONDeserializer.h"

#import "CJSONScanner.h"
#import "CDataScanner.h"

NSString *const kJSONDeserializerErrorDomain  = @"CJSONDeserializerErrorDomain";

@interface CJSONDeserializer ()
@end

@implementation CJSONDeserializer

@synthesize scanner;

+ (id)deserializer
{
return([[[self alloc] init] autorelease]);
}

- (id)init
{
if ((self = [super init]) != NULL)
    {
    scanner = [[CJSONScanner alloc] init];
    }
return(self);
}

- (void)dealloc
{
[scanner release];
scanner = NULL;
//
[super dealloc];
}

#pragma mark -

- (id)nullObject
    {
    return(self.scanner.nullObject);
    }

- (void)setNullObject:(id)inNullObject
    {
    self.scanner.nullObject = inNullObject;
    }

#pragma mark -

- (id)deserialize:(NSData *)inData scanSelector:(SEL)scanSelector error:(NSError **)outError
{
if (inData == NULL || [inData length] == 0)
	{
	if (outError)
		*outError = [NSError errorWithDomain:kJSONDeserializerErrorDomain code:-1 userInfo:NULL];

	return(NULL);
	}
self.scanner.data = inData;
if (self.scanner.data == NULL)
	{
	if (outError)
		{
		NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Invalid encoding. JSON data must be encoded in Unicode.", NSLocalizedDescriptionKey,
			NULL];
		*outError = [NSError errorWithDomain:kJSONDeserializerErrorDomain code:-2 userInfo:theUserInfo];
		}
	return(NULL);
	}
id theObject = NULL;
id *outObject = &theObject;
NSMethodSignature *methodSignature = [self.scanner methodSignatureForSelector:scanSelector];
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
[invocation setTarget:self.scanner];
[invocation setSelector:scanSelector];
[invocation setArgument:&outObject atIndex:2];
[invocation setArgument:&outError atIndex:3];
[invocation invoke];
BOOL success = NO;
[invocation getReturnValue:&success];

if (success == YES)
	return(theObject);
else
	return(NULL);
}

- (id)deserialize:(NSData *)inData error:(NSError **)outError
{
return [self deserialize:inData scanSelector:@selector(scanJSONObject:error:) error:outError];
}

- (id)deserializeAsDictionary:(NSData *)inData error:(NSError **)outError
{
return [self deserialize:inData scanSelector:@selector(scanJSONDictionary:error:) error:outError];
}

- (id)deserializeAsArray:(NSData *)inData error:(NSError **)outError
{
return [self deserialize:inData scanSelector:@selector(scanJSONArray:error:) error:outError];
}

@end
