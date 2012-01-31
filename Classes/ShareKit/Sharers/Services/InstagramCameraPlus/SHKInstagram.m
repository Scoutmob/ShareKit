//
//  SHKInstagram.m
//  ShareKit
//
//  Created by Brett Gibson on 8/11/12.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import "SHKInstagram.h"

#import "SHK.h"

@interface SHK ()
// need to access the root view controller
- (UIViewController *)getCurrentRootViewController;
@end

@interface SHKInstagram ()
+ (void)cleanupImageFile;
@end

NSString *const kInstagramAppURL  = @"instagram://app";

@implementation SHKInstagram

// we need to save the image to disk to pass it on
static NSString *imageFilePath;

static BOOL instagramAvailable;

#pragma mark - init

+ (void)initialize
{
    if (imageFilePath == nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,
                                                             YES);
        NSString *docPath = [paths objectAtIndex:0];
        imageFilePath = [[docPath stringByAppendingPathComponent:@"SHKInstagram-Temp-Image.ig"] retain];

        [self cleanupImageFile];

        instagramAvailable = [[UIApplication sharedApplication]
                              canOpenURL:[NSURL URLWithString:kInstagramAppURL]];
    }
}

#pragma mark private class methods

+ (void)cleanupImageFile
{
    [self initialize];

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:imageFilePath])
    {
        [fileMgr removeItemAtPath:imageFilePath error:nil];
    }
}

#pragma mark - Configuration : Service Defination

+ (NSString *)sharerTitle
{
    [self initialize];
    return @"Instagram";
}

+ (BOOL)canShareImage
{
	return instagramAvailable;
}

+ (BOOL)shareRequiresInternetConnection
{
	return NO;
}

+ (BOOL)requiresAuthentication
{
	return NO;
}



- (id)init
{
    if (self = [super init])
    {
        [self.class initialize];
    }
    return self;
}

#pragma mark - Configuration : Dynamic Enable

- (BOOL)shouldAutoShare
{
	return YES;
}


#pragma mark - Share API Methods

- (BOOL)send
{
    [self.class cleanupImageFile];
  
    NSData *jpg = UIImageJPEGRepresentation(item.image,  1.0f);
    if (![jpg writeToFile:imageFilePath atomically:NO])
    {
        return NO;
    }
  
    NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", imageFilePath]];
  
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController
                                  interactionControllerWithURL:fileURL];
    [interactionController retain];
    interactionController.UTI = @"com.instagram.photo";

    if (item.title) {
        interactionController.annotation = [NSDictionary dictionaryWithObject:item.title forKey:@"InstagramCaption"];
    }

    NSLog(@"annotation %@\nicons %@\nname %@\nURL %@\nUTI %@",
          interactionController.annotation,
          interactionController.icons,
          interactionController.name,
          interactionController.URL,
          interactionController.UTI);

    CGRect r = CGRectMake(0, 0, 0, 0);
    UIView *v = [[SHK currentHelper] getCurrentRootViewController].view;
    [interactionController presentOpenInMenuFromRect:r inView:v animated:NO];

	return YES;
}

@end
