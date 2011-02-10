//
//  FlipSideViewController.m
//  BeatTheMonkey
//
//  Created by EskiMag on 8.2.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import "FlipSideViewController.h"

@implementation FlipSideViewController

@synthesize changed, delegate, game, infoButton, highScoreLabel, difficultyControl, tilesCountControl;

#pragma mark - Actions

- (IBAction)done:(id)sender {
    [self.delegate flipSideViewControllerDidFinish:self];
}

- (void)difficultySwitched:(id)sender {
    NSInteger timeToHide = 3 - [sender selectedSegmentIndex];
    [[NSUserDefaults standardUserDefaults] setInteger:timeToHide forKey:@"TimeToHide"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.game.timeToHide = timeToHide;
    self.changed = YES;
}

- (void)tilesCountSwitched:(id)sender {
    NSInteger tilesCount = [sender selectedSegmentIndex] + 4;
    [[NSUserDefaults standardUserDefaults] setInteger:tilesCount forKey:@"TilesCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.game.tilesCount = tilesCount;
    self.changed = YES;
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    return self;
}

- (void)dealloc {
    [super dealloc];
//    [self.highscores release];
//    [self.game release];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSLog(@"Hiding userInfo button");
        [self.infoButton setHidden:YES];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger timeToHide = [userDefaults integerForKey:@"TimeToHide"];
    NSInteger tilesCount = [userDefaults integerForKey:@"TilesCount"];
    self.difficultyControl.selectedSegmentIndex = -timeToHide + 3;
    self.tilesCountControl.selectedSegmentIndex =  tilesCount - 4;
    self.changed = NO;
    self.game.timeToHide = timeToHide;
    self.game.tilesCount = tilesCount;
    NSString *highestScoreName = [userDefaults stringForKey:@"HighestScoreName"];
    NSUInteger highestScoreAmount = [userDefaults integerForKey:@"HighestScoreAmount"];
    if (highestScoreAmount == 0) {
        self.highScoreLabel.text = @"";
    } else {
        self.highScoreLabel.text = [NSString stringWithFormat:@"Highest score %d achieved by %@", highestScoreAmount, highestScoreName];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.changed) {
        self.changed = NO;
        NSLog(@"Calling NSTimer 2");
        [NSTimer scheduledTimerWithTimeInterval:0.7 target:self.game
                                       selector:@selector(startGame) userInfo:nil repeats:NO];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.game = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
