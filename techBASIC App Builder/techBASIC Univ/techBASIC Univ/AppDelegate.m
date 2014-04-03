//
//  AppDelegate.m
//  appStoreBASIC
//
//  Created by Mike Westerfield on 11/9/12.
//  Copyright (c) 2012 Mike Westerfield. All rights reserved.
//

#import "AppDelegate.h"

#import "GraphicsViewController.h"

@interface AppDelegate ()

@property (nonatomic) int showFullScreen;

- (void) getFiles;
- (void) setShowFullScreen: (int) flag;

@end

static AppDelegate *this;

@implementation AppDelegate

@synthesize showFullScreen;

- (void) dealloc {
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions {
    this = self;
    showFullScreen = 1;
    [self getFiles];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[[GraphicsViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil] autorelease];
    } else {
        self.viewController = [[[GraphicsViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil] autorelease];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

/*
 * Get the current iPhone app delegate. There is only one.
 *
 * Returns: The object instantiated from this class.
 */

+ (AppDelegate *) currentAppDelegate {
	return this;
}

/*
 * Move all files used by the BASIC program to the sandbox.
 *
 * Add or remove file names from the appFiles array, above. The files themselves should be placed in the Supporting Files/
 * Files group in the Xcode project. The code in this method may be commented out if the program does not need supporting
 * files.
 */

- (void) getFiles {
//	NSArray *fileNames = [[[NSArray alloc] initWithObjects: @"Gears.png", nil] autorelease];
//
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [paths objectAtIndex: 0];
//    
//    for (int i = 0; i < [fileNames count]; ++i) {
//        NSString *fullName = [fileNames objectAtIndex: i];
//        NSString *name = [fullName stringByDeletingPathExtension];
//        NSString *extension = [fullName pathExtension];
//        
//        NSString *destPath = [path stringByAppendingPathComponent: fullName];
//        NSString *srcPath = [[NSBundle mainBundle] pathForResource: name ofType: extension];
//        if (![[NSFileManager defaultManager] fileExistsAtPath: destPath])
//            [[NSFileManager defaultManager] removeItemAtPath: destPath error: nil];
//        [[NSFileManager defaultManager] copyItemAtPath: srcPath toPath: destPath error: nil];
//    }
}

/*
 * Get the main view controller where the BASIC app runs.
 *
 * Returns: The view controller that contains the BASIC app.
 */

+ (UIViewController *) mainViewController {
    return [this viewController];
}

/*
 * Set the show full screen flag and display mode.
 *
 * If in the graphcis display mode, setting to full screen displays the graphics screen on the entire available screen,
 * hiding all techBASIC related information. If not in graphics mode, this is ignored.
 *
 * This method is for use with selectors, which can't pass a straight int.
 *
 * Parameters:
 *	flag -	1 to use full screen mode and leave the sataus bar hidden
 *			-1 to use full screen and hide the status bar
 *			0 to leave full screen mode (Ignored in this implementation; only used in techBASIC.)
 */

- (void) setShowFullScreen: (int) flag {
    if (flag != showFullScreen) {
        showFullScreen = flag;
        if (showFullScreen) {
            // Hide or show the status bar.
            [[UIApplication sharedApplication] setStatusBarHidden: showFullScreen < 0
                                                    withAnimation: UIStatusBarAnimationNone];
            
            if (showFullScreen < 0) {
                // Use the space from the status bar.
                [[self.viewController view] setFrame: [[UIScreen mainScreen] bounds]];
            } else {
                // Get the height of the status bar.
                UIView *view = [self.viewController view];
                CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
                CGRect statusBarWindowRect = [view.window convertRect:statusBarFrame fromWindow: nil];
                CGRect statusBarViewRect = [view convertRect:statusBarWindowRect fromView: nil];
                
                // Leave space for the status bar.
                CGRect frame = [view frame];
                if (statusBarFrame.size.width < statusBarFrame.size.height) {
                    frame.size.width -= statusBarViewRect.size.height;
                    if (statusBarFrame.origin.x == 0) {
                        // Landscale Right.
                        frame.origin.x = statusBarViewRect.size.height;
                    } else {
                        // Landscale Left.
                        frame.origin.x = 0;
                    }
                } else {
                    frame.size.height -= statusBarViewRect.size.height;
                    if (statusBarFrame.origin.y == 0) {
                        // Portrait.
                        frame.origin.y = statusBarViewRect.size.height;
                    } else {
                        // Portrait Upside Down.
                        frame.origin.y = 0;
                    }
                }
                [view setFrame: frame];
            }
            [self.window makeKeyAndVisible];
        }
    }
}

/*
 * Set the show full screen flag and display mode.
 *
 * If in the graphcis display mode, setting to full screen displays the graphics screen on the entire available screen,
 * hiding all techBASIC related information. If not in graphics mode, this is ignored.
 *
 * This method is for use with selectors, which can't pass a straight int.
 *
 * Parameters:
 *	flag - 1 to use full screen mode, or 0 to clear it.
 */

- (void) setShowFullScreenWithNSNumber: (NSNumber *) flag {
	[self setShowFullScreen: [flag intValue]];
}

@end
