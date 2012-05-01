// Copyright (c) 2011 Robert Gill, All rights reserved.
// $Id$

#import "NSMutableArray+Queue.h"


@implementation NSMutableArray (Queue)

-(id)dequeue
{
   id result = nil;
   
   if (0 < [self count])
   {
      result = [self objectAtIndex:0];
      
      if (nil != result)
      {
         [[result retain] autorelease];
         
         [self removeObjectAtIndex:0];
      }
   }
   
   return result;
}

-(void)enqueue:(id)anObject
{
   [self addObject:anObject];
}

-(id)peek
{
   id result = nil;
   
   if (0 < [self count])
   {
      result = [self objectAtIndex:0];
   }
   
   return result;
}

@end
