//
//  DATile.h
//  DrApe
//
//  Created by EskiMag on 4.2.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"


@interface DATile : UIButton {}

@property (nonatomic, assign) BOOL mistaken;
@property (nonatomic, assign) NSUInteger position;

+ (void)setDelegate:(id<DATileDelegate>)delegate;
+ (NSMutableArray *)tiles;
+ (NSMutableArray *)positions;
+ (void)reset;
+ (void)removeAllTiles;
+ (void)hideAllTiles;
+ (void)mistakeAllTiles;
+ (void)showMistakenTiles;

- (void)hide;
- (void)flip;

@end
