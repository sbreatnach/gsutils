/*
 Copyright (c) 2011-2012 GlicSoft
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of GlicSoft nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL GLICSOFT BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  GSNSDate+Utilities.m
//  gsutils
//
//  Created by Shane Breatnach on 24/01/2012.
//  Copyright (c) 2012 GlicSoft. All rights reserved.
//

#import "GSNSDate+Utilities.h"

@implementation NSDate (GSUtilities)

- (NSString*)humanReadableString
{
    return [self humanReadableStringWithLocale:[NSLocale currentLocale]];
}

- (NSString*)humanReadableStringWithLocale:(NSLocale *)locale
{
    NSCalendar *calendar = [locale objectForKey:NSLocaleCalendar];
    NSDate *curDate = [NSDate date];
    NSTimeInterval timestamp = [curDate timeIntervalSince1970];
    // get gap from midnight of current date
    NSTimeInterval secondsToLastMidnight = ((int)timestamp % (int)86400.0);
    NSDate *midnight = [NSDate dateWithTimeIntervalSince1970:
                        timestamp-secondsToLastMidnight];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setLocale:locale];
    NSString *output = nil;
    if( [self earlierDate:curDate] == self && [self laterDate:midnight] == self )
    {
        // date older than current date/time but from sometime today
        [formatter setDateFormat:@"HH:mm"];
        output = [formatter stringFromDate:self];
    }
    else if( [self earlierDate:midnight] == self )
    {
        NSDateComponents *curComponents = [calendar components:NSDayCalendarUnit
                                                      fromDate:self
                                                        toDate:midnight
                                                       options:NSWrapCalendarComponents];
        if( curComponents.day < 1 )
        {
            // from yesterday
            output = NSLocalizedString(@"Yesterday", nil);
        }
        else if( curComponents.day < 7 )
        {
            // sometime in the last week
            [formatter setDateFormat:@"EEEE"];
            output = [formatter stringFromDate:self];
        }
    }
    if( output == nil )
    {
        // older than a week or any future date, show ISO date
        [formatter setDateFormat:@"yyyy/MM/dd"];
        output = [formatter stringFromDate:self];
    }
    return output;
}

@end
