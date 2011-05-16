//
//  DrApeAppDelegate.m
//  DrApe
//
//  Created by EskiMag on 17.1.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import "DrApeAppDelegate.h"
#import "DrApeViewController.h"


@implementation DrApeAppDelegate

@synthesize window = _window,
    viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc {
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
