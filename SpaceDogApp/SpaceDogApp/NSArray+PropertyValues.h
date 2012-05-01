// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>


@interface NSArray (PropertyValues)

-(CGPoint)asCGPoint;
-(CGSize)asCGSize;
-(CGRect)asCGRect;

-(NSUInteger)chapter;
-(NSUInteger)page;

-(NSArray*)asPathPointsArray;

@end
