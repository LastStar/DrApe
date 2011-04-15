//
//  FlipSideViewController.m
//  BeatTheMonkey
//
//  Created by EskiMag on 8.2.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import "FlipSideViewController.h"
#import "Utils.h"

@implementation FlipSideViewController

@synthesize changed, delegate, game, infoButton, highScoreLabel, difficultyControl, tilesCountControl, levelUpgradingSwitch;

#pragma mark - Actions

- (NSUInteger)segmentFromTilesCount {
    return self.game.tilesCount - self.game.tilesCountMin;
}

- (IBAction)done:(id)sender {
    [self.delegate flipSideViewControllerDidFinish:self];
}

- (IBAction)automaticLevelUpgradingChanged:(id)sender {
    [UD setBool:self.levelUpgradingSwitch.on forKey:@"AutomaticLevelUpgrading"];
    [UD synchronize];
    self.changed = YES;
}

- (void)difficultySwitched:(id)sender {
    [UD setInteger:self.difficultyControl.selectedSegmentIndex forKey:@"Difficulty"];
    [UD synchronize];
    self.changed = YES;
}

- (void)tilesCountSwitched:(id)sender {
    NSInteger tilesCount = [sender selectedSegmentIndex] + 4;
    [UD setInteger:tilesCount forKey:@"TilesCount"];
    [UD synchronize];
    self.changed = YES;
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
// ...
    }
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

- (void)viewDidLoad {
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.infoButton.hidden = YES;
    }
    [self.tilesCountControl removeAllSegments];
    for (int i = self.game.tilesCountMin; i <= self.game.tilesCountMax; i++ ) {
        NSString *segmentTitle = [NSString stringWithFormat:@"%d", i];
        NSUInteger segmentIndex = (i - self.game.tilesCountMin);
        [self.tilesCountControl insertSegmentWithTitle:segmentTitle atIndex:segmentIndex animated:NO];
    }
    self.difficultyControl.selectedSegmentIndex = self.game.difficulty;
    self.tilesCountControl.selectedSegmentIndex = [self segmentFromTilesCount];
    self.levelUpgradingSwitch.on = self.game.automaticLevelUpgrading;
    self.changed = NO;
    if (self.game.highestScoreAmount == 0) {
        self.highScoreLabel.text = @"";
    } else {
        self.highScoreLabel.text = [NSString stringWithFormat:@"Highest score %d by %@", self.game.highestScoreAmount, self.game.highestScoreName];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.changed) {
        self.changed = NO;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
