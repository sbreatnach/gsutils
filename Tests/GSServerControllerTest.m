//
//  GSServerControllerTest.m
//  gsutils
//
//  Created by Shane Breatnach on 23/08/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "GSServerController.h"
#import "GSHTTPRequest.h"
#import "GSHTTPResponse.h"


@interface GSServerControllerTest : GHAsyncTestCase { }
@end

@implementation GSServerControllerTest

- (void)responseReceived:(GSHTTPResponse*)response
{
    if( response.statusCode == 200 )
    {
        [self notify:kGHUnitWaitStatusSuccess];
    }
    else
    {
        [self notify:kGHUnitWaitStatusFailure];
    }
}

- (void)testSuccessfulConnection
{
    [self prepare];
    GSHTTPRequest *request = [GSHTTPRequest request];
    request.host = @"www.google.ie";
    [[GSServerController sharedInstance] sendAsyncRequest:request
                                               withTarget:self
                                            andActionName:@"responseReceived:"];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
}

@end
