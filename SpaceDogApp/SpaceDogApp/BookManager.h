// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>


@interface ABookManager : NSObject 
{
   NSDictionary* fBookInfo;
   
   NSUInteger fTotalNumberOfPages;
}

@property (nonatomic, retain) NSDictionary* bookInfo;
@property (readonly) NSUInteger TotalNumberOfPages;
@property (readonly) NSUInteger TotalNumberOfChapters;
@property (readonly) NSUInteger LastPageIndex;

+(ABookManager*)sharedBookManager;

-(NSUInteger)NumberOfPagesInChapter:(NSUInteger)chapter;
-(NSArray*)ChapterAndPageForRawPage:(NSInteger)rawPageNumber;
-(NSUInteger)RawPageIndexForChapter:(NSUInteger)chapter AndPage:(NSUInteger)page;
-(BOOL)ChapterIsBig:(NSUInteger)chapter;

@end
