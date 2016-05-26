//
//  SpeedSign.m
//  Speed Alert
//
//  Created by     on 11/8/13.
//  Copyright (c) 2013 michael. All rights reserved.
//

#import "SpeedSign.h"

@implementation SpeedSign
-(id)initWithDictionary:(NSDictionary*)dicUserInfo
{
    if (self = [super init])
    {
        self.Text = [dicUserInfo objectForKey:@"label"];
        self.Latitude = [[dicUserInfo objectForKey:@"lat"] floatValue];
        self.Longitude = [[dicUserInfo objectForKey:@"lng"] floatValue];
        self.Mph = [[dicUserInfo objectForKey:@"mph"] floatValue];
        self.Kph = [[dicUserInfo objectForKey:@"kph"] floatValue];
        self.Bearing = [[dicUserInfo objectForKey:@"cog"] floatValue];
    }
    return self;
}
@end
