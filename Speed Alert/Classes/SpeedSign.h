//
//  SpeedSign.h
//  Speed Alert
//
//  Created by     on 11/8/13.
//  Copyright (c) 2013 michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpeedSign : NSObject
@property (nonatomic, retain) NSString* Text;
@property (nonatomic)       float Latitude;
@property (nonatomic)       float Longitude;
@property (nonatomic)       float Bearing;
@property (nonatomic)       float Kph;
@property (nonatomic)       float Mph;

-(id)initWithDictionary:(NSDictionary*)dicUserInfo;
@end
