// Copyright (c) 2011 Robert Gill, All rights reserved.
// $Id$

#import <Foundation/Foundation.h>

@interface NSMutableArray (Queue)
-(id)dequeue;
-(void)enqueue:(id)obj;
-(id)peek;
@end

