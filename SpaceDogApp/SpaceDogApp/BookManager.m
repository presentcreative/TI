// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import "BookManager.h"
#import "Constants.h"
#import "NSDictionary+ElementAndPropertyValues.h"

typedef struct
{
   NSUInteger chapter;
   NSUInteger page;
   
} ChapterAndPage;

static ABookManager* sSharedBookManager = nil;
static NSMutableArray* sChapterAndPageMap = nil;

@interface ABookManager (Private)
-(NSString*)ChapterKeyForChapter:(NSUInteger)chapter;
@end


@implementation ABookManager

@synthesize bookInfo = fBookInfo;

+ (id)sharedBookManager
{
   @synchronized(self)
   {
      if (nil == sSharedBookManager)
      {
         sSharedBookManager = [[super allocWithZone:NULL] init];
      }
   }
   
   return sSharedBookManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
   return [[self sharedBookManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
   return self;
}

- (id)retain 
{
   return self;
}

- (unsigned)retainCount 
{
   return UINT_MAX; //denotes an object that cannot be released
}

- (oneway void)release 
{
   // never release
}

- (id)autorelease 
{
   return self;
}

- (id)init 
{
   if ((self = [super init])) 
   {
      NSURL* plistURL = [[NSBundle mainBundle] URLForResource:kBookInfoPlist withExtension:nil]; 
      NSDictionary* bookInformation = [[NSDictionary alloc] initWithContentsOfURL:plistURL];
      self.bookInfo = bookInformation;
      [bookInformation release];
      
      fTotalNumberOfPages = 0;
   }
   
   return self;
}

- (void)dealloc 
{
   // Should never be called, but just here for clarity really.
   Release(fBookInfo);
   
   [super dealloc];
}

#pragma mark -
#pragma mark Private Services
-(NSString*)ChapterKeyForChapter:(NSUInteger)chapter
{
   return [NSString stringWithFormat:kBookInfoChapterKeyTemplate, chapter];
}

#pragma mark -
#pragma mark Public Services
-(NSUInteger)RawPageIndexForChapter:(NSUInteger)chapter AndPage:(NSUInteger)page
{
   NSUInteger totalPages = 0;
   
   for (NSUInteger i = 1; i <= chapter; i++)
   {
      totalPages += [self NumberOfPagesInChapter:i];
   }
   
   return totalPages + page;
}

-(NSUInteger)NumberOfPagesInChapter:(NSUInteger)chapter
{
   NSDictionary* chapterInfo = [self.bookInfo objectForKey:[self ChapterKeyForChapter:chapter]];
   
   return chapterInfo.numPages;
}

-(NSArray*)ChapterAndPageForRawPage:(NSInteger)rawPageNumber
{
   NSArray* result = nil;
   
   if (0 > rawPageNumber)
   {
      return result;
   }
   
   // retrieve from the cache...
   if (nil != sChapterAndPageMap)
   {
      NSValue* chapterAndPageValue = [sChapterAndPageMap objectAtIndex:rawPageNumber];
      
      ChapterAndPage chapterAndPage;
      
      [chapterAndPageValue getValue:&chapterAndPage];
      
      result = [NSArray arrayWithObjects:
                [NSNumber numberWithUnsignedInteger:chapterAndPage.chapter], 
                [NSNumber numberWithUnsignedInteger:chapterAndPage.page], 
                nil];
   }
   else 
   {
      // build the cache...
      sChapterAndPageMap = [[NSMutableArray alloc] initWithCapacity:256];
            
      NSUInteger numChapters = [self TotalNumberOfChapters];
      
      for (NSUInteger i = 1; i <= numChapters; i++)
      {
         NSUInteger chapterPages = [self NumberOfPagesInChapter:i];
         
         for (int j = 0; j < chapterPages; j++)
         {
            ChapterAndPage cAndP;
            cAndP.chapter = i;
            cAndP.page = j;
            
            [sChapterAndPageMap addObject:[NSValue value:&cAndP withObjCType:@encode(ChapterAndPage)]];
         }
      }
      
      // ... and then recurse briefly now that the cache is built
      result = [self ChapterAndPageForRawPage:rawPageNumber];
   }
   
   return result;
}

-(NSUInteger)LastPageIndex
{
   return self.TotalNumberOfPages-1;
}

-(NSUInteger)TotalNumberOfPages
{
   if (0 == fTotalNumberOfPages)
   {
      NSUInteger numChapters = [self TotalNumberOfChapters];
      
      for (NSUInteger chapterIndex = 1; chapterIndex <= numChapters; chapterIndex++)
      {
         NSString* chapterKey = [NSString stringWithFormat:@"Chapter%d", chapterIndex];
         
         fTotalNumberOfPages += [[[self.bookInfo objectForKey:chapterKey] objectForKey:@"numPages"] unsignedIntegerValue];
      }
   }
   
   return fTotalNumberOfPages;
}

-(NSUInteger)TotalNumberOfChapters
{
   return [(NSNumber*)[self.bookInfo objectForKey:@"numChapters"] unsignedIntegerValue];
}

-(BOOL)ChapterIsBig:(NSUInteger)chapterNumber
{
   NSDictionary* chapterInfo = [self.bookInfo objectForKey:[self ChapterKeyForChapter:chapterNumber+1]];
   
   return chapterInfo.big;
}

@end
