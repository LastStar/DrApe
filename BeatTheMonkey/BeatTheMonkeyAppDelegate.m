//
//  BeatTheMonkeyAppDelegate.m
//  BeatTheMonkey
//
//  Created by EskiMag on 17.1.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import "BeatTheMonkeyAppDelegate.h"
#import "BeatTheMonkeyViewController.h"


@interface BeatTheMonkeyAppDelegate()
- (void)setupOptions;
@end

@implementation BeatTheMonkeyAppDelegate

@synthesize window, viewController, options;

- (void)setupOptions {
    NSString *settingsFileName = [NSString stringWithFormat:@"Settings-%@", (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad ? @"iPad" : @"iPhone")];
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSString *pathForSettings = [thisBundle pathForResource:settingsFileName ofType:@"plist"];
    NSLog(@"settingsFileName = %@", settingsFileName);
    NSLog(@"pathForSettings = %@", pathForSettings);
    self.options = [[NSDictionary alloc] initWithContentsOfFile:pathForSettings];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"launchOptions = %@", launchOptions);
    [self setupOptions];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.viewController.options = self.options;
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc {
    [window release];
    [viewController release];
    [super dealloc];
}

@end
