//
//  BTMGame.h
//  BeatTheMonkey
//
//  Created by EskiMag on 17.1.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+BTM.h"
#import "BTMTile.h"

typedef enum { DAGameModeCampaign = 0,
               DAGameModeTraining = 1 } DAGameMode;

@protocol BTMGameDelegate;

@interface BTMGame : NSObject {}

+ (NSUInteger)highestScoreAmount;
+ (NSString *)highestScoreName;
+ (void)setHighestScoreWithName:(NSString *)name andAmount:(int)highestscore;

- (BTMGame *)initWithView:(UIView *)aView;
- (void)startGame;
- (void)cancelGame;
- (void)resetCampaign;
- (BOOL)isPlayingForFirstTime;

@property (nonatomic, assign) id<BTMGameDelegate> delegate;
@property (nonatomic, readonly) DAGameMode gameMode;
@property (nonatomic, readonly) NSUInteger difficulty;
@property (nonatomic, readonly) NSUInteger tempScore;

@end

@protocol BTMGameDelegate <NSObject>
- (void)btmGame:(BTMGame *)aGame hasNewHighScore:(NSUInteger)score;
- (void)btmGameHasFinished:(BTMGame *)aGame withScore:(NSUInteger)score totalScore:(NSUInteger)totalScore andMistake:(BOOL)aMistake;
- (void)btmGameIsPlayingForFirstTime:(BTMGame *)game;
@end
