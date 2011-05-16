//
//  DATile.h
//  DrApe
//
//  Created by EskiMag on 4.2.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DATile : UIButton {}

@property (nonatomic, assign) int position;
@property (nonatomic, assign) BOOL mistaken;

+ (DATile *)tileWithFrame:(CGRect)aFrame;

@end
