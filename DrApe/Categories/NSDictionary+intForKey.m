//
//  NSDictionary+DA.m
//  DrApe
//
//  Created by EskiMag on 8.2.2011.
//  Copyright 2011 LastStar.eu. All rights reserved.
//

#import "NSDictionary+intForKey.h"


@implementation NSDictionary (intForKey)
- (int)intForKey:(id)aKey {
    id obj = [self objectForKey:aKey];
    if (!obj) NSLog(@"Trying to get object for uknown key %@", aKey);
    return [obj intValue];
}
@end
