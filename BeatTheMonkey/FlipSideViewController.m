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

- (double)difficultyToTime:(NSUInteger)aDifficulty {
    switch (aDifficulty) {
        case 0:
            return 2;
        case 1:
            return 1;
        case 2:
            return 0.5;
        default:
            return 2;
    }
}

- (NSUInteger)timeToDifficulty:(double)aTime {
    if (aTime==0.5) return 2;
    else if (aTime==1) return 1;
    else if (aTime==2) return 0;
    else return 0;
}

- (IBAction)done:(id)sender {
    [self.delegate flipSideViewControllerDidFinish:self];
}

- (void)difficultySwitched:(id)sender {
    double timeToHide = [self difficultyToTime:[sender selectedSegmentIndex]];
    [[NSUserDefaults standardUserDefaults] setDouble:timeToHide forKey:@"TimeToHide"];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    NSLog(@"timeToHide %f", timeToHide);
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
    [infoButton release];
    [highScoreLabel release];
    [difficultyControl release];
    [tilesCountControl release];
    [game release];
    [super dealloc];
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
//        NSLog(@"Hiding userInfo button");
        [self.infoButton setHidden:YES];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    double timeToHide = [userDefaults doubleForKey:@"TimeToHide"];
    NSInteger tilesCount = [userDefaults integerForKey:@"TilesCount"];
//    NSLog(@"tilesCount = %d", tilesCount);
    self.difficultyControl.selectedSegmentIndex = [self timeToDifficulty:timeToHide];
    self.tilesCountControl.selectedSegmentIndex = tilesCount==0 ? 0 : tilesCount-4;
    self.changed = NO;
    NSString *highestScoreName = [userDefaults stringForKey:@"HighestScoreName"];
    NSUInteger highestScoreAmount = [userDefaults integerForKey:@"HighestScoreAmount"];
    if (highestScoreAmount == 0) {
        self.highScoreLabel.text = @"";
    } else {
        self.highScoreLabel.text = [NSString stringWithFormat:@"Highest score %d by %@", highestScoreAmount, highestScoreName];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
//    NSLog(@"timeToHide viewWillDisappear %f", self.game.timeToHide);
    if (self.changed) {
        self.changed = NO;
//        NSLog(@"Calling NSTimer 2");
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
