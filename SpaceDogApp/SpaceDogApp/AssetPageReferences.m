// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <QuartzCore/QuartzCore.h>
#import "AssetReference.h"
#import "AssetPageReferences.h"
#import "NSDictionary+ElementAndPropertyValues.h"

@class AssetReference;

@implementation AAssetPageReferences

@synthesize fPage;
@synthesize fPageAssetReferences;

-(id)initWithPage:(NSUInteger)page
{
   self = [super init];
   if (self)
   {
      fPage = page;
      fPageAssetReferences = [[NSMutableArray alloc] initWithCapacity:0]; 
   }
   return self;
}

-(void)dealloc
{
   [fPageAssetReferences release];
   [super dealloc];
}

-(AAssetReference*)AssetReferenceForElement:(NSDictionary*)element
{
   for (AAssetReference* ref in fPageAssetReferences)
   {
      if (ref.fElement == element)
      {
         return ref;
      }
   }
   return nil;
}

-(AAssetReference*)AssetReferenceForProperty:(NSDictionary*)property
{
   for (AAssetReference* ref in fPageAssetReferences)
   {
      NSDictionary* element = ref.fElement;
      NSArray* propertyList = element.propertyList;
      if ([propertyList containsObject:property])
      {
         return ref;
      }
   }
   return nil;
}

-(void)RunConcurrentAnimationsInGroup:(NSString*)animationGroup
{
   // collect all animations in the given group and run them together
   NSMutableArray* assetsWithAnimationsToRun = [NSMutableArray array];
   
   // use our global filter block
   [self.fPageAssetReferences enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
      
       AAssetReference* assetRef = (AAssetReference*)object;
       
       if ([animationGroup isEqualToString:assetRef.fAnimationGroup])
       {
          NSLog(@"adding animation for animationGroup: %@", assetRef.fAnimationGroup);
          [assetsWithAnimationsToRun addObject:assetRef];
       }
   }];
   
   if (0 < [assetsWithAnimationsToRun count])
   {
      [CATransaction begin];
      
      for (AAssetReference* assetRef in assetsWithAnimationsToRun)
      {
         CAAnimation* animation = assetRef.fStandaloneAnimation;
         
         [assetRef.fLayer addAnimation:animation forKey:[animation valueForKey:@"property"]];         
      }
      
      [CATransaction commit];
   }
}


@end
