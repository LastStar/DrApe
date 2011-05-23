//
//  DAGame.h
//  DrApe
//
//  Created by EskiMag on 17.1.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+intForKey.h"
#import "DATile.h"

typedef enum {
    DAGameModeCampaign = 0,
    DAGameModeTraining = 1
} DAGameMode;

@protocol DAGameDelegate;

@interface DAGame : NSObject {}

+ (NSUInteger)highestScoreAmount;
+ (NSString *)highestScoreName;
+ (void)setHighestScoreWithName:(NSString *)name andAmount:(int)highestscore;

- (void)startGame;
- (void)startMultiplayerGame;
- (void)cancelGame;
- (void)resetCampaign;
- (BOOL)isPlayingForFirstTime;

@property (nonatomic, assign) id<DAGameDelegate> delegate;
@property (nonatomic, readonly) DAGameMode gameMode;
@property (nonatomic, readonly) NSUInteger difficulty;
@property (nonatomic, readonly) NSUInteger tempScore;
@property (nonatomic, assign) BOOL multiplayer;

@end

@protocol DAGameDelegate <NSObject>
- (void)DAGame:(DAGame *)aGame hasNewHighScore:(NSUInteger)score;
- (void)DAGameHasFinished:(DAGame *)aGame withScore:(NSUInteger)score totalScore:(NSUInteger)totalScore andMistake:(BOOL)aMistake;
- (void)DAGameIsPlayingForFirstTime:(DAGame *)game;
- (void)DAGame:(DAGame *)aGame addsNewTile:(DATile *)tile;
- (void)DAGame:(DAGame *)aGame tileHasBeenPressed:(DATile *)tile;
- (void)DAGameDidComplete:(DAGame *)aGame;
@end
