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
        alertView.outerFrameColor = [UIColor blackColor];
        alertView.buttonTextColor = [UIColor whiteColor];
        alertView.buttonShadowColor = [UIColor blackColor];
    }];
    
    [self keepAlive];

    return YES;
}

// https://github.com/davidkaminsky/Unplugged/
- (void)keepAlive
{
    UIApplication* app = [UIApplication sharedApplication];
    
    __weak __typeof(&*self)weakSelf = self;
    self.expirationHandler = ^{
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        [app endBackgroundTask:strongSelf.bgTask];
        strongSelf.bgTask = UIBackgroundTaskInvalid;
        strongSelf.bgTask = [app beginBackgroundTaskWithExpirationHandler:strongSelf.expirationHandler];
        NSLog(@"Expired");
        strongSelf.jobExpired = YES;
        while(strongSelf.jobExpired) {
            // spin while we wait for the task to actually end.
            [NSThread sleepForTimeInterval:1];
        }
        // Restart the background task so we can run forever.
        [strongSelf startBackgroundTask];
    };
    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:_expirationHandler];
}

- (void)startBackgroundTask
{
    NSLog(@"Restarting task");
    // Start the long-running task.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // When the job expires it still keeps running since we never exited it. Thus have the expiration handler
        // set a flag that the job expired and use that to exit the while loop and end the task.
        while(self.background && !self.jobExpired)
        {
            [NSThread sleepForTimeInterval:1];
        }
        
        self.jobExpired = NO;
    });
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[LTBlacklist shared] deactivate];
}

@end
