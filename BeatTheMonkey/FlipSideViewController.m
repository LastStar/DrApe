//
//  FlipSideViewController.m
//  BeatTheMonkey
//
//  Created by EskiMag on 8.2.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import "FlipSideViewController.h"
#import "Utils.h"
#import "SHK.h"


@implementation FlipSideViewController

    @synthesize  changed = _changed,
                delegate = _delegate,
                    game = _game,
              infoButton = _infoButton,
          highScoreLabel = _highScoreLabel,
       difficultyControl = _difficultyControl,
       tilesCountControl = _tilesCountControl,
         gameModeControl = _gameModeControl,
         tilesCountLabel = _tilesCountLabel,
gameModeDescriptionLabel = _gameModeDescriptionLabel,
 shareHighestScoreButton = _shareHighestScoreButton;

#pragma mark - Actions

- (void)shareHighestScore:(id)sender {
    // Create the item to share (in this example, a url)
	SHKItem *item = [SHKItem text:[NSString stringWithFormat:NSLocalizedString(@"HighestScoreShare", nil), [UD integerForKey:@"HighestScoreAmount"]]];
    
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
	// Display the action sheet
	[actionSheet showInView:self.view];
}

- (NSUInteger)segmentFromTilesCount {
    return [UD integerForKey:@"TilesCount"] - TILES_COUNT_MIN;
}

- (IBAction)done:(id)sender {
    [self.delegate flipSideViewControllerDidFinish:self];
}

- (void)showHideTilesCount {
    if (self.gameModeControl.selectedSegmentIndex == DAGameModeCampaign) {
        self.gameModeDescriptionLabel.hidden = NO;
        self.tilesCountLabel.hidden = YES;
        self.tilesCountControl.hidden = YES;
    } else {
        self.gameModeDescriptionLabel.hidden = YES;
        self.tilesCountLabel.hidden = NO;
        self.tilesCountControl.hidden = NO;
    }
}

- (IBAction)gameModeChanged:(id)sender {
    [UD setInteger:self.gameModeControl.selectedSegmentIndex forKey:@"GameMode"];
    [UD synchronize];
    self.changed = YES;
    [self showHideTilesCount];
}

- (void)difficultySwitched:(id)sender {
    [UD setInteger:self.difficultyControl.selectedSegmentIndex forKey:@"Difficulty"];
    [UD synchronize];
    self.changed = YES;
}

- (void)tilesCountSwitched:(id)sender {
    NSInteger tilesCount = [sender selectedSegmentIndex] + TILES_COUNT_MIN;
    [UD setInteger:tilesCount forKey:@"TilesCount"];
    [UD synchronize];
    self.changed = YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"KeyboardWillShow %@", notification);
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"KeyboardWillHide %@", notification);    
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
    [_infoButton release];
    [_highScoreLabel release];
    [_difficultyControl release];
    [_tilesCountControl release];
    [_gameModeDescriptionLabel release];
    [_game release];
    [_shareHighestScoreButton release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)setupDifficulties {
    for (int i = 0; i <= DIFFICULTY_MAX; i++) {
        [self.difficultyControl setEnabled:(i <= [UD integerForKey:@"DifficultyMaxAchieved"]) forSegmentAtIndex:i];
    }
    self.difficultyControl.selectedSegmentIndex = self.game.difficulty;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showHideTilesCount];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.infoButton.hidden = YES;
    }
    [self.tilesCountControl removeAllSegments];
    for (int i = TILES_COUNT_MIN; i <= TILES_COUNT_MAX; i++ ) {
        NSString *segmentTitle = [NSString stringWithFormat:@"%d", i];
        NSUInteger segmentIndex = (i - TILES_COUNT_MIN);
        [self.tilesCountControl insertSegmentWithTitle:segmentTitle atIndex:segmentIndex animated:NO];
    }
    [self setupDifficulties];
    self.tilesCountControl.selectedSegmentIndex = [self segmentFromTilesCount];
    self.gameModeControl.selectedSegmentIndex = self.game.gameMode;
    self.gameModeDescriptionLabel.text = NSLocalizedString(@"GameModeDescription", nil);
    self.changed = NO;
    if (self.game.highestScoreAmount == 0) {
        self.highScoreLabel.text = @"";
        self.shareHighestScoreButton.hidden = YES;
    } else {
        self.highScoreLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Highest score %d by %@", nil), self.game.highestScoreAmount, self.game.highestScoreName];
        self.shareHighestScoreButton.hidden = NO;
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
    self.game = nil;
    self.tilesCountLabel = nil;
    self.tilesCountControl = nil;
    self.difficultyControl = nil;
    self.highScoreLabel = nil;
    self.shareHighestScoreButton = nil;
    self.gameModeControl = nil;
    self.gameModeDescriptionLabel = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
