//
//  DrApeViewController.h
//  DrApe
//
//  Created by EskiMag on 17.1.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlipSideViewController.h"
#import "DAGame.h"
#import "GCHelper.h"

typedef enum {
    kMessageTypeRandomNumber = 0,
    kMessageTypeGameBegin,
    kMessageTypeMove,
    kMessageTypeGameOver
} MessageType;

typedef struct {
    MessageType messageType;
} Message;

typedef struct {
    Message message;
    uint32_t randomNumber;
} MessageRandomNumber;

typedef struct {
    Message message;
} MessageGameBegin;

typedef struct {
    Message message;
} MessageMove;

typedef struct {
    Message message;
    BOOL player1Won;
} MessageGameOver;

typedef enum {
    kEndReasonWin,
    kEndReasonLose,
    kEndReasonDisconnect
} EndReason;

typedef enum {
    kGameStateWaitingForMatch = 0,
    kGameStateWaitingForRandomNumber,
    kGameStateWaitingForStart,
    kGameStateActive,
    kGameStateDone
} GameState;
@interface DrApeViewController : UIViewController <FlipSideViewControllerDelegate,
                                                   DAGameDelegate,
                                                   UIAlertViewDelegate,
                                                   GCHelperDelegate> {
                                                       
    BOOL isPlayer1;        
    GameState gameState;
                                                       
    uint32_t ourRandom;
    BOOL receivedRandom;
    NSString *otherPlayerID;
}

@property (nonatomic, retain) DAGame *game;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) UILabel *scoreLabel;
@property (nonatomic, retain) UIButton *startGameButton;

- (IBAction)infoPressed:(id)sender;
- (void)setGameState:(GameState)state;

@end
