//
//  LTAppDelegate.m
//  LTBlacklist
//
//  Created by Lex on 6/26/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import "LTAppDelegate.h"
#import "LTBlacklistViewController.h"
#import "LTBlacklist.h"
#import "WCAlertView.h"

@implementation LTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[LTBlacklistViewController alloc] init]];
    navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.window.rootViewController = navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[LTBlacklist shared] activate];
    
    [WCAlertView setDefaultStyle:WCAlertViewStyleBlack];
    [WCAlertView setDefaultCustomiaztonBlock:^(WCAlertView *alertView) {
        alertView.labelTextColor = [UIColor whiteColor];
        alertView.labelShadowColor = [UIColor blackColor];
        alertView.outerFrameColor = [UIColor colorWithWhite:0.35f alpha:0.9f];
        alertView.buttonTextColor = [UIColor whiteColor];
        alertView.buttonShadowColor = [UIColor blackColor];
    }];

    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[LTBlacklist shared] deactivate];
}

@end
