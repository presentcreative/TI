// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>
#import "SoundEffect.h"

@interface ARandomSoundEffect : ASoundEffect
{
   NSMutableArray* fResourceNames;
}

@property (nonatomic, retain) NSMutableArray* resourceNames;

@end
