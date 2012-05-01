// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>

@class AAssetReference;

@interface AAssetPageReferences : NSObject {
   NSUInteger fPage;
   NSMutableArray* fPageAssetReferences; 
}

@property (nonatomic, readonly) NSUInteger fPage;
@property (nonatomic, readonly) NSMutableArray* fPageAssetReferences;

-(id)initWithPage:(NSUInteger)page;
-(AAssetReference*)AssetReferenceForElement:(NSDictionary*)element;
-(AAssetReference*)AssetReferenceForProperty:(NSDictionary*)property;

-(void)RunConcurrentAnimationsInGroup:(NSString*)animationGroup;

@end
