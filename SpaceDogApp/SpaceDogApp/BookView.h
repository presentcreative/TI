// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomAnimation.h"

//@class TiledPDFView; //wpm

@interface ABookView : UIImageView
{
   NSInteger fPageNumber;
   NSUInteger fAssetChapterNumber;
   NSInteger fAssetPageNumber;
   NSMutableDictionary* fAssets;
   NSMutableArray* fTriggersOnView;
   
   NSMutableArray* fHelpDescriptors;
   CALayer* fHelpSuperLayer;
   
   BOOL fStarted;
    
    // wpm
    // current pdf zoom scale
    CGFloat pdfScale;

    CGPDFPageRef page;
    CGPDFDocumentRef pdf;

}

@property (assign) NSInteger pageNumber;
@property (assign) NSUInteger assetChapterNumber;
@property (assign) NSInteger assetPageNumber;
@property (nonatomic, retain) NSMutableDictionary* assets;
@property (nonatomic, retain) NSMutableArray* helpDescriptors;
@property (nonatomic, retain) NSMutableArray* triggersOnView; 
@property (nonatomic, retain) CALayer* helpSuperLayer;

-(void)SetToPageNumber:(NSInteger)rawPageNumber;
-(void)LoadAssets;
-(void)LoadAssets:(NSString*)assetFilename;
-(void)RegisterAsset:(id<ACustomAnimation>)customAnimationAsset WithKey:(NSString*)assetKey;
-(void)StartAnimations;
-(void)StopAnimations;
-(void)DisplayLinkDidTick:(CADisplayLink*)displayLink;
-(void)ShowHelp;
-(void)Sterilize;

@end
