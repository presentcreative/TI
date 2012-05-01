// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "NSString+PropertyValues.h"
#import "ImageSequence.h"

@implementation NSString (PropertyValues)

-(NSValue*)asSequenceTransitionValue
{
   NSValue* result = nil;
   
   NSArray* tsParts = [self componentsSeparatedByString:@","];
   
   if (2 == [tsParts count])
   {
      SequenceTransition ts;
      
      ts.sequence = [[tsParts objectAtIndex:0] intValue];
      ts.frame = [[tsParts objectAtIndex:1] intValue];
      
      result = [NSValue value:&ts withObjCType:@encode(SequenceTransition)];
   }
   
   return result;
}

@end
