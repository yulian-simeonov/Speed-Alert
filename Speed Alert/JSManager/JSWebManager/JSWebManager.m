//
//  WebManager.m
//  WebTest
//
//  Created by ZhiXing Li on 9/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSWebManager.h"

@implementation JSWebManager
@synthesize delegate;

-(id)initWithAsyncOption:(BOOL)isAsync
{
    if (self = [super init])
    {
        m_jsonManager = [[JSONManager alloc] initWithAsyncOption:isAsync];
        [m_jsonManager setDelegate:self];
        m_url = @"http://gps.trackometer.net/api/api_feedback?app=parkassist.ruhe.com&s=I like it&u=test@hotmail.om&a=hello";
        m_isAsync = isAsync;
        m_requestActionName = None;
    }
    return self;
}

-(void)dealloc
{
    [super dealloc];
    [m_jsonManager release];
}

-(void)CancelRequest
{
    [m_jsonManager RequestCancel];
}

-(void)JSONRequestFinished:(ASIHTTPRequest*)request decoder:(id)jsonDecoder
{
    if (delegate)
        [delegate ReceivedValue:request];
}

-(void)JSONRequestFailed:(NSError*)error
{
    if (delegate != nil)
    {
        [delegate WebManagerFailed:error];
    }
    m_requestActionName = None;
}
- (void)FileDownload:(NSString*)url savePath:(NSString *)path
{
    [m_jsonManager DownloadFile:url SavePath:path];
}

-(void)SubmitFeedback:(NSString*)text email:(NSString*)addr
{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"speedalert.ruhesystems.com.au", @"app",
                            text, @"s",
                            addr, @"u",
                            nil];
    [m_jsonManager JSONRequest:@"http://gps.trackometer.net/api/api_feedback" params:params requestMethod:POST];
}

-(void)GetSpeedSigns:(float)lat longtitude:(float)lng
{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"trackOmeter", @"name",
                            [NSString stringWithFormat:@"%f", lat + 0.002f], @"nelat",
                            [NSString stringWithFormat:@"%f", lat - 0.002f], @"swlat",
                            [NSString stringWithFormat:@"%f", lng + 0.002f], @"nelng",
                            [NSString stringWithFormat:@"%f", lng - 0.002f], @"swlng",
                            nil];
    [m_jsonManager JSONRequest:@"http://www.wikispeedia.org/a/marks_bb2.php" params:params requestMethod:GET];
}
@end
