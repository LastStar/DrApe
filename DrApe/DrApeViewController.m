//
//  DrApeViewController.m
//  DrApe
//
//  Created by EskiMag on 17.1.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "DrApeViewController.h"
#import "Utils.h"
#import "AlertPrompt.h"

@interface DrApeViewController ()
- (void)sendMove;
- (void)sendGameOver:(BOOL)player1Won;
@end


@implementation DrApeViewController

@synthesize game = _game,
      infoButton = _infoButton,
      scoreLabel = _scoreLabel,
 startGameButton = _startGameButton;

- (void)NSLogoc {
    [otherPlayerID release];
    otherPlayerID = nil;
    
    [_infoButton release];
    [_scoreLabel release];
    [_startGameButton release];
    [_game release];
//    [super NSLogoc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)infoPressed:(id)sender {
    FlipSideViewController *controller = [[FlipSideViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = self;
    controller.game = self.game;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        popover.popoverContentSize = controller.view.bounds.size;
        [popover presentPopoverFromRect:self.infoButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    } else {
        [self resignFirstResponder];
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
    }
    [controller release];
}

- (void)flipSideViewControllerDidFinish:(FlipSideViewController *)controller {
    [self dismissModalViewControllerAnimated:YES];
    [self becomeFirstResponder];
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
    self.infoButton.hidden = NO;
    [self.game startGame];
}

#pragma mark - DAGame Delegate methods

- (void)DAGame:(DAGame *)aGame tileHasBeenPressed:(DATile *)tile {
    [self sendMove];
}

- (void)tutorialSeen:(id)sender {
    [[self.view viewWithTag:1111] removeFromSuperview];
    [[self.view viewWithTag:2222] removeFromSuperview];
    [UD setBool:YES forKey:@"TutorialSeen"];
    [self.game startGame];
}

- (void)DAGame:(DAGame *)aGame addsNewTile:(DATile *)tile {
    [self.view addSubview:tile];
}

- (void)DAGameDidComplete:(DAGame *)aGame {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"You finished the whole game" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    [alertView release];
}

- (void)DAGameIsPlayingForFirstTime:(DAGame *)game  {
    UIButton *tutorial = [UIButton buttonWithType:UIButtonTypeCustom];
    tutorial.tag = 1111;
    tutorial.titleLabel.numberOfLines = 0;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        tutorial.frame = CGRectMake(0, 0, 1024, 768);
    } else {
       tutorial.frame = CGRectMake(0, 0, 480, 320);
    }
    UIWebView *tutText = [[UIWebView alloc] initWithFrame:tutorial.frame];
    tutText.tag = 2222;
    NSString *localizedString = NSLocalizedString(@"TutorialText", nil);
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><style>body {font-size:1.05em; background-color:black; color:#fff; font-family:Helvetica;} li {list-style:circle;} div {margin:10%% auto; width:250pt; text-align:left;}</style></head><body><div>%@</div></body></html>", localizedString];
    [tutText loadHTMLString:htmlString baseURL:nil];
    [tutText addSubview:tutorial];
    [tutorial addTarget:self action:@selector(tutorialSeen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tutText];
    [tutText release];
}

- (void)DAGameHasFinished:(DAGame *)game withScore:(NSUInteger)score totalScore:(NSUInteger)totalScore andMistake:(BOOL)mistake {
    NSString *startGameButtonTitle = NSLocalizedString(@"TapAnywhereToNewGame", nil);
    [self sendGameOver:isPlayer1];
    if (!mistake) {
        if (score == totalScore) {
            self.scoreLabel.text = [NSString stringWithFormat:@"%d", score];
        } else {
            self.scoreLabel.text = [NSString stringWithFormat:@"+%d=%d", score, totalScore];
        }
        self.scoreLabel.alpha = 1;
        [self.view bringSubviewToFront:self.scoreLabel];
        self.scoreLabel.hidden = NO;
        if (self.game.gameMode == DAGameModeCampaign) {
            startGameButtonTitle = NSLocalizedString(@"TapAnywhereToContinue", nil);
        }
    }
    
    [self.startGameButton setTitle:startGameButtonTitle forState:UIControlStateNormal];
    [self.view bringSubviewToFront:self.startGameButton];
    self.startGameButton.hidden = NO;
    self.infoButton.hidden = YES;
}

- (void)DAGame:(DAGame *)game hasNewHighScore:(NSUInteger)score {
    AlertPrompt *prompt = [[AlertPrompt alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"New High Score: %d", nil), score] message:NSLocalizedString(@"Enter your name please:", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) okButtonTitle:NSLocalizedString(@"Save", nil)];
    prompt.textField.text = [DAGame highestScoreName];
    [prompt show];
    [prompt release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        [DAGame setHighestScoreWithName:((AlertPrompt *)alertView).textField.text andAmount:self.game.tempScore];
    } 
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[GCHelper sharedInstance] authenticateLocalUserWithCompletionHandler:^(NSError *error) {
        [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self delegate:self];
    }];
    
    ourRandom = arc4random();
    [self setGameState:kGameStateWaitingForMatch];
    
//    NSLog(@"width, height = %f, %f", self.view.bounds.size.width, self.view.bounds.size.height);
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_screen.png"]];
    
    self.game = [[DAGame alloc] init];
    self.game.delegate = self;
    
    self.scoreLabel = [[UILabel alloc] init];
    self.scoreLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_tile.png"]];
    self.scoreLabel.textAlignment = UITextAlignmentCenter;
    self.scoreLabel.backgroundColor = [UIColor clearColor];
    self.scoreLabel.hidden = YES;
    [self.view addSubview:self.scoreLabel];
    [self.scoreLabel release];
    
    self.startGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.startGameButton.backgroundColor = [UIColor clearColor];
    [self.startGameButton setTitleColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_tile.png"]] forState:UIControlStateNormal];
    [self.startGameButton addTarget:self action:@selector(newGameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.startGameButton.hidden = YES;
    [self.view addSubview:self.startGameButton];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        self.scoreLabel.frame = CGRectMake(0, 300, 1024, 160);
        self.scoreLabel.font = [UIFont fontWithName:@"Helvetica" size:150];
        self.startGameButton.contentEdgeInsets = UIEdgeInsetsMake(730, 0, 0, 0);
        self.startGameButton.frame = CGRectMake(0, 0, 1024, 768);
        self.startGameButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    } else {
        self.scoreLabel.frame = CGRectMake(0, 110, 480, 100);
        self.scoreLabel.font = [UIFont fontWithName:@"Helvetica" size:90];
        self.startGameButton.contentEdgeInsets = UIEdgeInsetsMake(290, 0, 0, 0);
        self.startGameButton.frame = CGRectMake(0, 0, 480, 320);
        self.startGameButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    }
    
    if ([self.game isPlayingForFirstTime]) {
        [self DAGameIsPlayingForFirstTime:self.game];
    } else {
        [self.game startGame];
    }
}

- (void)motionEnded:(UIEventSubtype)motion
		  withEvent:(UIEvent *)event {
	if (motion == UIEventSubtypeMotionShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [self.game cancelGame];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Game Center methods

- (void)setGameState:(GameState)state {
    
    gameState = state;
    if (gameState == kGameStateWaitingForMatch) {
        NSLog(@"Waiting for match");
    } else if (gameState == kGameStateWaitingForRandomNumber) {
        NSLog(@"Waiting for rand #");
    } else if (gameState == kGameStateWaitingForStart) {
        NSLog(@"Waiting for start");
    } else if (gameState == kGameStateActive) {
        NSLog(@"Active");
    } else if (gameState == kGameStateDone) {
        NSLog(@"Done");
    } 
    
}

- (void)sendData:(NSData *)data {
    NSError *error;
    BOOL success = [[GCHelper sharedInstance].match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (!success) {
        NSLog(@"Error sending init packet");
        [self matchEnded];
    }
}

- (void)sendRandomNumber {
    
    MessageRandomNumber message;
    message.message.messageType = kMessageTypeRandomNumber;
    message.randomNumber = ourRandom;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];    
    [self sendData:data];
}

- (void)sendGameBegin {
    
    MessageGameBegin message;
    message.message.messageType = kMessageTypeGameBegin;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)];    
    [self sendData:data];
    
}

- (void)sendMove {
    
    MessageMove message;
    message.message.messageType = kMessageTypeMove;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageMove)];    
    [self sendData:data];
    
}

- (void)sendGameOver:(BOOL)player1Won {
    
    MessageGameOver message;
    message.message.messageType = kMessageTypeGameOver;
    message.player1Won = player1Won;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameOver)];    
    [self sendData:data];
    
}

    // Reload the current scene
    // [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:[HelloWorldLayer scene]]];

- (void)tryStartGame {
    
    if (isPlayer1 && gameState == kGameStateWaitingForStart) {
        [self setGameState:kGameStateActive];
        [self sendGameBegin];
//        starting the game
//        [self setupStringsWithOtherPlayerId:otherPlayerID];
    }
    
}

#pragma mark GCHelperDelegate

- (void)matchStarted {    
    NSLog(@"Match started");        
    if (receivedRandom) {
        [self setGameState:kGameStateWaitingForStart];
    } else {
        [self setGameState:kGameStateWaitingForRandomNumber];
    }
    [self sendRandomNumber];
    [self tryStartGame];
}

- (void)inviteReceived {
//    [self restartTapped:nil];    
    NSLog(@"Invite received.");
}

- (void)matchEnded {    
    NSLog(@"Match ended");    
    [[GCHelper sharedInstance].match disconnect];
    [GCHelper sharedInstance].match = nil;
//    [self endScene:kEndReasonDisconnect];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    
    // Store away other player ID for later
    if (otherPlayerID == nil) {
        otherPlayerID = [playerID retain];
    }
    
    Message *message = (Message *) [data bytes];
    if (message->messageType == kMessageTypeRandomNumber) {
        
        MessageRandomNumber * messageInit = (MessageRandomNumber *) [data bytes];
        NSLog(@"Received random number: %ud, ours %ud", messageInit->randomNumber, ourRandom);
        bool tie = false;
        
        if (messageInit->randomNumber == ourRandom) {
            NSLog(@"TIE!");
            tie = true;
            ourRandom = arc4random();
            [self sendRandomNumber];
        } else if (ourRandom > messageInit->randomNumber) {            
            NSLog(@"We are player 1");
            isPlayer1 = YES;            
        } else {
            NSLog(@"We are player 2");
            isPlayer1 = NO;
        }
        
        if (!tie) {
            receivedRandom = YES;    
            if (gameState == kGameStateWaitingForRandomNumber) {
                [self setGameState:kGameStateWaitingForStart];
            }
            [self tryStartGame];        
        }
        
    } else if (message->messageType == kMessageTypeGameBegin) {        
        
        [self setGameState:kGameStateActive];
//        [self setupStringsWithOtherPlayerId:playerID];
        
    } else if (message->messageType == kMessageTypeMove) {
        
        NSLog(@"Received move");
        
        if (isPlayer1) {
//            [player2 moveForward];
        } else {
//            [player1 moveForward];
        }        
    } else if (message->messageType == kMessageTypeGameOver) {        
        
        MessageGameOver * messageGameOver = (MessageGameOver *) [data bytes];
        NSLog(@"Received game over with player 1 won: %d", messageGameOver->player1Won);
        
        if (messageGameOver->player1Won) {
//            [self endScene:kEndReasonLose];    
        } else {
//            [self endScene:kEndReasonWin];    
        }
        
    }    
}


@end
