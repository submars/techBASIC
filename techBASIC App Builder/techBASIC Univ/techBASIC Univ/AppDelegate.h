//
//  AppDelegate.h
//  appStoreBASIC
//
//  Created by Mike Westerfield on 11/9/12.
//  Copyright (c) 2012 Mike Westerfield. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphicsViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GraphicsViewController *viewController;

+ (AppDelegate *) currentAppDelegate;
+ (UIViewController *) mainViewController;
- (void) setShowFullScreenWithNSNumber: (NSNumber *) flag;

@end
