//
//  BeatTheMonkeyViewController.m
//  BeatTheMonkey
//
//  Created by EskiMag on 17.1.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import "BeatTheMonkeyViewController.h"
#import "Utils.h"

@implementation BeatTheMonkeyViewController

@synthesize game = _game,
      infoButton = _infoButton,
      scoreLabel = _scoreLabel,
 startGameButton = _startGameButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    NSLog(@"nibNameOrNil = %@, nibBundleOrNil = %@", nibNameOrNil, nibBundleOrNil);
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [_game release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)infoPressed:(id)sender {
    FlipSideViewController *controller = [[FlipSideViewController alloc] initWithNibName:@"FlipSideViewController" bundle:nil];
    controller.delegate = self;
    controller.game = self.game;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        popover.popoverContentSize = controller.view.bounds.size;
        [popover presentPopoverFromRect:self.infoButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    } else {
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
    }
    [controller release];
}

- (void)flipSideViewControllerDidFinish:(FlipSideViewController *)controller {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)newGameButtonPressed:(id)sender {
    if (!self.scoreLabel.hidden) {
        [UIView animateWithDuration:0.4 animations:^(void) {
            self.scoreLabel.alpha = 0;
        } completion:^(BOOL finished) {
            self.scoreLabel.hidden = YES;
        }];    
    }
    self.startGameButton.hidden = YES;
//    NSLog(@"Calling NSTimer 3");
    [self.game startGame];
}

#pragma mark - BTMGame Delegate methods

- (void)btmGameHasFinished:(BTMGame *)aGame mistake:(BOOL)aMistake {
    if (!aMistake) {
        self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.game.thisScore];
        self.scoreLabel.alpha = 1;
        [self.view bringSubviewToFront:self.scoreLabel];
        self.scoreLabel.hidden = NO;
    }
    [self.view bringSubviewToFront:self.startGameButton];
    self.startGameButton.hidden = NO;
}

- (void)btmGameHasNewHighScore:(BTMGame *)aGame {
    NSString *alertMessage = [NSString stringWithFormat:@"New High Score %d. Please enter your name:", aGame.thisScore];
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:alertMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    [prompt addTextFieldWithValue:@"" label:nil];
    [[prompt textField] setText:[UD stringForKey:@"HighestScoreName"]];
    [prompt show];
    [prompt release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.game addNewHighScoreWithName:[[alertView textField] text]];
    } 
//    NSLog(@"Calling NSTimer 4");
    [NSTimer scheduledTimerWithTimeInterval:1 target:self.game selector:@selector(startGame) userInfo:nil repeats:NO];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSLog(@"width, height = %f, %f", self.view.bounds.size.width, self.view.bounds.size.height);
    self.game = [[BTMGame alloc] initWithView:self.view];
    self.game.delegate = self;
    
    self.scoreLabel = [[UILabel alloc] init];
    self.scoreLabel.textColor = [UIColor whiteColor];
    self.scoreLabel.textAlignment = UITextAlignmentCenter;
    self.scoreLabel.backgroundColor = [UIColor clearColor];
    self.scoreLabel.hidden = YES;
    [self.view addSubview:self.scoreLabel];
    [self.scoreLabel release];
    
    self.startGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.startGameButton.backgroundColor = [UIColor clearColor];
    [self.startGameButton setTitle:@"Tap anywhere on screen to start new game." forState:UIControlStateNormal];
    [self.startGameButton addTarget:self action:@selector(newGameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.startGameButton.hidden = YES;
    [self.view addSubview:self.startGameButton];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        self.scoreLabel.frame = CGRectMake(0, 300, 1024, 160);
        self.scoreLabel.font = [UIFont fontWithName:@"Helvetica" size:150];
        self.startGameButton.contentEdgeInsets = UIEdgeInsetsMake(730, 0, 0, 0);
        self.startGameButton.frame = CGRectMake(0, 0, 1024, 768);
        self.startGameButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
    } else {
        self.scoreLabel.frame = CGRectMake(0, 110, 480, 100);
        self.scoreLabel.font = [UIFont fontWithName:@"Helvetica" size:90];
        self.startGameButton.contentEdgeInsets = UIEdgeInsetsMake(290, 0, 0, 0);
        self.startGameButton.frame = CGRectMake(0, 0, 480, 320);
        self.startGameButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    }
    
    [self.game startGame];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
