//
//  BeatTheMonkeyViewController.m
//  BeatTheMonkey
//
//  Created by EskiMag on 17.1.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import "BeatTheMonkeyViewController.h"

@implementation BeatTheMonkeyViewController

@synthesize game, options, infoButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    NSLog(@"nibNameOrNil = %@, nibBundleOrNil = %@", nibNameOrNil, nibBundleOrNil);
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [game release];
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

#pragma mark - BTMGame Delegate methods

- (void)btmGameHasFinished:(BTMGame *)aGame mistake:(BOOL)aMistake {
    NSLog(@"Calling NSTimer 3");
    [NSTimer scheduledTimerWithTimeInterval:[self.options intForKey:@"TimeToStart"] target:self.game
                                   selector:@selector(startGame) userInfo:nil repeats:NO];
    if (!aMistake) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height / 2) - 80, self.view.bounds.size.width, 160)];
        label.text = [NSString stringWithFormat:@"%d", self.game.thisScore];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont fontWithName:@"Helvetica" size:150];
        label.backgroundColor = [UIColor blackColor];
        [self.view addSubview:label];
        [UIView animateWithDuration:0.5 animations:^(void) {
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
            [label release];
        }];    
    }
}

- (void)btmGameHasNewHighScore:(BTMGame *)aGame {
    NSString *alertMessage = [NSString stringWithFormat:@"New High Score %d. Please enter your name:", aGame.thisScore];
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:alertMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    [prompt addTextFieldWithValue:@"" label:nil];
    [[prompt textField] setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"HighestScoreName"]];
    [prompt show];
    [prompt release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.game addNewHighScoreWithName:[[alertView textField] text]];
    } 
    NSLog(@"Calling NSTimer 4");
    [NSTimer scheduledTimerWithTimeInterval:1 target:self.game selector:@selector(startGame) userInfo:nil repeats:NO];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"width, height = %f, %f", self.view.bounds.size.width, self.view.bounds.size.height);
    game = [[BTMGame alloc] initWithView:self.view andOptions:self.options];
    game.delegate = self;
    [game startGame];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
