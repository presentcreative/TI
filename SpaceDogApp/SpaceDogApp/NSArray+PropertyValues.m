// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "NSArray+PropertyValues.h"


@implementation NSArray (PropertyValues)

-(CGPoint)asCGPoint
{
   CGPoint result = CGPointMake(0.0, 0.0);
   
   if (2 <= [self count])
   {
      NSNumber* x = (NSNumber*)[self objectAtIndex:0];
      NSNumber* y = (NSNumber*)[self objectAtIndex:1];
      
      result.x = [x floatValue];
      result.y = [y floatValue];
   }
   
   return result;   
}

-(CGSize)asCGSize
{
   CGSize result = CGSizeMake(0.0, 0.0);
   
   if (4 == [self count] || 2 == [self count])
   {
      int widthIndex = 0;
      int heightIndex = 1;
      
      if (4 == [self count])
      {
         widthIndex = 2;
         heightIndex = 3;
      }
      else if (2 == [self count])
      {
         widthIndex = 0;
         heightIndex = 1;
      }
       
      NSNumber* width = (NSNumber*)[self objectAtIndex:widthIndex];
      NSNumber* height = (NSNumber*)[self objectAtIndex:heightIndex];
      
      result.width = [width floatValue];
      result.height = [height floatValue];
   }
   
   return result;   
}

-(CGRect)asCGRect
{
   CGRect result = CGRectMake(0.0, 0.0, 0.0, 0.0);
         
   result.origin = [self asCGPoint];
   result.size = [self asCGSize];
   
   return result;
}

-(NSUInteger)chapter
{
   NSUInteger result = 0;
   
   if (2 == [self count])
   {
      result = [(NSNumber*)[self objectAtIndex:0] unsignedIntegerValue];
   }
   
   return result;
}

-(NSUInteger)page
{
   NSUInteger result = 0;
   
   if (2 == [self count])
   {
      result = [(NSNumber*)[self objectAtIndex:1] unsignedIntegerValue];
   }
   
   return result;
}

-(NSArray*)asPathPointsArray
{
   NSMutableArray* result = nil;
   
   if (0 < [self count])
   {
      result = [NSMutableArray arrayWithCapacity:[self count]];
      
      for (NSString* pointString in self)
      {
         [result addObject:[NSValue valueWithCGPoint:CGPointFromString(pointString)]];
      }
   }
   
   return result;
}

@end
